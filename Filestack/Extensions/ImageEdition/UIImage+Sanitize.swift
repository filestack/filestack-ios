//
//  ImageEditor+Sanitize.swift
//  EditImage
//
//  Created by Mihály Papp on 28/06/2018.
//  Copyright © 2018 Mihály Papp. All rights reserved.
//

import UIKit

// MARK: Sanitize
extension UIImage {
  var sanitized: UIImage? {
    guard
      let imageRef = cgImage,
      let colorSpace = imageRef.colorSpace,
      let context = CGContext(data: nil,
                              width: imageRef.width,
                              height: imageRef.height,
                              bitsPerComponent: imageRef.bitsPerComponent,
                              bytesPerRow: imageRef.bytesPerRow,
                              space: colorSpace,
                              bitmapInfo: imageRef.bitmapInfo.rawValue) else { return nil }
    context.draw(imageRef, in: CGRect(x: 0, y: 0, width: CGFloat(imageRef.width), height: CGFloat(imageRef.height)))
    guard let sanitizedRef = context.makeImage() else { return nil }
    return UIImage(cgImage: sanitizedRef, scale: scale, orientation: .up)
  }
}
