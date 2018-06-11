//
//  AlbumListCell.swift
//  Filestack
//
//  Created by Mihály Papp on 23/05/2018.
//  Copyright © 2018 Filestack. All rights reserved.
//

import Foundation

class AlbumCell: UITableViewCell {
  @IBOutlet weak var coverImage: UIImageView!
  @IBOutlet weak var titleLabel: UILabel!
  
  func configure(for album: Album) {
    selectionStyle = .none
    titleLabel.text = album.title
    coverImage.contentMode = .scaleAspectFill
    coverImage.clipsToBounds = true
    album.elements.last?.fetchImage(forSize: coverImage.frame.size) { image in
      DispatchQueue.main.async { self.coverImage.image = image }
    }
  }
}
