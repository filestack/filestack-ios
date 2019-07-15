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

internal class ImagePickerUploadController: NSObject {
    let multifileUpload: MultifileUpload
    let viewController: UIViewController

    let sourceType: UIImagePickerController.SourceType
    let config: Config

    private lazy var urlExtractor: UrlExtractor = {
        UrlExtractor(imageExportPreset: config.imageURLExportPreset,
                     videoExportPreset: config.videoExportPreset,
                     cameraImageQuality: config.imageExportQuality)
    }()

    private lazy var uploadableExtractor = UploadableExtractor()

    private var photoPickerController: PhotoPickerController?

    var filePickedCompletionHandler: ((_ success: Bool) -> Swift.Void)?

    init(multifileUpload: MultifileUpload,
         viewController: UIViewController,
         sourceType: UIImagePickerController.SourceType,
         config: Config) {
        self.multifileUpload = multifileUpload
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

private extension ImagePickerUploadController {
    var sourceTypeSupportsMultipleSelection: Bool {
        return sourceType == .camera ? false : true
    }

    var shouldUseCustomPicker: Bool {
        let multipleSelectionAllowed = config.maximumSelectionAllowed != 1
        let editingEnabled = config.showEditorBeforeUpload
        return sourceTypeSupportsMultipleSelection && (multipleSelectionAllowed || editingEnabled)
    }

    var nativePicker: UINavigationController {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.modalPresentationStyle = config.modalPresentationStyle
        picker.sourceType = sourceType
        picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: sourceType)!
        if #available(iOS 11.0, *) {
            picker.imageExportPreset = config.imageURLExportPreset.asImagePickerControllerImageURLExportPreset
            picker.videoExportPreset = config.videoExportPreset
        }
        picker.videoQuality = config.videoQuality
        return picker
    }

    var customPicker: UINavigationController {
        let picker = PhotoPickerController(maximumSelection: config.maximumSelectionAllowed)

        // Keep a strong reference to the picker, so it does not go away while we still need it.
        photoPickerController = picker

        picker.delegate = self
        let navigation = picker.navigation
        navigation.modalPresentationStyle = config.modalPresentationStyle
        return navigation
    }

    func editor(with image: UIImage) -> UIViewController {
        return EditorViewController(image: image, completion: { image in
            guard let image = image, let url = self.urlExtractor.fetchUrl(image: image) else {
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

        multifileUpload.uploadURLs = urlList
        multifileUpload.uploadFiles()
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

    private func upload(with info: [UIImagePickerController.InfoKey: Any]) {
        if let imageURL = info[.imageURL] as? URL {
            upload(url: imageURL)
        } else if let mediaURL = info[.mediaURL] as? URL {
            upload(url: mediaURL)
        } else if let image = info[.originalImage] as? UIImage, let url = self.urlExtractor.fetchUrl(image: image) {
            upload(url: url)
        } else {
            cancelUpload()
        }
    }
}

private extension ImagePickerUploadController {
    func upload(assets: [PHAsset]) {
        SVProgressHUD.show(withStatus: "Preparing")

        urlExtractor.fetchUrls(assets, completion: { [weak self] urlList in
            guard let self = self else { return }

            SVProgressHUD.dismiss()

            self.viewController.dismiss(animated: true) { [weak self] in
                guard let self = self else { return }

                self.multifileUpload.uploadURLs.append(contentsOf: urlList)
                self.multifileUpload.uploadFiles()
                self.filePickedCompletionHandler?(true)
            }
        })
    }

    func showEditor(with assets: [PHAsset], on navigationController: UINavigationController) {
        if assets.count == 1 {
            handleSingleSelection(of: assets[0], on: navigationController)
        } else {
            showSelectionList(with: assets, on: navigationController)
        }
    }

    func showSelectionList(with assets: [PHAsset], on navigationController: UINavigationController) {
        let editor = SelectionListViewController(assets: assets, config: config, delegate: self)
        navigationController.pushViewController(editor, animated: true)
    }

    func handleSingleSelection(of asset: PHAsset, on navigationController: UINavigationController) {
        if asset.mediaType == .image {
            showEditor(with: asset, on: navigationController)
        } else {
            upload(assets: [asset])
        }
    }

    func showEditor(with singleImageAsset: PHAsset, on navigationController: UINavigationController) {
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

    func upload(url: URL) {
        multifileUpload.uploadURLs = [url]
        multifileUpload.uploadFiles()
        filePickedCompletionHandler?(true)
    }

    func cancelUpload() {
        multifileUpload.cancel()
        filePickedCompletionHandler?(false)
    }
}
