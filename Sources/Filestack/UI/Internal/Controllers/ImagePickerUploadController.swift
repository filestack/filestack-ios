//
//  ImagePickerUploadController.swift
//  Filestack
//
//  Created by Ruben Nine on 10/23/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import AVFoundation.AVAssetExportSession
import FilestackSDK
import Photos
import UIKit
import PhotosUI

class ImagePickerUploadController: NSObject, Cancellable, Monitorizable, Startable {
    let uploader: (Uploader & DeferredAdd)?
    let viewController: UIViewController

    private let completionBlock: (([URL]) -> Void)?
    private let trackingProgress = TrackingProgress()
    private var uploaderObservers: [NSKeyValueObservation] = []

    /// Adds `Monitorizable` Conformance
    var progress: Progress { trackingProgress }

    let sourceType: UIImagePickerController.SourceType
    let config: Config

    private lazy var urlExtractor: URLExtractor = {
        URLExtractor(imageExportPreset: config.imageURLExportPreset,
                     videoExportPreset: config.videoExportPreset,
                     cameraImageQuality: config.imageExportQuality)
    }()

    private lazy var uploadableExtractor = UploadableExtractor()
    private var photoPickerController: PhotoPickerController?
    private weak var urlExtractorOperation: AssetURLExtractorOperation?

    init(uploader: (Uploader & DeferredAdd)?,
         viewController: UIViewController,
         sourceType: UIImagePickerController.SourceType,
         config: Config,
         completionBlock: (([URL]) -> Void)? = nil) {
        self.uploader = uploader
        self.viewController = viewController
        self.sourceType = sourceType
        self.config = config
        self.completionBlock = completionBlock
    }

    /// Add `Startable` conformance.
    @discardableResult
    func start() -> Bool {
        if #available(iOS 14.0, *), sourceType != .camera {
            viewController.present(nativePicker, animated: true, completion: nil)
        } else if shouldUseCustomPicker {
            viewController.present(customPicker, animated: true, completion: nil)
        } else {
            viewController.present(legacyNativePicker, animated: true, completion: nil)
        }

        return true
    }

    /// Add `Cancellable` conformance.
    @discardableResult
    func cancel() -> Bool {
        urlExtractorOperation?.cancel()
        trackingProgress.cancel()
        completionBlock?([])

        return uploader?.cancel() ?? true
    }
}

// MARK: - Private Computed Properties

private extension ImagePickerUploadController {
    var sourceTypeSupportsMultipleSelection: Bool {
        return sourceType == .camera ? false : true
    }

    var shouldUseCustomPicker: Bool {
        let multipleSelectionAllowed = config.maximumSelectionAllowed != 1
        let editingEnabled = config.showEditorBeforeUpload

        return sourceTypeSupportsMultipleSelection && (multipleSelectionAllowed || editingEnabled)
    }

    @available(iOS 14.0, *)
    var nativePicker: PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = .any(of: config.photosPickerFilter.map(\.asPHFilter))
        configuration.selectionLimit = Int(config.maximumSelectionAllowed)
        configuration.preferredAssetRepresentationMode = .current

        let picker = PHPickerViewController(configuration: configuration)

        picker.delegate = self

        return picker
    }

    var legacyNativePicker: UIImagePickerController {
        let picker = UIImagePickerController()

        picker.delegate = self
        picker.modalPresentationStyle = config.modalPresentationStyle
        picker.sourceType = sourceType
        picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: sourceType)!
        picker.imageExportPreset = config.imageURLExportPreset.asImagePickerControllerImageURLExportPreset
        picker.videoExportPreset = config.videoExportPreset
        picker.videoQuality = config.videoQuality

        return picker
    }

    var customPicker: UINavigationController {
        let picker = PhotoPickerController(maximumSelection: config.maximumSelectionAllowed)
        picker.delegate = self

        // Keep a strong reference to the picker, so it does not go away while we still need it.
        photoPickerController = picker

        let navigation = picker.navigation
        navigation.modalPresentationStyle = config.modalPresentationStyle

        return navigation
    }
}

// MARK: - Private Functions

private extension ImagePickerUploadController {
    func extractAndUpload(assets: [PHAsset]) {
        let operation = urlExtractor.fetchURLs(of: assets, config: config) { (result) in
            self.urlExtractorOperation = nil

            switch result {
            case let .success(urls):
                self.upload(urls: urls)
            case .failure(_):
                self.cancel()
            }
        }

        urlExtractorOperation = operation
        trackingProgress.update(tracked: operation.progress)
    }

    @available(iOS 14.0, *)
    func extract(results: [PHPickerResult], updateTrackingProgress: Bool = true, completion: @escaping (([URL]) -> Void)) {
        let itemProviders = results.map(\.itemProvider)
        let progress = Progress(totalUnitCount: Int64(itemProviders.count))
        progress.localizedDescription = "Fetching \(progress.totalUnitCount) photo album asset(s)…"
        if updateTrackingProgress {
            trackingProgress.update(tracked: progress)
        }

        actor URLCollector {
            private var urls: [URL] = []
            
            func add(_ url: URL) {
                urls.append(url)
            }
            
            func getAllURLs() -> [URL] {
                return urls
            }
        }

        Task {
            let collector = URLCollector()
            await withThrowingTaskGroup(of: Void.self) { group in
                let providers = itemProviders
                for itemProvider in providers {
                    group.addTask {
                        // Get the appropriate type identifier based on config
                        let typeIdentifier = await self.getTypeIdentifier(for: itemProvider)
                        
                        guard let unwrappedTypeIdentifier = typeIdentifier else {
                            progress.completedUnitCount += 1
                            return
                        }
                        let url = await withCheckedContinuation { continuation in
                            itemProvider.loadFileRepresentation(forTypeIdentifier: unwrappedTypeIdentifier) { (url, error) in
                                defer { progress.completedUnitCount += 1 }
                                
                                // Move or copy the file into a temporary location
                                let tempURL = url?.moveIntoTemporaryLocation() ?? url?.copyIntoTemporaryLocation()
                                continuation.resume(returning: tempURL)
                            }
                        }
                        
                        if let url = url {
                            await collector.add(url)
                        }
                    }
                }

                try? await group.waitForAll()
            }

            let urls = await collector.getAllURLs()
            completion(urls)
        }
    }
    
