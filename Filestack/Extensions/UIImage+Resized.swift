//
//  UIImage+Resized.swift
//  Filestack
//
//  Created by Ruben Nine on 7/11/19.
//  Copyright © 2019 Filestack. All rights reserved.
//

import UIKit

extension UIImage {
    func resized(for size: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: size)

        return renderer.image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
