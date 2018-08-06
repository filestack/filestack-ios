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
  
  private lazy var urlExtractor: UrlExtractor = {
    var imagePreset = ImageURLExportPreset.compatible
    var videoPreset: String = AVAssetExportPresetPassthrough
    if #available(iOS 11.0, *) {
      imagePreset = config.imageURLExportPreset
      videoPreset = config.videoExportPreset
    }
    return UrlExtractor(imageExportPreset: imagePreset,
                        videoExportPreset: videoPreset,
                        cameraImageQuality: config.imageExportQuality)
  }()
  private lazy var uploadableExtractor = UploadableExtractor()
  
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
    if config.showEditorBeforeUpload {
      showEditor(with: assets, on: controller)
    } else {
      
      upload(assets: assets)
    }
  }
  
  func upload(assets: [PHAsset]) {
    viewController.dismiss(animated: true) {
      let urlList = self.urlExtractor.fetchUrls(assets)
      self.multifileUpload.uploadURLs.append(contentsOf: urlList)
      self.multifileUpload.uploadFiles()
    }
  }
  
  func showEditor(with assets: [PHAsset], on navigationController: UINavigationController) {
    let elements = UploadableExtractor().fetch(from: assets)
    let editor = SelectionListViewController(elements: elements, delegate: self)
    navigationController.pushViewController(editor, animated: true)
  }
}

extension ImagePickerUploadController: UploadListDelegate {
  func resignFromUpload() {
    multifileUpload.cancel()
    filePickedCompletionHandler?(false)
  }
  
  func upload(_ elements: [Uploadable]) {
    viewController.dismiss(animated: true) {
      self.multifileUpload.uploadURLs = self.urlExtractor.fetchUrls(elements)
      self.multifileUpload.uploadFiles()
    }
  }
}

extension ImagePickerUploadController: UIImagePickerControllerDelegate {
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    picker.dismiss(animated: true) {
      self.cancelUpload()
    }
  }
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    picker.dismiss(animated: true) { [unowned self] in
      self.upload(with: info)
    }
  }
  
  private func upload(with info: [String : Any]) {
    if let imageURL = info[PickerKeys.cameraUrl] as? URL {
      upload(url: imageURL)
    } else if let mediaURL = info[PickerKeys.cameraMediaUrl] as? URL {
      upload(url: mediaURL)
    } else if let image = info[PickerKeys.pickerImage] as? UIImage, let url = self.urlExtractor.fetchUrl(image: image) {
      upload(url: url)
    } else {
      cancelUpload()
    }
  }
  
  private func upload(url: URL) {
    multifileUpload.uploadURLs = [url]
    multifileUpload.uploadFiles()
    filePickedCompletionHandler?(true)
  }
  
  private func cancelUpload() {
    multifileUpload.cancel()
    filePickedCompletionHandler?(true)
  }
  private struct PickerKeys {
    static let cameraUrl = "UIImagePickerControllerImageURL"
    static let cameraMediaUrl = "UIImagePickerControllerMediaURL"
    static let pickerImage = "UIImagePickerControllerOriginalImage"
  }
}

extension ImagePickerUploadController: UINavigationControllerDelegate {}
