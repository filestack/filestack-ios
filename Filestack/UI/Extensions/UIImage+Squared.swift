//
//  UIImage+Squared.swift
//  Filestack
//
//  Created by Ruben Nine on 11/14/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import UIKit

extension UIImage {
    var isPortrait: Bool { return size.height > size.width }
    var isLandscape: Bool { return size.width > size.height }
    var breadth: CGFloat { return min(size.width, size.height) }
    var breadthSize: CGSize { return CGSize(width: breadth, height: breadth) }
    var breadthRect: CGRect { return CGRect(origin: .zero, size: breadthSize) }

    var squared: UIImage? {
        if size.width == size.height {
            // Already square. Return self
            return self
        }

        UIGraphicsBeginImageContextWithOptions(breadthSize, false, scale)
        defer { UIGraphicsEndImageContext() }

        let cropX = isLandscape ? floor((size.width - size.height) / 2) : 0
        let cropY = isPortrait ? floor((size.height - size.width) / 2) : 0
        let cropRect = CGRect(origin: CGPoint(x: cropX, y: cropY), size: breadthSize)

        guard let cgImage = cgImage?.cropping(to: cropRect) else { return nil }

        UIImage(cgImage: cgImage).draw(in: breadthRect)

        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
