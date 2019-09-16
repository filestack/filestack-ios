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
    private let imageManager = PHCachingImageManager.default()

    func fetch(from assets: [PHAsset]) -> [Uploadable] {
        let dispatchGroup = DispatchGroup()
        let serialQueue = DispatchQueue(label: "serialQueue")
        var elements = [Uploadable]()
        for asset in assets {
            fetchUploadable(of: asset, inside: dispatchGroup) { element in
                guard let element = element else { return }
                serialQueue.sync { elements.append(element) }
            }
        }
        dispatchGroup.wait()
        return elements
    }

    func fetchUploadable(of asset: PHAsset, completion: @escaping (Uploadable?) -> Void) {
        switch asset.mediaType {
        case .image: fetchImage(for: asset, completion: completion)
        case .video: fetchVideo(for: asset, completion: completion)
        case .unknown, .audio:
            fallthrough
        @unknown default:
            completion(nil)
        }
    }
}

/// :nodoc:
private extension UploadableExtractor {
    func fetchUploadable(of asset: PHAsset, inside dispatchGroup: DispatchGroup, completion: @escaping (Uploadable?) -> Void) {
        dispatchGroup.enter()
        fetchUploadable(of: asset) { url in
            completion(url)
            dispatchGroup.leave()
        }
    }

    func fetchImage(for asset: PHAsset, completion: @escaping (Uploadable?) -> Void) {
        asset.fetchImage(forSize: PHImageManagerMaximumSize) { image in
            completion(image)
        }
    }

    func fetchVideo(for asset: PHAsset, completion: @escaping (Uploadable?) -> Void) {
        imageManager.requestAVAsset(forVideo: asset, options: videoRequestOptions) { avAsset, _, _ in
            completion(avAsset)
        }
    }

    var videoRequestOptions: PHVideoRequestOptions {
        let options = PHVideoRequestOptions()
        options.version = PHVideoRequestOptionsVersion.current
        options.deliveryMode = PHVideoRequestOptionsDeliveryMode.fastFormat
        return options
    }
}
