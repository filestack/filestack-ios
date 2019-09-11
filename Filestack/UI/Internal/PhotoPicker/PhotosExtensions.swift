//
//  PhotosExtensions.swift
//  Filestack
//
//  Created by Mihály Papp on 29/05/2018.
//  Copyright © 2018 Filestack. All rights reserved.
//

import Photos

extension PHAsset {
    func fetchImage(forSize size: CGSize, completion: @escaping (UIImage?) -> Void) {
        let getMaximumSize = (size == PHImageManagerMaximumSize)
        let scaledSize = getMaximumSize ? PHImageManagerMaximumSize : adjustToScreenScale(size: size)
        let manager = PHImageManager.default()
        manager.requestImage(for: self, targetSize: scaledSize, contentMode: .aspectFit, options: requestOption(isSynchronous: getMaximumSize)) { image, _ in
            completion(image)
        }
    }

    private func adjustToScreenScale(size: CGSize) -> CGSize {
        let scale = UIScreen.main.scale
        return CGSize(width: size.width * scale, height: size.height * scale)
    }

    private func requestOption(isSynchronous: Bool = false) -> PHImageRequestOptions {
        let option = PHImageRequestOptions()
        option.isNetworkAccessAllowed = true
        option.isSynchronous = isSynchronous
        return option
    }
}

extension PHAssetCollection {
    class func allCollections(types: [PHAssetCollectionType]) -> [PHAssetCollection] {
        var allCollections = [PHAssetCollection]()
        types.forEach {
            let fetch = PHAssetCollection.fetchAssetCollections(with: $0, subtype: .any, options: nil)
            fetch.enumerateObjects { collection, _, _ in allCollections.append(collection) }
        }
        return allCollections
    }

    var allAssets: [PHAsset] {
        var allAssets = [PHAsset]()
        let fetch = PHAsset.fetchAssets(in: self, options: nil)
        fetch.enumerateObjects { asset, _, _ in allAssets.append(asset) }
        return allAssets
    }
}
