//
//  AssetCollectionViewController.swift
//  Filestack
//
//  Created by Mihály Papp on 04/06/2018.
//  Copyright © 2018 Filestack. All rights reserved.
//

import UIKit
import Photos

protocol AssetSelectionDelegate {
  func add(asset: PHAsset)
  func remove(asset: PHAsset)
}

class AssetCollectionViewController: UICollectionViewController {
  
  var pickerController: PhotoPickerController!
  var elements: [PHAsset]?
  
  var selectedAssets: Set<PHAsset> {
    return pickerController.selectedAssets
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    setupView()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationItem.rightBarButtonItems = pickerController.rightBarItems
  }
  
  func configure(with album: Album) {
    self.title = album.title
    elements = album.elements
  }  
}

extension AssetCollectionViewController {
  func setupView() {
    view.backgroundColor = .white
  }
}

extension AssetCollectionViewController {
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return elements?.count ?? 0
  }
  
  override func collectionView(_ collectionView: UICollectionView,
                               cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AssetCell",
                                                        for: indexPath) as? AssetCell else {
                                                          return UICollectionViewCell()
    }
    let asset = elements![indexPath.row]
    let isSelected = selectedAssets.contains(asset)
    cell.configure(for: asset, isSelected: isSelected)
    return cell
  }
  
  override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let asset = elements![indexPath.row]
    let isSelecting = !selectedAssets.contains(asset)
    let cell = collectionView.cellForItem(at: indexPath) as! AssetCell
    if isSelecting && maximumReached {
      return
    }
    cell.set(selected: isSelecting)
    isSelecting ? pickerController.add(asset: asset) : pickerController.remove(asset: asset)
  }
}

extension AssetCollectionViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAt indexPath: IndexPath) -> CGSize {
    return cellSize
  }
}

private extension AssetCollectionViewController {
  var cellSize: CGSize {
    return CGSize(width: cellEdge, height: cellEdge)
  }
  
  var cellEdge: CGFloat {
    let totalWidth = view.frame.width
    let totalSpacing = cellSpacing * (columnsCount - 1)
    return (totalWidth - totalSpacing) / columnsCount
  }
  
  var columnsCount: CGFloat {
    let isPortrait = UIInterfaceOrientationIsPortrait(UIApplication.shared.statusBarOrientation)
    return isPortrait ? 4 : 7
  }
  
  var cellSpacing: CGFloat {
    return 2
  }
  
  var maximumReached: Bool {
    return pickerController.isMaximumLimitSet && selectedAssets.count >= pickerController.maximumSelectionCount
  }
}
