//
//  ImagePickerUploadController.swift
//  Filestack
//
//  Created by Ruben Nine on 10/23/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation
import FilestackSDK
import AVFoundation.AVAssetExportSession


internal class ImagePickerUploadController: NSObject {

    let multifileUpload: MultifileUpload
    let viewController: UIViewController
    let picker: UIImagePickerController
    let sourceType: UIImagePickerControllerSourceType
    let config: Config

    var filePickedCompletionHandler: ((_ success: Bool) -> Swift.Void)? = nil


    init(multifileUpload: MultifileUpload,
         viewController: UIViewController,
         sourceType: UIImagePickerControllerSourceType,
         config: Config) {
        self.multifileUpload = multifileUpload
        self.viewController = viewController
        self.sourceType = sourceType
        self.picker = UIImagePickerController()
        self.config = config
    }


    func start() {

        picker.delegate = self
        picker.modalPresentationStyle = .currentContext
        picker.sourceType = sourceType
        picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: sourceType)!

        if #available(iOS 11.0, *) {
            picker.imageExportPreset = config.imageURLExportPreset.asImagePickerControllerImageURLExportPreset
            picker.videoExportPreset = config.videoExportPreset
        }

        picker.videoQuality = config.videoQuality

        viewController.present(picker, animated: true, completion: nil)
    }
}

extension ImagePickerUploadController: UIImagePickerControllerDelegate {

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {

        picker.dismiss(animated: true) {
            self.multifileUpload.cancel()
            self.filePickedCompletionHandler?(false)
        }
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {

        picker.dismiss(animated: true) {
            if let imageURL = info["UIImagePickerControllerImageURL"] as? URL {
                // Upload image from camera roll
                self.multifileUpload.uploadURLs = [imageURL]
                self.multifileUpload.uploadFiles()
            } else if let mediaURL = info["UIImagePickerControllerMediaURL"] as? URL {
                // Upload media (typically video) from camera roll
                self.multifileUpload.uploadURLs = [mediaURL]
                self.multifileUpload.uploadFiles()
            } else if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage {
                var exportedURL: URL?
                // Export to HEIC or JPEG following according to the image export preset.
                // On iOS versions before 11, this defaults always to JPEG.
                if #available(iOS 11.0, *), picker.imageExportPreset == .current {
                    exportedURL = self.exportedHEICImageURL(image: image) ?? self.exportedJPEGImageURL(image: image)
                } else {
                    exportedURL = self.exportedJPEGImageURL(image: image)
                }

                if let url = exportedURL {
                    self.multifileUpload.uploadURLs = [url]
                    self.multifileUpload.uploadFiles()
                } else {
                    self.multifileUpload.cancel()
                }
            }

            self.filePickedCompletionHandler?(true)
        }
    }


    // MARK: - Private Functions

    @available(iOS 11.0, *)
    private func exportedHEICImageURL(image: UIImage) -> URL? {

        // Save picture as a temporary HEIC file
        if let imageData = image.heicRepresentation(quality: config.imageExportQuality) {
            let filename = UUID().uuidString + ".heic"
            return writeImageDataToURL(imageData: imageData, filename: filename)
        }

        return nil
    }

    private func exportedJPEGImageURL(image: UIImage) -> URL? {

        // Save picture as a temporary JPEG file
        if let imageData = UIImageJPEGRepresentation(image, CGFloat(config.imageExportQuality)) {
            let filename = UUID().uuidString + ".jpeg"
            return writeImageDataToURL(imageData: imageData, filename: filename)
        }

        return nil
    }

    private func writeImageDataToURL(imageData: Data, filename: String) -> URL? {

        do {
            let tmpURL = URL(fileURLWithPath: NSTemporaryDirectory() + filename)
            try imageData.write(to: tmpURL)

            return tmpURL
        } catch {
            // NO-OP
            return nil
        }
    }
}

extension ImagePickerUploadController: UINavigationControllerDelegate {

}
