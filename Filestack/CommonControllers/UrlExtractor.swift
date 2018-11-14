//
//  UrlExtractor.swift
//  Filestack
//
//  Created by Mihály Papp on 02/08/2018.
//  Copyright © 2018 Filestack. All rights reserved.
//

import Foundation
import Photos

class UrlExtractor {
  
  private let imageManager = PHCachingImageManager.default()
  
  private let videoExportPreset: String
  private let imageExportPreset: ImageURLExportPreset
  private let cameraImageQuality: Float

  init(imageExportPreset: ImageURLExportPreset, videoExportPreset: String, cameraImageQuality: Float) {
    self.videoExportPreset = videoExportPreset
    self.imageExportPreset = imageExportPreset
    self.cameraImageQuality = cameraImageQuality
  }
  
  func fetchUrls(_ elements: [Uploadable]) -> [URL] {
    let dispatchGroup = DispatchGroup()
    var urlList = [URL]()
    let serialQueue = DispatchQueue(label: "serialQueue")
    for element in elements {
      fetchUrl(of: element, inside: dispatchGroup) { (url) in
        guard let url = url else { return }
        serialQueue.sync { urlList.append(url) }
      }
    }
    dispatchGroup.wait()
    return urlList
  }
  
  func fetchUrls(_ assets: [PHAsset]) -> [URL] {
    let dispatchGroup = DispatchGroup()
    var urlList = [URL]()
    let serialQueue = DispatchQueue(label: "serialQueue")
    for asset in assets {
      fetchUrl(of: asset, inside: dispatchGroup) { (url) in
        guard let url = url else { return }
        serialQueue.sync { urlList.append(url) }
      }
    }
    dispatchGroup.wait()
    return urlList
  }
  
  func fetchUrl(image: UIImage) -> URL? {
    if #available(iOS 11.0, *), imageExportPreset == .current {
      return exportedHEICImageURL(image: image) ?? exportedJPEGImageURL(image: image)
    } else {
      return exportedJPEGImageURL(image: image)
    }
  }
}

private extension UrlExtractor {
  func fetchUrl(of element: Uploadable, inside dispatchGroup: DispatchGroup, completion: @escaping (URL?) -> Void) {
    dispatchGroup.enter()
    fetchUrl(of: element) { (url) in
      completion(url)
      dispatchGroup.leave()
    }
  }

  func fetchUrl(of asset: PHAsset, inside dispatchGroup: DispatchGroup, completion: @escaping (URL?) -> Void) {
    dispatchGroup.enter()
    fetchUrl(of: asset) { (url) in
      completion(url)
      dispatchGroup.leave()
    }
  }
  
  func fetchUrl(of element: Uploadable, completion: @escaping (URL?) -> Void) {
    if let image = element as? UIImage {
      completion(fetchUrl(image: image))
      return
    } else if let video = element as? AVAsset {
      fetchVideoUrl(of: video, completion: completion)
      return
    }
    completion(nil)
  }

  func fetchUrl(of asset: PHAsset, completion: @escaping (URL?) -> Void) {
    switch asset.mediaType {
    case .image: fetchImageUrl(of: asset, completion: completion)
    case .video: fetchVideoUrl(of: asset, completion: completion)
    case .unknown,
         .audio: completion(nil)
    }
  }
  
  func fetchVideoUrl(of asset: PHAsset, completion: @escaping (URL?) -> Void) {
    imageManager.requestAVAsset(forVideo: asset, options: videoRequestOptions) { (element, _, _) in
      guard let element = element else {
        completion(nil)
        return
      }
      self.fetchVideoUrl(of: element, completion: completion)
    }
  }
  
  func fetchVideoUrl(of asset: AVAsset, completion: @escaping (URL?) -> Void) {
    guard let export = self.videoExportSession(for: asset) else {
      completion(nil)
      return
    }
    export.exportAsynchronously { completion(export.outputURL) }
  }
  
  
  var videoRequestOptions: PHVideoRequestOptions {
    let options = PHVideoRequestOptions()
    options.version = PHVideoRequestOptionsVersion.current
    options.deliveryMode = PHVideoRequestOptionsDeliveryMode.highQualityFormat
    return options
  }
  
  func preferedVideoPreset(for asset: AVAsset) -> String {
    let compatibilePresets = AVAssetExportSession.exportPresets(compatibleWith: asset)
    if #available(iOS 11.0, *), compatibilePresets.contains(videoExportPreset) {
      return videoExportPreset
    }
    return AVAssetExportPresetPassthrough
  }
  
  func videoExportSession(for asset: AVAsset) -> AVAssetExportSession? {
    let export = AVAssetExportSession(asset: asset, presetName: preferedVideoPreset(for: asset))
    export?.outputURL = URL(fileURLWithPath: NSTemporaryDirectory() + UUID().uuidString + ".mov")
    export?.outputFileType = .mov
    return export
  }
  
  func fetchImageUrl(of asset: PHAsset, completion: @escaping (URL?) -> Void) {
    asset.fetchImage(forSize: PHImageManagerMaximumSize) { (image) in
      guard let image = image else {
        completion(nil)
        return
      }
      var exportedUrl: URL?
      if #available(iOS 11.0, *), self.imageExportPreset == .current {
        exportedUrl = self.exportedHEICImageURL(image: image) ?? self.exportedJPEGImageURL(image: image)
      } else {
        exportedUrl = self.exportedJPEGImageURL(image: image)
      }
      completion(exportedUrl)
    }
  }
  
  @available(iOS 11.0, *)
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
