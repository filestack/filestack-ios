//
//  AssetCell.swift
//  Filestack
//
//  Created by Mihály Papp on 04/06/2018.
//  Copyright © 2018 Filestack. All rights reserved.
//

import Photos

class AssetCell: UICollectionViewCell {
  @IBOutlet weak var image: UIImageView!
  @IBOutlet weak var selectedCheckbox: UIImageView!
  @IBOutlet weak var dimView: UIView!
  
  private var asset: PHAsset!
    
  func configure(for asset: PHAsset, isSelected: Bool) {
    self.asset = asset
    asset.fetchImage(forSize: image.frame.size) { image in
      DispatchQueue.main.async {
        self.configure(with: image)
        self.set(selected: isSelected)
      }
    }
  }
  
  func set(selected: Bool) {
    dimView.isHidden = !selected
    selectedCheckbox.isHidden = !selected
  }
}

private extension AssetCell {
  func configure(with image: UIImage?) {
    self.image.image = image
    selectedCheckbox.image = UIImage(named: "icon-selected", in: Bundle(for: type(of: self)), compatibleWith: nil)
  }
}
