//
//  DocumentPickerUploadController.swift
//  Filestack
//
//  Created by Ruben Nine on 12/1/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import FilestackSDK
import UIKit
import ZIPFoundation

class DocumentPickerUploadController: NSObject, Cancellable, Monitorizable {
    let uploader: Uploader & DeferredAdd
    let viewController: UIViewController
    let picker: UIDocumentPickerViewController
    let config: Config

    private let trackingProgress = TrackingProgress()
    private var observers: [NSKeyValueObservation] = []

    var progress: Progress { trackingProgress }

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
        observers.removeAll()

        return uploader.cancel()
    }
}

extension DocumentPickerUploadController {
    private func upload(urls: [URL]) {
        DispatchQueue.global(qos: .userInitiated).async { self.doUpload(urls: urls) }
    }

    private func doUpload(urls: [URL]) {
        let progress = Progress(totalUnitCount: Int64(urls.count * 100))

        progress.localizedDescription = "Processing \(urls.count) file(s)…"
        progress.localizedAdditionalDescription = ""

        trackingProgress.update(tracked: progress)

        var uploadables: [URL] = []
        var individualProgress: [Int: Double] = [:]
        let dispatchGroup = DispatchGroup()

        let updateProgress: () -> () = {
            progress.localizedAdditionalDescription = "\(uploadables.count) of \(urls.count)"
        }

        updateProgress()

        for (idx, url) in urls.enumerated()  {
            dispatchGroup.enter()

            let fileProgress = Progress()

            observers.append(fileProgress.observe(\.fractionCompleted, options: [.new]) { (progress, change) in
                individualProgress[idx] = progress.fractionCompleted
                progress.completedUnitCount = Int64(individualProgress.values.reduce(0, +) * 100)
            })

            uploadableURL(from: url, progress: progress) { (url) in
                if let url = url {
                    uploadables.append(url)
                }

                updateProgress()
                dispatchGroup.leave()
            }
        }

        dispatchGroup.wait()

        observers.removeAll()

        guard !uploadables.isEmpty else {
            cancel()
            return
        }

        if uploader.state == .cancelled {
            for url in uploadables {
                if url.path.starts(with: FileManager.default.temporaryDirectory.path) {
                    try? FileManager.default.removeItem(at: url)
                }
            }
        } else {
            uploader.add(uploadables: uploadables)
            uploader.start()
            trackingProgress.update(tracked: uploader.progress)
        }
    }

    private func uploadableURL(from url: URL, progress: Progress, completion: (URL?) -> ()) {
        if url.isDirectory {
            completion(zipURL(from: url, progress: progress))
        } else {
            completion(url)
        }
    }

    private func zipURL(from url: URL, progress: Progress) -> URL? {
        let destinationURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(url.lastPathComponent)
            .appendingPathExtension("zip")

        do {
            try FileManager.default.zipItem(at: url,
                                            to: destinationURL,
                                            shouldKeepParent: true,
                                            compressionMethod: .deflate,
                                            progress: progress)
        } catch {
            return nil
        }

        if url.path.starts(with: FileManager.default.temporaryDirectory.path) {
            try? FileManager.default.removeItem(at: url)
        }

        return destinationURL
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
