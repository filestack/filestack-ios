//
//  AssetCell.swift
//  Filestack
//
//  Created by Mihály Papp on 04/06/2018.
//  Copyright © 2018 Filestack. All rights reserved.
//

import Photos

class AssetCell: UICollectionViewCell {
    @IBOutlet var image: UIImageView!
    @IBOutlet var selectedCheckbox: UIImageView!
    @IBOutlet var dimView: UIView!
    @IBOutlet var additionalInfoLabel: UILabel!
    private lazy var gradientLayer = CAGradientLayer()

    private var asset: PHAsset!
    private var requestIDs: [PHImageRequestID] = []
    private let uploadableExtractor = UploadableExtractor()

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = image.frame
    }

    func configure(for asset: PHAsset, isSelected: Bool) {
        self.asset = asset

        requestIDs.append(asset.fetchImage(forSize: image.frame.size) { image, requestID in
            self.requestIDs.removeAll { $0 == requestID }

            DispatchQueue.main.async {
                self.configure(with: image)
                self.set(selected: isSelected)
            }
        })

        if asset.mediaType == .video {
            if let requestID = (uploadableExtractor.fetchUploadable(using: asset) { uploadable, requestID in
                self.requestIDs.removeAll { $0 == requestID }

                DispatchQueue.main.async {
                    self.additionalInfoLabel.text = uploadable?.additionalInfo
                    self.setupGradientLayer()
                }
            }) {
                requestIDs.append(requestID)
            }
        }
    }

    deinit {
        for requestID in requestIDs {
            uploadableExtractor.cancelFetch(using: requestID)
        }

        requestIDs.removeAll()
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

    func setupGradientLayer() {
        image.layer.insertSublayer(gradientLayer, at: 0)
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.clear.cgColor, UIColor(white: 0.55, alpha: 0.6).cgColor]
        gradientLayer.locations = [NSNumber(value: 0), NSNumber(value: 0.6), NSNumber(value: 1)]
        gradientLayer.startPoint = CGPoint(x: 1, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0, y: 1)
        gradientLayer.frame = image.frame
    }
}
