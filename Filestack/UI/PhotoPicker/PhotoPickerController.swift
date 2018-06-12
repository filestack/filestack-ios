//
//  PhotoPickerController.swift
//  Filestack
//
//  Created by Mihály Papp on 23/05/2018.
//  Copyright © 2018 Filestack. All rights reserved.
//

import Photos

protocol PhotoPickerControllerDelegate: class {
  func photoPickerControllerDidCancel()
  func photoPickerControllerFinish(with assets: [PHAsset])
}

class PhotoPickerController {
  
  let albumRepository = PhotoAlbumRepository()
  var selectedAssets = Set<PHAsset>()
  
  let maximumSelectionAllowed: UInt
  var isMaximumLimitSet: Bool {
    return maximumSelectionAllowed != Config.kMaximumSelectionNoLimit
  }
  
  weak var delegate: PhotoPickerControllerDelegate?
  
  init(maximumSelection: UInt) {
    self.maximumSelectionAllowed = maximumSelection
    albumRepository.getAlbums() { _ in }
  }
  
  var assetCollection: AssetCollectionViewController {
    let vc = viewController(with: "AssetCollectionViewController")
    guard let assetCollection = vc as? AssetCollectionViewController else {
      fatalError("AssetCollectionViewController type is corrupted")
    }
    assetCollection.pickerController = self
    return assetCollection
  }
  
  lazy var albumList: AlbumListViewController = {
    let vc = viewController(with: "AlbumListViewController")
    guard let albumList = vc as? AlbumListViewController else {
      fatalError("AlbumListViewController type is corrupted")
    }
    albumList.pickerController = self
    return albumList
  }()
  
  lazy var navigation: UINavigationController = {
    return UINavigationController(rootViewController: albumList)
  }()
  
  var cancelBarButton: UIBarButtonItem {
    return UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismissWithoutSelection))
  }
  
  var rightBarItems: [UIBarButtonItem] {
    if selectedAssets.count == 0 {
      return []
    }
    return [selectionCountBarButton, doneBarButton]
  }
  
  var doneBarButton: UIBarButtonItem {
    return UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissWithSelection))
  }

  var selectionCountBarButton: UIBarButtonItem {
    let maximum = isMaximumLimitSet ? "/\(maximumSelectionAllowed)" : ""
    let title = "(\(selectedAssets.count)\(maximum))"
    return UIBarButtonItem(title: title, style: .done, target: self, action: #selector(dismissWithSelection))
  }
  
  @objc func dismissWithSelection() {
    delegate?.photoPickerControllerFinish(with: Array(selectedAssets))
    navigation.dismiss(animated: true, completion: nil)
  }

  @objc func dismissWithoutSelection() {
    delegate?.photoPickerControllerDidCancel()
    navigation.dismiss(animated: true, completion: nil)
  }
}

private extension PhotoPickerController {
  func viewController(with name: String) -> UIViewController {
    let storyboard = UIStoryboard(name: "PhotoPicker", bundle: Bundle(for: type(of: self)))
    return storyboard.instantiateViewController(withIdentifier: name)
  }
  
}

extension PhotoPickerController: AssetSelectionDelegate {
  func add(asset: PHAsset) {
    selectedAssets.insert(asset)
    updateNavBar()
  }
  
  func remove(asset: PHAsset) {
    selectedAssets.remove(asset)
    updateNavBar()
  }
  
  func updateNavBar() {
    navigation.viewControllers.forEach { $0.navigationItem.rightBarButtonItems = self.rightBarItems }
  }
}
