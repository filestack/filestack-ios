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
    let deferredUploader: Uploader & DeferredAdd
    let viewController: UIViewController
    let picker: UIDocumentPickerViewController
    let config: Config

    var filePickedCompletionHandler: ((_ success: Bool) -> Void)?

    init(uploader: Uploader & DeferredAdd, viewController: UIViewController, config: Config) {
        self.deferredUploader = uploader
        self.viewController = viewController
        self.picker = UIDocumentPickerViewController(documentTypes: config.documentPickerAllowedUTIs, in: .import)
        self.config = config
    }

    func start() {
        picker.delegate = self
        picker.modalPresentationStyle = config.modalPresentationStyle
        picker.allowsMultipleSelection = (config.maximumSelectionAllowed != 1)

        viewController.present(picker, animated: true)
    }
}

extension DocumentPickerUploadController {
    private func upload(urls: [URL]) {
        guard !urls.isEmpty else {
            cancel()
            return
        }

        deferredUploader.add(uploadables: urls.compactMap { uploadableURL(from: $0) })
        deferredUploader.start()
        filePickedCompletionHandler?(true)
    }

    private func cancel() {
        deferredUploader.cancel()
        filePickedCompletionHandler?(false)
    }

    private func uploadableURL(from url: URL) -> URL? {
        return url.isDirectory ? zipURL(from: url) : url
    }

    private func zipURL(from url: URL) -> URL? {
        guard let tmpFileURL = tempZipURL(filename: url.lastPathComponent),
            SSZipArchive.createZipFile(atPath: tmpFileURL.path,
                                       withContentsOfDirectory: url.path,
                                       keepParentDirectory: true) else { return nil }

        return tmpFileURL
    }

    private func tempZipURL(filename: String) -> URL? {
        let cachesDirectoryURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first

        return cachesDirectoryURL?
            .appendingPathComponent(UUID().uuidString + "_" + filename)
            .appendingPathExtension("zip")
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
