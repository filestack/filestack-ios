//
//  SelectionListViewController+UICollectionView.swift
//  EditImage
//
//  Created by Mihály Papp on 26/07/2018.
//  Copyright © 2018 Mihály Papp. All rights reserved.
//

import UIKit

extension SelectionListViewController {
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return numberOfCells
  }
  
//  override func collectionView(_ collectionView: UICollectionView,
//                               willDisplay cell: UICollectionViewCell,
//                               forItemAt indexPath: IndexPath) {
//    guard let cell = collectionView.reuse(SelectionCell.self, for: indexPath) else { return }
//  }
  
  override func collectionView(_ collectionView: UICollectionView,
                               cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.reuse(SelectionCell.self, for: indexPath) else { return UICollectionViewCell() }
    cellWasDisplayed(cell, on: indexPath.row)
    return cell
  }
  
  override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    cellWasPressed(on: indexPath.row)
  }  
}

// MARK: LongPress handling
extension SelectionListViewController {
  override func collectionView(_ collectionView: UICollectionView,
                               shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
    cellWasLongPressed(on: indexPath.row)
    return true
  }
  
  override func collectionView(_ collectionView: UICollectionView,
                               canPerformAction action: Selector,
                               forItemAt indexPath: IndexPath,
                               withSender sender: Any?) -> Bool {
    return false
  }
  
  override func collectionView(_ collectionView: UICollectionView,
                               performAction action: Selector,
                               forItemAt indexPath: IndexPath,
                               withSender sender: Any?) {
    return
  }
}
