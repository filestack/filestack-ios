//
//  DocumentPickerUploadController.swift
//  Filestack
//
//  Created by Ruben Nine on 12/1/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation
import FilestackSDK


internal class DocumentPickerUploadController: NSObject {

    let multipartUpload: MultipartUpload
    let viewController: UIViewController
    let picker: UIDocumentPickerViewController

    var filePickedCompletionHandler: ((_ success: Bool) -> Swift.Void)? = nil


    init(multipartUpload: MultipartUpload, viewController: UIViewController) {

        self.multipartUpload = multipartUpload
        self.viewController = viewController
        self.picker = UIDocumentPickerViewController(documentTypes: ["public.content"], in: .import)
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

        multipartUpload.localURL = url
        multipartUpload.uploadFile()
        filePickedCompletionHandler?(true)
    }

    fileprivate func cancel() {

        multipartUpload.cancel()
        filePickedCompletionHandler?(false)
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
