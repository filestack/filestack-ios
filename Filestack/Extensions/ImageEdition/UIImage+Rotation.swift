//
//  UIImage+Rotation.swift
//  EditImage
//
//  Created by Mihály Papp on 28/06/2018.
//  Copyright © 2018 Mihály Papp. All rights reserved.
//

import UIKit

// MARK: Rotation

extension UIImage {
    func rotated(clockwise: Bool) -> UIImage? {
        guard
            let imageRef = cgImage,
            let rotatedImage = rotateBy90Degrees(imageRef, clockwise: clockwise) else { return nil }
        return UIImage(cgImage: rotatedImage, scale: scale, orientation: .up)
    }

    func rotateBy90Degrees(_ imageRef: CGImage, clockwise: Bool) -> CGImage? {
        guard
            let colorSpace = imageRef.colorSpace,
            let context = CGContext(data: nil,
                                    width: imageRef.height,
                                    height: imageRef.width,
                                    bitsPerComponent: imageRef.bitsPerComponent,
                                    bytesPerRow: imageRef.bytesPerRow,
                                    space: colorSpace,
                                    bitmapInfo: imageRef.bitmapInfo.rawValue) else { return nil }
        context.rotateBy90Degrees(imageRef, clockwise: clockwise)
        return context.makeImage()
    }
}

extension CGContext {
    func rotateBy90Degrees(_ image: CGImage, clockwise: Bool) {
        let width = CGFloat(self.width)
        let height = CGFloat(self.height)
        let angle = clockwise ? -CGFloat.pi / 2 : CGFloat.pi / 2
        translateBy(x: width / 2, y: height / 2)
        rotate(by: angle)
        translateBy(x: -height / 2, y: -width / 2)
        draw(image, in: CGRect(x: 0, y: 0, width: height, height: width))
    }
}
