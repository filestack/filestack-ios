//
//  URLExtractor.swift
//  Filestack
//
//  Created by Mihály Papp on 02/08/2018.
//  Copyright © 2018 Filestack. All rights reserved.
//

import Photos
import UIKit

class URLExtractor {
    // MARK: - Private Properties

    private let imageManager = PHCachingImageManager.default()
    private let videoExportPreset: String
    private let imageExportPreset: ImageURLExportPreset
    private let cameraImageQuality: Float
    private let fetchAssetsOperationQueue = OperationQueue()

    // MARK: - Lifecycle

    init(imageExportPreset: ImageURLExportPreset, videoExportPreset: String, cameraImageQuality: Float) {
        self.videoExportPreset = videoExportPreset
        self.imageExportPreset = imageExportPreset
        self.cameraImageQuality = cameraImageQuality
    }
}

// MARK: - Calculated Properties

private extension URLExtractor {
    var videoRequestOptions: PHVideoRequestOptions {
        let options = PHVideoRequestOptions()

        options.version = PHVideoRequestOptionsVersion.current
        options.deliveryMode = PHVideoRequestOptionsDeliveryMode.highQualityFormat

        return options
    }
}

// MARK: - Internal Functions

extension URLExtractor {
    func fetchURLs(of assets: [PHAsset], config: Config, completion: @escaping (Result<[URL], Error>) -> Void) -> AssetURLExtractorOperation {
        let operation = AssetURLExtractorOperation(assets: assets, config: config)

        operation.completionBlock = {
            switch operation.result {
            case let .success(urls):
                completion(.success(urls))
            case let .failure(error):
                completion(.failure(error))
            }
        }

        fetchAssetsOperationQueue.addOperation(operation)

        return operation
    }

    func fetchURL(image: UIImage) -> URL? {
        switch imageExportPreset {
        case .current:
            // Use HEIC, and fallback to JPEG if it fails, since HEIC is not available in all devices
            // (see https://support.apple.com/en-us/HT207022)
            return exportedHEICImageURL(image: image) ?? exportedJPEGImageURL(image: image)
        case .compatible:
            // Use JPEG.
            return exportedJPEGImageURL(image: image)
        }
    }

    func fetchVideoURL(of asset: AVAsset, completion: @escaping (URL?) -> Void) -> AVAssetExportSession? {
        guard let export = self.videoExportSession(for: asset) else {
            completion(nil)
            return nil
        }

        let outputURL = export.outputURL
        export.exportAsynchronously {
            completion(outputURL)
        }
        return export
    }
}

// MARK: - Internal Functions

private extension URLExtractor {
    func fetchURL(of asset: PHAsset, completion: @escaping (URL?) -> Void) {
        switch asset.mediaType {
        case .image: fetchImageURL(of: asset, completion: completion)
        case .video: fetchVideoURL(of: asset, completion: completion)
        case .unknown, .audio:
            fallthrough
        @unknown default:
            completion(nil)
        }
    }

    func fetchURL(of asset: PHAsset, inside dispatchGroup: DispatchGroup, completion: @escaping (URL?) -> Void) {
        dispatchGroup.enter()
        fetchURL(of: asset) { url in
            completion(url)
            dispatchGroup.leave()
        }
    }
}

// MARK: - Helper Image Functions

private extension URLExtractor {
    func fetchImageURL(of asset: PHAsset, completion: @escaping (URL?) -> Void) {
        asset.requestContentEditingInput(with: nil) { editingInput, _ in
            if let editingInput = editingInput, let fullSizeImageURL = editingInput.fullSizeImageURL {
                if let outputURL = fullSizeImageURL.copyIntoTemporaryLocation() {
                    completion(outputURL)
                } else {
                    completion(nil)
                }
            } else {
                completion(nil)
            }
        }
    }

    func exportedHEICImageURL(image: UIImage) -> URL? {
        if let imageData = image.heicRepresentation(quality: cameraImageQuality) {
            let filename = UUID().uuidString + ".heic"
            return writeImageDataToURL(imageData: imageData, filename: filename)
        }

        return nil
    }

    func exportedJPEGImageURL(image: UIImage) -> URL? {
        if let imageData = image.jpegData(compressionQuality: CGFloat(cameraImageQuality)) {
            let filename = UUID().uuidString + ".jpeg"
            return writeImageDataToURL(imageData: imageData, filename: filename)
        }

        return nil
    }

    func writeImageDataToURL(imageData: Data, filename: String) -> URL? {
        do {
            let tmpURL = URL(fileURLWithPath: NSTemporaryDirectory() + filename)
            try imageData.write(to: tmpURL)
            return tmpURL
        } catch {
            return nil
        }
    }
}

// MARK: - Helper Video Functions

private extension URLExtractor {
    func fetchVideoURL(of asset: PHAsset, completion: @escaping (URL?) -> Void) {
        imageManager.requestAVAsset(forVideo: asset, options: videoRequestOptions) { element, _, _ in
            guard let element = element else {
                completion(nil)
                return
            }

            let exportSession = self.fetchVideoURL(of: element, completion: { url in
                completion(url)
            })

            if exportSession == nil {
                completion(nil)
            }
        }
    }

    func videoExportSession(for asset: AVAsset) -> AVAssetExportSession? {
        let export = AVAssetExportSession(asset: asset, presetName: preferedVideoPreset(for: asset))

        export?.outputURL = URL(fileURLWithPath: NSTemporaryDirectory() + UUID().uuidString + ".mov")
        export?.outputFileType = .mov

        return export
    }

    func preferedVideoPreset(for asset: AVAsset) -> String {
        let compatiblePresets = AVAssetExportSession.exportPresets(compatibleWith: asset)

        return compatiblePresets.contains(videoExportPreset) ? videoExportPreset : AVAssetExportPresetPassthrough
    }
}

