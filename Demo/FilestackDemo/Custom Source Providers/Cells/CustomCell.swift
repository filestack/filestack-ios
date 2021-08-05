//
//  CustomCell.swift
//  CustomCell
//
//  Created by Ruben Nine on 5/8/21.
//  Copyright © 2021 Filestack. All rights reserved.
//

import UIKit

class CustomCell: UICollectionViewCell {
    let imageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CustomCell {
    func setupView() {
        selectedBackgroundView = UIView()
        selectedBackgroundView?.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.33)
        selectedBackgroundView?.layer.cornerRadius = 9
        selectedBackgroundView?.clipsToBounds = true
        selectedBackgroundView?.layer.borderColor = UIColor.white.cgColor
        selectedBackgroundView?.layer.borderWidth = 2

        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 9
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true

        let backgroundView = UIView()
        backgroundView.addSubview(imageView)

        imageView.topAnchor.constraint(equalTo: backgroundView.topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor).isActive = true

        self.backgroundView = backgroundView
    }
}
