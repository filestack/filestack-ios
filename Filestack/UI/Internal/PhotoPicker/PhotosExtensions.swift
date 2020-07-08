//
//  PhotosExtensions.swift
//  Filestack
//
//  Created by Mihály Papp on 29/05/2018.
//  Copyright © 2018 Filestack. All rights reserved.
//

import Photos

// MARK: - PHAsset Public Properties

extension PHAsset {
    func fetchImage(forSize size: CGSize, completion: @escaping (UIImage?, PHImageRequestID) -> Void) -> PHImageRequestID {
        let getMaximumSize = (size == PHImageManagerMaximumSize)
        let scaledSize = getMaximumSize ? PHImageManagerMaximumSize : adjustToScreenScale(size: size)
        let manager = PHImageManager.default()

        var requestID: PHImageRequestID!

        requestID = manager.requestImage(for: self,
                                    targetSize: scaledSize,
                                    contentMode: .aspectFit,
                                    options: requestOptions) { image, _ in
            completion(image, requestID)
        }

        return requestID
    }
}

// MARK: - PHAsset Computed Properties

private extension PHAsset {
    var requestOptions: PHImageRequestOptions {
        let option = PHImageRequestOptions()

        option.deliveryMode = .highQualityFormat
        option.isNetworkAccessAllowed = true
        option.isSynchronous = false

        return option
    }
}

// MARK: - PHAsset Private Functions

private extension PHAsset {
    func adjustToScreenScale(size: CGSize) -> CGSize {
        let scale = UIScreen.main.scale

        return CGSize(width: size.width * scale, height: size.height * scale)
    }
}

// MARK: - PHAssetCollection Functions

extension PHAssetCollection {
    class func allCollections(types: [PHAssetCollectionType]) -> [PHAssetCollection] {
        var allCollections = [PHAssetCollection]()

        for type in types {
            let fetch = PHAssetCollection.fetchAssetCollections(with: type, subtype: .any, options: nil)

            fetch.enumerateObjects { collection, _, _ in allCollections.append(collection) }
        }

        return allCollections
    }
}

// MARK: - PHAssetCollection Computed Properties

extension PHAssetCollection {
    var allAssets: [PHAsset] {
        var allAssets = [PHAsset]()
        let fetch = PHAsset.fetchAssets(in: self, options: nil)

        fetch.enumerateObjects { asset, _, _ in allAssets.append(asset) }

        return allAssets
    }
}
