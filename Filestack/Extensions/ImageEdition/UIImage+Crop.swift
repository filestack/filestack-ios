//
//  UIImage+Crop.swift
//  EditImage
//
//  Created by Mihály Papp on 28/06/2018.
//  Copyright © 2018 Mihály Papp. All rights reserved.
//

import UIKit

// MARK: Crop
extension UIImage {
  func cropped(by insets: UIEdgeInsets) -> UIImage? {
    guard let imageRef = cgImage else { return nil }
    let intersection = UIEdgeInsetsInsetRect(cgRect, insets)
    let scaledRect = intersection.scaled(by: scale)
    guard let croppedImage = imageRef.cropping(to: scaledRect) else { return nil }
    return UIImage(cgImage: croppedImage, scale: scale, orientation: .up)
  }
  
  func cropped(to rect: CGRect) -> UIImage? {
    guard let imageRef = cgImage else { return nil }
    let intersection = cgRect.intersection(rect)
    let scaledRect = intersection.scaled(by: scale)
    guard let croppedImage = imageRef.cropping(to: scaledRect) else { return nil }
    return UIImage(cgImage: croppedImage, scale: scale, orientation: .up)
  }
}
