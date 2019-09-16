//
//  ImagePickerUploadController.swift
//  Filestack
//
//  Created by Ruben Nine on 10/23/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import AVFoundation.AVAssetExportSession
import FilestackSDK
import Foundation
import Photos
import SVProgressHUD

class ImagePickerUploadController: NSObject {
    let deferredUploader: Uploader & DeferredAdd
    let viewController: UIViewController

    let sourceType: UIImagePickerController.SourceType
    let config: Config

    private lazy var urlExtractor: URLExtractor = {
        URLExtractor(imageExportPreset: config.imageURLExportPreset,
                     videoExportPreset: config.videoExportPreset,
                     cameraImageQuality: config.imageExportQuality)
    }()

    private lazy var uploadableExtractor = UploadableExtractor()

    private var photoPickerController: PhotoPickerController?

    var filePickedCompletionHandler: ((_ success: Bool) -> Swift.Void)?

    init(uploader: Uploader & DeferredAdd,
         viewController: UIViewController,
         sourceType: UIImagePickerController.SourceType,
         config: Config) {
        self.deferredUploader = uploader
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
}

extension ImagePickerUploadController {
    private var sourceTypeSupportsMultipleSelection: Bool {
        return sourceType == .camera ? false : true
    }

    private var shouldUseCustomPicker: Bool {
        let multipleSelectionAllowed = config.maximumSelectionAllowed != 1
        let editingEnabled = config.showEditorBeforeUpload

        return sourceTypeSupportsMultipleSelection && (multipleSelectionAllowed || editingEnabled)
    }

    private var nativePicker: UINavigationController {
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

    private var customPicker: UINavigationController {
        let picker = PhotoPickerController(maximumSelection: config.maximumSelectionAllowed)

        // Keep a strong reference to the picker, so it does not go away while we still need it.
        photoPickerController = picker

        picker.delegate = self
        let navigation = picker.navigation
        navigation.modalPresentationStyle = config.modalPresentationStyle

        return navigation
    }

    private func editor(with image: UIImage) -> UIViewController {
        return EditorViewController(image: image, completion: { image in
            guard let image = image, let url = self.urlExtractor.fetchURL(image: image) else {
                self.cancelUpload()
                return
            }

            self.upload(url: url)
        })
    }
}

extension ImagePickerUploadController: PhotoPickerControllerDelegate {
    func photoPickerControllerDidCancel() {
        cancelUpload()
    }

    func photoPicker(_ controller: UINavigationController, didSelectAssets assets: [PHAsset]) {
        if config.showEditorBeforeUpload {
            showEditor(with: assets, on: controller)
        } else {
            upload(assets: assets)
        }
    }
}

extension ImagePickerUploadController: UploadListDelegate {
    func resignFromUpload() {
        cancelUpload()
    }

    func upload(_ elements: [SelectableElement]) {
        let urlList = elements.compactMap { $0.localURL }

        deferredUploader.add(uploadables: urlList)
        deferredUploader.start()
        filePickedCompletionHandler?(true)
    }
}

extension ImagePickerUploadController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true) {
            self.cancelUpload()
        }
    }

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true) { [unowned self] in
            self.upload(with: info)
        }
    }

    // MARK: - Private Functions

    private func upload(with info: [UIImagePickerController.InfoKey: Any]) {
        if let imageURL = info[.imageURL] as? URL {
            upload(url: imageURL)
        } else if let mediaURL = info[.mediaURL] as? URL {
            upload(url: mediaURL)
        } else if let image = info[.originalImage] as? UIImage, let url = self.urlExtractor.fetchURL(image: image) {
            upload(url: url)
        } else {
            cancelUpload()
        }
    }
}

extension ImagePickerUploadController {
    private func upload(assets: [PHAsset]) {
        SVProgressHUD.show(withStatus: "Preparing")

        urlExtractor.fetchURLs(assets, completion: { [weak self] urlList in
            guard let self = self else { return }

            SVProgressHUD.dismiss()

            self.viewController.dismiss(animated: true) { [weak self] in
                guard let self = self else { return }

                self.deferredUploader.add(uploadables: urlList)
                self.deferredUploader.start()
                self.filePickedCompletionHandler?(true)
            }
        })
    }

    private func showEditor(with assets: [PHAsset], on navigationController: UINavigationController) {
        if assets.count == 1 {
            handleSingleSelection(of: assets[0], on: navigationController)
        } else {
            showSelectionList(with: assets, on: navigationController)
        }
    }

    private func showSelectionList(with assets: [PHAsset], on navigationController: UINavigationController) {
        let editor = SelectionListViewController(assets: assets, config: config, delegate: self)
        navigationController.pushViewController(editor, animated: true)
    }

    private func handleSingleSelection(of asset: PHAsset, on navigationController: UINavigationController) {
        if asset.mediaType == .image {
            showEditor(with: asset, on: navigationController)
        } else {
            upload(assets: [asset])
        }
    }

    private func showEditor(with singleImageAsset: PHAsset, on navigationController: UINavigationController) {
        UploadableExtractor().fetchUploadable(of: singleImageAsset) { uploadable in
            guard let image = uploadable as? UIImage else {
                self.upload(assets: [singleImageAsset])
                return
            }

            navigationController.dismiss(animated: false) {
                self.viewController.present(self.editor(with: image), animated: false)
            }
        }
    }

    private func upload(url: URL) {
        deferredUploader.add(uploadables: [url])
        deferredUploader.start()
        filePickedCompletionHandler?(true)
    }

    private func cancelUpload() {
        deferredUploader.cancel()
        filePickedCompletionHandler?(false)
    }
}