    @available(iOS 14.0, *)
    private func getTypeIdentifier(for itemProvider: NSItemProvider) async -> String? {
        let registeredTypeIdentifiers = itemProvider.registeredTypeIdentifiers
        
        switch self.config.imageURLExportPreset {
        case .compatible:
            if registeredTypeIdentifiers.contains(AVFileType.jpg.rawValue) {
                return AVFileType.jpg.rawValue
            } else {
                return registeredTypeIdentifiers.first
            }
        case .current:
            if registeredTypeIdentifiers.contains(AVFileType.heic.rawValue) {
                return AVFileType.heic.rawValue
            } else {
                return registeredTypeIdentifiers.first
            }
        }
    }

    @available(iOS 14.0, *)
    func upload(results: [PHPickerResult]) {
        extract(results: results) { urls in
            if urls.count > 0 {
                self.upload(urls: urls)
            } else {
                self.cancel()
            }
        }
    }

    func upload(urls: [URL]) {
        completionBlock?(urls)

        guard let uploader = uploader else { return }

        trackingProgress.update(tracked: uploader.progress, delay: 1)

        let cleanup: () -> () = {
            self.trackingProgress.cancel()
            self.uploaderObservers.removeAll()
            self.photoPickerController = nil
        }

        uploaderObservers.append(uploader.progress.observe(\.isCancelled) { (_, _) in
            cleanup()
        })

        uploaderObservers.append(uploader.progress.observe(\.isFinished) { (_, _) in
            cleanup()
        })

        if uploader.state == .cancelled {
            for url in urls {
                if url.path.starts(with: FileManager.default.temporaryDirectory.path) {
                    try? FileManager.default.removeItem(at: url)
                }
            }
        } else {
            uploader.add(uploadables: urls)
            uploader.start()
        }
    }

    func editor(using image: UIImage) -> UIViewController {
        return EditorViewController(image: image, completion: { editedImage in
            guard let image = editedImage, let url = self.urlExtractor.fetchURL(image: image) else {
                self.cancel()
                return
            }

            self.upload(urls: [url])
        })
    }

    func showEditor(with asset: PHAsset) {
        // Fetch uploadable completion
        let completion: (Uploadable?, PHImageRequestID?) -> Void = { uploadable, requestID in
            guard let image = uploadable as? UIImage else {
                self.extractAndUpload(assets: [asset])
                return
            }

            self.showEditor(with: image)
        }

        guard uploadableExtractor.fetchUploadable(using: asset, completion: completion) != nil else {
            extractAndUpload(assets: [asset])
            return
        }
    }

    @available(iOS 14.0, *)
    func showEditor(with result: PHPickerResult) {
        extract(results: [result], updateTrackingProgress: false) { urls in
            guard let url = urls.first, let data = try? Data(contentsOf: url), let image = UIImage(data: data) else {
                self.cancel()
                return
            }

            DispatchQueue.main.async {
                self.showEditor(with: image)
            }
        }
    }

    func showEditor(with image: UIImage) {
        viewController.present(editor(using: image), animated: true)
    }
}

// MARK: - PhotoPickerControllerDelegate Conformance

extension ImagePickerUploadController: PhotoPickerControllerDelegate {
    func photoPickerControllerDidCancel(controller: UINavigationController) {
        controller.dismiss(animated: true) {
            self.cancel()
        }
    }

    func photoPicker(controller: UINavigationController, didSelectAssets assets: [PHAsset]) {
        controller.dismiss(animated: true) {
            if self.config.showEditorBeforeUpload, assets.count == 1, let asset = assets.first {
                self.showEditor(with: asset)
            } else {
                self.extractAndUpload(assets: assets)
            }
        }
    }
}

// MARK: - UIImagePickerControllerDelegate & UINavigationControllerDelegate Conformance

extension ImagePickerUploadController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true) {
            self.cancel()
        }
    }

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true) {
            if let imageURL = info[.imageURL] as? URL {
                self.upload(urls: [imageURL])
            } else if let mediaURL = info[.mediaURL] as? URL {
                self.upload(urls: [mediaURL])
            } else if let image = info[.originalImage] as? UIImage, let imageURL = self.urlExtractor.fetchURL(image: image) {
                self.upload(urls: [imageURL])
            } else {
                self.cancel()
            }
        }
    }
}

// MARK: - PHPickerViewControllerDelegate Conformance

@available(iOS 14, *)
extension ImagePickerUploadController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true) {
            if self.config.showEditorBeforeUpload, results.count == 1, let result = results.first {
                self.showEditor(with: result)
            } else {
                self.upload(results: results)
            }
        }
    }
}

// MARK: - UploadListDelegate Conformance

extension ImagePickerUploadController: UploadListDelegate {
    func resignFromUpload() {
        cancel()
    }

    func upload(_ elements: [SelectableElement]) {
        let urls = elements.compactMap(\.localURL)

        completionBlock?(urls)

        if let uploader = uploader {
            uploader.add(uploadables: urls)
            uploader.start()
        }
    }
}
