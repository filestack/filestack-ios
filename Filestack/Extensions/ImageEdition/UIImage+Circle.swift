//
//  UIImage+Circle.swift
//  EditImage
//
//  Created by Mihály Papp on 29/06/2018.
//  Copyright © 2018 Mihály Papp. All rights reserved.
//

import UIKit

// MARK: Circle

extension UIImage {
    func circled(center: CGPoint, radius: CGFloat) -> UIImage? {
        let origin = CGPoint(x: (center.x - radius).rounded(), y: (center.y - radius).rounded())
        let rect = CGRect(origin: origin, size: CGSize(width: radius * 2, height: radius * 2))
        return circled(to: rect)
    }

    func circled(to rect: CGRect) -> UIImage? {
        let scaledRect = rect.scaled(by: scale)
        UIGraphicsBeginImageContextWithOptions(scaledRect.size, false, 1)
        guard let imageRef = cgImage?.cropping(to: scaledRect) else { return nil }
        let translatedRect = CGRect(origin: .zero, size: scaledRect.size)
        UIBezierPath(ovalIn: translatedRect).addClip()
        UIImage(cgImage: imageRef, scale: 1, orientation: imageOrientation).draw(in: translatedRect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        let newImage = UIImage(cgImage: image!.cgImage!, scale: scale, orientation: imageOrientation)
        return newImage
    }
}
