//
//  DocumentPickerUploadController.swift
//  Filestack
//
//  Created by Ruben Nine on 12/1/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import FilestackSDK
import Foundation

#if UseCarthage
    import ZipArchive
#else
    import SSZipArchive
#endif

class DocumentPickerUploadController: NSObject {
    let multifileUpload: MultifileUpload
    let viewController: UIViewController
    let picker: UIDocumentPickerViewController
    let config: Config

    var filePickedCompletionHandler: ((_ success: Bool) -> Swift.Void)?

    init(multifileUpload: MultifileUpload, viewController: UIViewController, config: Config) {
        self.multifileUpload = multifileUpload
        self.viewController = viewController
        picker = UIDocumentPickerViewController(documentTypes: config.documentPickerAllowedUTIs, in: .import)
        self.config = config
    }

    func start() {
        picker.delegate = self
        picker.modalPresentationStyle = config.modalPresentationStyle
        picker.allowsMultipleSelection = (config.maximumSelectionAllowed != 1)

        viewController.present(picker, animated: true, completion: nil)
    }
}

extension DocumentPickerUploadController {
    private func upload(urls: [URL]) {
        guard !urls.isEmpty else {
            cancel()
            return
        }

        multifileUpload.add(uploadables: urls.compactMap { validURL(from: $0) })
        startUpload()
    }

    private func validURL(from url: URL) -> URL? {
        return url.hasDirectoryPath ? zipURL(from: url) : url
    }

    private func zipURL(from url: URL) -> URL? {
        let tmpFilePath = tempZipPath(filename: url.lastPathComponent)
        let success = SSZipArchive.createZipFile(atPath: tmpFilePath,
                                                 withContentsOfDirectory: url.path,
                                                 keepParentDirectory: true)
        return success ? URL(fileURLWithPath: tmpFilePath) : nil
    }

    private func tempZipPath(filename: String) -> String {
        var path = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]
        path += "/\(UUID().uuidString)_\(filename).zip"
        return path
    }

    private func cancel() {
        multifileUpload.cancel()
        filePickedCompletionHandler?(false)
    }

    private func startUpload() {
        multifileUpload.start()
        filePickedCompletionHandler?(true)
    }
}

extension DocumentPickerUploadController: UIDocumentPickerDelegate {
    // called if the user dismisses the document picker without selecting a document (using the Cancel button)
    func documentPickerWasCancelled(_: UIDocumentPickerViewController) {
        cancel()
    }

    // Required
    func documentPicker(_: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        upload(urls: urls)
    }
}
