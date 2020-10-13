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

class ImagePickerUploadController: NSObject, Cancellable, Monitorizable {
    let uploader: Uploader & DeferredAdd
    let viewController: UIViewController

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

    init(uploader: Uploader & DeferredAdd,
         viewController: UIViewController,
         sourceType: UIImagePickerController.SourceType,
         config: Config) {
        self.uploader = uploader
        self.viewController = viewController
        self.sourceType = sourceType
        self.config = config
    }

    func start() {
        if shouldUseCustomPicker {
            viewController.present(customPicker, animated: true, completion: nil)
        } else {
            viewController.present(nativePicker, animated: true, completion: nil)
        }
    }

    /// Adds `Cancellable` Conformance
    @discardableResult
    func cancel() -> Bool {
        urlExtractorOperation?.cancel()
        trackingProgress.cancel()

        return uploader.cancel()
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

    var nativePicker: UIImagePickerController {
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

    func upload(urls: [URL]) {
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

        uploader.add(uploadables: urls)
        uploader.start()
    }

    func editor(using image: UIImage) -> UIViewController {
        return EditorViewController(image: image, completion: { image in
            guard let image = image, let url = self.urlExtractor.fetchURL(image: image) else {
                self.cancel()
                return
            }

            self.upload(urls: [url])
        })
    }

    func showEditor(with asset: PHAsset, on navigationController: UINavigationController) {
        // Fetch uploadable completion
        let completion: (Uploadable?, PHImageRequestID?) -> Void = { uploadable, requestID in
            guard let image = uploadable as? UIImage else {
                self.extractAndUpload(assets: [asset])
                return
            }

            self.viewController.present(self.editor(using: image), animated: true)
        }

        guard uploadableExtractor.fetchUploadable(using: asset, completion: completion) != nil else {
            extractAndUpload(assets: [asset])
            return
        }
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
                self.showEditor(with: asset, on: controller)
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

// MARK: - UploadListDelegate Conformance

extension ImagePickerUploadController: UploadListDelegate {
    func resignFromUpload() {
        cancel()
    }

    func upload(_ elements: [SelectableElement]) {
        let urls = elements.compactMap(\.localURL)

        uploader.add(uploadables: urls)
        uploader.start()
    }
}
