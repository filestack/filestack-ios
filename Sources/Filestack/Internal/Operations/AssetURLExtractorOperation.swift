//
//  AssetURLExtractorOperation.swift
//  Filestack
//
//  Created by Ruben Nine on 08/07/2020.
//  Copyright © 2020 Filestack. All rights reserved.
//

import FilestackSDK
import Photos
import UIKit

class AssetURLExtractorOperation: BaseOperation<[URL]>, ProgressReporting, @unchecked Sendable {
    // MARK: - Internal Properties

    let assets: [PHAsset]

    // MARK: - Private Properties

    private let config: Config

    private(set) lazy var progress: Progress = {
        let progress = Progress(totalUnitCount: Int64(assets.count))

        progress.localizedDescription = "Processing \(assets.count) file(s)…"

        return progress
    }()

    private var imageRequestIDs: [PHImageRequestID] = []
    private var assetExportSessions: [AVAssetExportSession] = []

    private lazy var uploadableExtractor = UploadableExtractor()

    private lazy var urlExtractor: URLExtractor = {
        URLExtractor(imageExportPreset: config.imageURLExportPreset,
                     videoExportPreset: config.videoExportPreset,
                     cameraImageQuality: config.imageExportQuality)
    }()

    // MARK: - Lifecycle

    init(assets: [PHAsset], config: Config) {
        self.assets = assets
        self.config = config
    }

    // MARK: - Overrides

    override func main() {
        extract()
    }

    override func cancel() {
        super.cancel()

        for requestID in imageRequestIDs {
            PHImageManager.default().cancelImageRequest(requestID)
        }

        imageRequestIDs.removeAll()

        for exportSession in assetExportSessions {
            exportSession.cancelExport()
        }

        assetExportSessions.removeAll()
    }
}

// MARK: - Private Functions

private extension AssetURLExtractorOperation {
    func extract() {
        var urls: [URL] = []
        var completed: Int = 0

        let markProgress: (URL?, PHImageRequestID) -> () = { url, id in
            completed += 1

            self.imageRequestIDs.removeAll { $0 == id }
            self.progress.completedUnitCount = Int64(completed)

            if let url = url {
                urls.append(url)
            }

            if self.imageRequestIDs.count == 0, !self.isCancelled {
                self.finish(with: .success(urls))
            }
        }

        for asset in assets {
            let requestID: PHImageRequestID? = uploadableExtractor.fetchUploadable(using: asset) { (uploadable, id) in
                guard !self.isCancelled else { return }

                switch uploadable {
                case let image as UIImage:
                    if let url = self.urlExtractor.fetchURL(image: image) {
                        markProgress(url, id)
                    } else {
                        markProgress(nil, id)
                    }
                case let video as AVAsset:
                    let exportSession = self.urlExtractor.fetchVideoURL(of: video) { url in
                        markProgress(url, id)
                    }

                    if let exportSession = exportSession {
                        self.assetExportSessions.append(exportSession)
                    }
                default:
                    break
                }
            }

            if let requestID = requestID {
                imageRequestIDs.append(requestID)
            }
        }
    }
}
