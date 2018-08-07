//
//  UICollectionView+Reusable.swift
//  EditImage
//
//  Created by Mihály Papp on 26/07/2018.
//  Copyright © 2018 Mihály Papp. All rights reserved.
//

import UIKit

private extension UICollectionViewCell {
  class var reuseIdentifier: String {
    return String(describing: self)
  }
}

extension UICollectionView {
  func register<Cell: UICollectionViewCell>(_ cell: Cell.Type) {
    register(cell, forCellWithReuseIdentifier: cell.reuseIdentifier)
  }
  
  func reuse<Cell: UICollectionViewCell>(_ cell: Cell.Type, for indexPath: IndexPath) -> Cell? {
    let reusable = dequeueReusableCell(withReuseIdentifier: cell.reuseIdentifier, for: indexPath)
    return reusable as? Cell
  }  
}
