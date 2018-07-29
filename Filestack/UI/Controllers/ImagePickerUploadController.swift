//
//  ImagePickerUploadController.swift
//  Filestack
//
//  Created by Ruben Nine on 10/23/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation
import FilestackSDK
import AVFoundation.AVAssetExportSession
import Photos


internal class ImagePickerUploadController: NSObject {
  
  let multifileUpload: MultifileUpload
  let viewController: UIViewController
  let picker: UIImagePickerController
  let sourceType: UIImagePickerControllerSourceType
  let config: Config
  
  var filePickedCompletionHandler: ((_ success: Bool) -> Swift.Void)? = nil
  
  let imageManager = PHCachingImageManager.default()
  
  init(multifileUpload: MultifileUpload,
       viewController: UIViewController,
       sourceType: UIImagePickerControllerSourceType,
       config: Config) {
    self.multifileUpload = multifileUpload
    self.viewController = viewController
    self.sourceType = sourceType
    self.picker = UIImagePickerController()
    self.config = config
  }
  
  
  func start() {
    if config.maximumSelectionAllowed == 1 {
      showNativePicker()
    }
    showCustomPicker()
  }
  
  func showNativePicker() {
    picker.delegate = self
    picker.modalPresentationStyle = config.modalPresentationStyle
    picker.sourceType = sourceType
    picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: sourceType)!
    if #available(iOS 11.0, *) {
      picker.imageExportPreset = config.imageURLExportPreset.asImagePickerControllerImageURLExportPreset
      picker.videoExportPreset = config.videoExportPreset
    }
    picker.videoQuality = config.videoQuality
    
    viewController.present(picker, animated: true, completion: nil)
  }
  
  func showCustomPicker() {
    let picker = PhotoPickerController(maximumSelection: config.maximumSelectionAllowed)
    picker.delegate = self
    let navigation = picker.navigation
    navigation.modalPresentationStyle = config.modalPresentationStyle
    viewController.present(navigation, animated: true, completion: nil)
  }
}

extension ImagePickerUploadController: PhotoPickerControllerDelegate {
  func photoPickerControllerDidCancel() {
    multifileUpload.cancel()
    filePickedCompletionHandler?(false)
  }
  
  func photoPicker(_ controller: UINavigationController, didSelectAssets assets: [PHAsset]) {
    controller.pushViewController(uploadListController(with: assets), animated: true)
//    multifileUpload.uploadURLs.append(contentsOf: urlList)
//    multifileUpload.uploadFiles()
  }
  
  func uploadListController(with assets: [PHAsset]) -> UIViewController {
    let urlList = fetchUrl(assets: assets)
    let images = urlList.compactMap { UIImage(data: try! Data(contentsOf: $0)) }
    return SelectionListViewController(images: images, delegate: self)
  }
  
  func fetchUrl(assets: [PHAsset]) -> [URL] {
    let dispatchGroup = DispatchGroup()
    var urlList = [URL]()
    for asset in assets {
      fetchUrl(of: asset, inside: dispatchGroup) { (url) in
        guard let url = url else {  return }
        urlList.append(url)
      }
    }
    dispatchGroup.wait()
    return urlList
  }
  
  func fetchUrl(of asset: PHAsset, inside dispatchGroup: DispatchGroup, completion: @escaping (URL?) -> Void) {
    dispatchGroup.enter()
    fetchUrl(of: asset) { (url) in
      completion(url)
      dispatchGroup.leave()
    }
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
      guard let element = element, let export = self.videoExportSession(for: element) else {
        completion(nil)
        return
      }
      export.exportAsynchronously { completion(export.outputURL) }
    }
  }
  
  var videoRequestOptions: PHVideoRequestOptions {
    let options = PHVideoRequestOptions()
    options.version = PHVideoRequestOptionsVersion.current
    options.deliveryMode = PHVideoRequestOptionsDeliveryMode.highQualityFormat
    return options
  }
  
  func preferedVideoPreset(for asset: AVAsset) -> String {
    let compatibilePresets = AVAssetExportSession.exportPresets(compatibleWith: asset)
    if #available(iOS 11.0, *), compatibilePresets.contains(self.config.videoExportPreset) {
      return config.videoExportPreset
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
      if #available(iOS 11.0, *), self.config.imageURLExportPreset == .current {
        exportedUrl = self.exportedHEICImageURL(image: image) ?? self.exportedJPEGImageURL(image: image)
      } else {
        exportedUrl = self.exportedJPEGImageURL(image: image)
      }
      completion(exportedUrl)
    }
  }
}

extension ImagePickerUploadController: UploadListDelegate {
  func resignFromUpload() {
    multifileUpload.cancel()
    filePickedCompletionHandler?(false)
  }
  
  func uploadImages(_ images: [UIImage]) {
    multifileUpload.uploadURLs.append(contentsOf: images.compactMap { exportedUrl(from: $0) })
    multifileUpload.uploadFiles()
  }
}

extension ImagePickerUploadController: UIImagePickerControllerDelegate {
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    picker.dismiss(animated: true) {
      self.multifileUpload.cancel()
      self.filePickedCompletionHandler?(false)
    }
  }
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    
    picker.dismiss(animated: true) {
      if let imageURL = info["UIImagePickerControllerImageURL"] as? URL {
        // Upload image from camera roll
        self.multifileUpload.uploadURLs = [imageURL]
        self.multifileUpload.uploadFiles()
      } else if let mediaURL = info["UIImagePickerControllerMediaURL"] as? URL {
        // Upload media (typically video) from camera roll
        self.multifileUpload.uploadURLs = [mediaURL]
        self.multifileUpload.uploadFiles()
      } else if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage {
        if let url = self.exportedUrl(from: image) {
          self.multifileUpload.uploadURLs.append(url)
          self.multifileUpload.uploadFiles()
        } else {
          self.multifileUpload.cancel()
        }
      }
      self.filePickedCompletionHandler?(true)
    }
  }
  
  private func exportedUrl(from image: UIImage) -> URL? {
    if #available(iOS 11.0, *), picker.imageExportPreset == .current {
      return exportedHEICImageURL(image: image) ?? exportedJPEGImageURL(image: image)
    } else {
      return exportedJPEGImageURL(image: image)
    }
  }
  
  // MARK: - Private Functions
  
  @available(iOS 11.0, *)
  private func exportedHEICImageURL(image: UIImage) -> URL? {
    
    // Save picture as a temporary HEIC file
    if let imageData = image.heicRepresentation(quality: config.imageExportQuality) {
      let filename = UUID().uuidString + ".heic"
      return writeImageDataToURL(imageData: imageData, filename: filename)
    }
    
    return nil
  }
  
  private func exportedJPEGImageURL(image: UIImage) -> URL? {
    
    // Save picture as a temporary JPEG file
    if let imageData = UIImageJPEGRepresentation(image, CGFloat(config.imageExportQuality)) {
      let filename = UUID().uuidString + ".jpeg"
      return writeImageDataToURL(imageData: imageData, filename: filename)
    }
    
    return nil
  }
  
  private func writeImageDataToURL(imageData: Data, filename: String) -> URL? {
    
    do {
      let tmpURL = URL(fileURLWithPath: NSTemporaryDirectory() + filename)
      try imageData.write(to: tmpURL)
      
      return tmpURL
    } catch {
      // NO-OP
      return nil
    }
  }
}

extension ImagePickerUploadController: UINavigationControllerDelegate {
  
}
