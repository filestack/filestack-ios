//
//  UploadableExtractor.swift
//  Filestack
//
//  Created by Mihály Papp on 02/08/2018.
//  Copyright © 2018 Filestack. All rights reserved.
//

import Foundation
import Photos

class UploadableExtractor {
    // MARK: - Private Properties

    private lazy var imageManager = PHCachingImageManager.default()

    private lazy var videoRequestOptions: PHVideoRequestOptions = {
        let options = PHVideoRequestOptions()

        options.version = PHVideoRequestOptionsVersion.current
        options.deliveryMode = PHVideoRequestOptionsDeliveryMode.fastFormat

        return options
    }()
}

// MARK: - Internal Functions

extension UploadableExtractor {
    func fetchUploadable(using asset: PHAsset, completion: @escaping (Uploadable?, PHImageRequestID) -> Void) -> PHImageRequestID? {
        switch asset.mediaType {
        case .image: return fetchImage(for: asset, completion: completion)
        case .video: return fetchVideo(for: asset, completion: completion)
        case .unknown, .audio: fallthrough
        @unknown default: return nil
        }
    }

    func cancelFetch(using requestID: PHImageRequestID) {
        PHImageManager.default().cancelImageRequest(requestID)
    }
}

// MARK: - Private Functions

private extension UploadableExtractor {
    func fetchImage(for asset: PHAsset, completion: @escaping (Uploadable?, PHImageRequestID) -> Void) -> PHImageRequestID {
        return asset.fetchImage(forSize: PHImageManagerMaximumSize) { image, requestID in
            completion(image, requestID)
        }
    }

    func fetchVideo(for asset: PHAsset, completion: @escaping (Uploadable?, PHImageRequestID) -> Void) -> PHImageRequestID {
        var requestID: PHImageRequestID!

        requestID = imageManager.requestAVAsset(forVideo: asset, options: videoRequestOptions) { avAsset, _, _ in
            completion(avAsset, requestID)
        }

        return requestID
    }
}
