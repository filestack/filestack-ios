//
//  DocumentPickerUploadController.swift
//  Filestack
//
//  Created by Ruben Nine on 12/1/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation
import FilestackSDK
import ZipArchive


internal class DocumentPickerUploadController: NSObject {

    let multipartUpload: MultipartUpload
    let viewController: UIViewController
    let picker: UIDocumentPickerViewController
    let config: Config
    
    var filePickedCompletionHandler: ((_ success: Bool) -> Swift.Void)? = nil


    init(multipartUpload: MultipartUpload, viewController: UIViewController, config: Config) {

        self.multipartUpload = multipartUpload
        self.viewController = viewController
        self.picker = UIDocumentPickerViewController(documentTypes: config.documentPickerAllowedUTIs, in: .import)
        self.config = config
    }


    func start() {

        picker.delegate = self
        picker.modalPresentationStyle = .currentContext

        if #available(iOS 11.0, *) {
            picker.allowsMultipleSelection = false
        }

        viewController.present(picker, animated: true, completion: nil)
    }


    // MARK: - Private Functions

    fileprivate func upload(url: URL) {

        if url.hasDirectoryPath {
            // Likely a bundle — let's attempt to zip it.
            let tmpFilePath = tempZipPath(filename: url.lastPathComponent)

            let success = SSZipArchive.createZipFile(atPath: tmpFilePath,
                                                     withContentsOfDirectory: url.path,
                                                     keepParentDirectory: true)

            if success {
                multipartUpload.localURL = URL(fileURLWithPath: tmpFilePath)
            } else {
                multipartUpload.cancel()
                filePickedCompletionHandler?(false)

                return
            }
        } else {
            // Regular file
            multipartUpload.localURL = url
        }

        multipartUpload.uploadFile()
        filePickedCompletionHandler?(true)
    }

    fileprivate func cancel() {

        multipartUpload.cancel()
        filePickedCompletionHandler?(false)
    }

    private func tempZipPath(filename: String) -> String {

        let uuid = UUID().uuidString
        var path = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]

        path += "/\(uuid)_\(filename).zip"

        return path
    }
}

extension DocumentPickerUploadController: UIDocumentPickerDelegate {

    // called if the user dismisses the document picker without selecting a document (using the Cancel button)
    public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {

        cancel()
    }

    // Required
    @available(iOS 11.0, *)
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {

        if let url = urls.first {
            upload(url: url)
        } else {
            cancel()
        }
    }

    @available(iOS, introduced: 8.0, deprecated: 11.0)
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {

        upload(url: url)
    }
}
