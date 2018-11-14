//
//  SelectionListViewController+FlowLayout.swift
//  EditImage
//
//  Created by Mihály Papp on 24/07/2018.
//  Copyright © 2018 Mihály Papp. All rights reserved.
//

import UIKit

extension SelectionListViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      insetForSectionAt section: Int) -> UIEdgeInsets {
    return UIEdgeInsets(top: cellSpacing, left: cellSpacing, bottom: cellSpacing, right: cellSpacing)
  }

  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      sizeForItemAt indexPath: IndexPath) -> CGSize {
    return cellSize
  }
  
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return cellSpacing
  }
  
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return cellSpacing
  }
}

private extension SelectionListViewController {
  
  var cellSize: CGSize {
    return CGSize(width: cellEdge, height: cellEdge)
  }
  
  private var cellEdge: CGFloat {
    let totalWidth = view.frame.width
    let totalSpacing = cellSpacing * (columnsCount + 1)
    return (totalWidth - totalSpacing) / columnsCount
  }
  
  private var columnsCount: CGFloat {
    let isPortrait = UIApplication.shared.statusBarOrientation.isPortrait
    return isPortrait ? 3 : 5
  }
  
  var cellSpacing: CGFloat {
    return 6
  }
}
