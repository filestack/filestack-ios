//
//  DocumentPickerUploadController.swift
//  Filestack
//
//  Created by Ruben Nine on 12/1/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation
import FilestackSDK

#if UseCarthage
    import ZipArchive
#else
    import SSZipArchive
#endif


internal class DocumentPickerUploadController: NSObject {

    let multifileUpload: MultifileUpload
    let viewController: UIViewController
    let picker: UIDocumentPickerViewController
    let config: Config
    
    var filePickedCompletionHandler: ((_ success: Bool) -> Swift.Void)? = nil


    init(multifileUpload: MultifileUpload, viewController: UIViewController, config: Config) {
        self.multifileUpload = multifileUpload
        self.viewController = viewController
        self.picker = UIDocumentPickerViewController(documentTypes: config.documentPickerAllowedUTIs, in: .import)
        self.config = config
    }


    func start() {
        picker.delegate = self
        picker.modalPresentationStyle = .currentContext
        if #available(iOS 11.0, *) {
            picker.allowsMultipleSelection = true
        }
        viewController.present(picker, animated: true, completion: nil)
    }

}

private extension DocumentPickerUploadController {
    func upload(urls: [URL]) {
        multifileUpload.uploadURLs = urls.compactMap { validUrl(from: $0) }
        guard multifileUpload.uploadURLs.count > 0 else {
            cancel()
            return
        }
        startUpload()
    }
    
    func validUrl(from url: URL) -> URL? {
        return url.hasDirectoryPath ? zipUrl(from: url) : url
    }
    
    func zipUrl(from url: URL) -> URL? {
        let tmpFilePath = tempZipPath(filename: url.lastPathComponent)
        let success = SSZipArchive.createZipFile(atPath: tmpFilePath,
                                                 withContentsOfDirectory: url.path,
                                                 keepParentDirectory: true)
        return success ? URL(fileURLWithPath: tmpFilePath) : nil
    }
    
    func tempZipPath(filename: String) -> String {
        var path = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]
        path += "/\(UUID().uuidString)_\(filename).zip"
        return path
    }

    func cancel() {
        multifileUpload.cancel()
        filePickedCompletionHandler?(false)
    }
    
    func startUpload() {
        multifileUpload.uploadFiles()
        filePickedCompletionHandler?(true)
    }
}

extension DocumentPickerUploadController: UIDocumentPickerDelegate {

    // called if the user dismisses the document picker without selecting a document (using the Cancel button)
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        cancel()
    }

    // Required
    @available(iOS 11.0, *)
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        upload(urls: urls)
    }

    @available(iOS, introduced: 8.0, deprecated: 11.0)
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        upload(urls: [url])
    }
}
