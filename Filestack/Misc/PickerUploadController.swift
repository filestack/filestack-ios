//
//  PickerUploadController.swift
//  Filestack
//
//  Created by Ruben Nine on 10/23/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation
import FilestackSDK


internal class PickerUploadController: NSObject {

    let multipartUpload: MultipartUpload
    let viewController: UIViewController
    let picker: UIImagePickerController
    let sourceType: UIImagePickerControllerSourceType

    var filePickedCompletionHandler: ((_ success: Bool) -> Swift.Void)? = nil

    init(multipartUpload: MultipartUpload, viewController: UIViewController, sourceType: UIImagePickerControllerSourceType) {

        self.multipartUpload = multipartUpload
        self.viewController = viewController
        self.sourceType = sourceType
        self.picker = UIImagePickerController()
    }


    func start() {

        picker.delegate = self
        picker.modalPresentationStyle = .currentContext
        picker.sourceType = sourceType
        picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: sourceType)!

        viewController.present(picker, animated: true, completion: nil)
    }
}

extension PickerUploadController: UIImagePickerControllerDelegate {

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {

        picker.dismiss(animated: true) {
            self.multipartUpload.cancel()
            self.filePickedCompletionHandler?(false)
        }
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {

        picker.dismiss(animated: true) {
            if let imageURL = info["UIImagePickerControllerImageURL"] as? URL {
                // Upload image from camera roll
                self.multipartUpload.localURL = imageURL
                self.multipartUpload.uploadFile()
            } else if let mediaURL = info["UIImagePickerControllerMediaURL"] as? URL {
                // Upload media (typically video) from camera roll
                self.multipartUpload.localURL = mediaURL
                self.multipartUpload.uploadFile()
            } else if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage {
                // Save picture as a temporary JPEG file
                if let imageData = UIImageJPEGRepresentation(image, 0.85) {
                    let tmpDir = NSTemporaryDirectory()
                    let tmpFileName = UUID().uuidString
                    let tmpURL = URL(fileURLWithPath: "\(tmpDir)\(tmpFileName).jpeg")

                    do {
                        try imageData.write(to: tmpURL)

                        self.multipartUpload.localURL = tmpURL
                        self.multipartUpload.uploadFile()
                    } catch {
                        self.multipartUpload.cancel()
                    }
                }
            }

            self.filePickedCompletionHandler?(true)
        }
    }
}

extension PickerUploadController: UINavigationControllerDelegate {

}
