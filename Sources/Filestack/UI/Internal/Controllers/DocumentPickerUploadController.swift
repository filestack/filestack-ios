//
//  DocumentPickerUploadController.swift
//  Filestack
//
//  Created by Ruben Nine on 12/1/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import FilestackSDK
import UIKit
import Zip

class DocumentPickerUploadController: NSObject, Cancellable, Monitorizable {
    let uploader: Uploader & DeferredAdd
    let viewController: UIViewController
    let picker: UIDocumentPickerViewController
    let config: Config

    var progress: Progress { uploader.progress }

    init(uploader: Uploader & DeferredAdd, viewController: UIViewController, config: Config) {
        self.uploader = uploader
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

    @discardableResult
    func cancel() -> Bool {
        return uploader.cancel()
    }
}

extension DocumentPickerUploadController {
    private func upload(urls: [URL]) {
        guard !urls.isEmpty else {
            cancel()
            return
        }

        uploader.add(uploadables: urls.compactMap { uploadableURL(from: $0) })
        uploader.start()
    }

    private func uploadableURL(from url: URL) -> URL? {
        return url.isDirectory ? zipURL(from: url) : url
    }

    private func zipURL(from url: URL) -> URL? {
        let fileName = url.lastPathComponent
        
        return try? Zip.quickZipFiles([url], fileName: fileName)
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
