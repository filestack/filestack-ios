//
//  AlbumListCell.swift
//  Filestack
//
//  Created by Mihály Papp on 23/05/2018.
//  Copyright © 2018 Filestack. All rights reserved.
//

import Photos
import UIKit

class AlbumCell: UITableViewCell {
    @IBOutlet var coverImage: UIImageView!
    @IBOutlet var titleLabel: UILabel!

    private var requestIDs: [PHImageRequestID] = []

    func configure(for album: Album) {
        selectionStyle = .none
        titleLabel.text = album.title
        coverImage.contentMode = .scaleAspectFill
        coverImage.clipsToBounds = true

        let requestID = album.elements.last?.fetchImage(forSize: coverImage.frame.size) { image, requestID in
            self.requestIDs.removeAll { $0 == requestID }

            DispatchQueue.main.async { self.coverImage.image = image }
        }

        if let requestID = requestID {
            requestIDs.append(requestID)
        }
    }

    deinit {
        for requestID in requestIDs {
            PHImageManager.default().cancelImageRequest(requestID)
        }

        requestIDs.removeAll()
    }
}
