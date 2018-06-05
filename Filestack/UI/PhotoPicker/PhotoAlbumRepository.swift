//
//  PhotoAlbumRepository.swift
//  Filestack
//
//  Created by Mihály Papp on 29/05/2018.
//  Copyright © 2018 Filestack. All rights reserved.
//

import Photos

struct Album {
  let title: String
  let elements: [PHAsset]
}

class PhotoAlbumRepository {
  
  private var cachedAlbums: [Album]?
  
  init() {
    fetchAndCacheAlbums(completion: nil)
  }
  
  func getAlbums(completion: @escaping ([Album]) -> Void) {
    if let cachedAlbums = cachedAlbums {
      completion(cachedAlbums)
    }
    fetchAndCacheAlbums(completion: completion)
  }
  
  private func fetchAndCacheAlbums(completion: (([Album]) -> Void)?) {
    DispatchQueue.global(qos: .default).async {
      let collections = PHAssetCollection.allCollections(types: [.smartAlbum, .album])
      let allAlbums = collections.map { Album(title: $0.localizedTitle ?? "", elements: $0.allAssets) }
      let nonEmptyAlbums = allAlbums.filter { $0.elements.count > 0 }
      self.cachedAlbums = nonEmptyAlbums
      completion?(nonEmptyAlbums)
    }

  }
}

