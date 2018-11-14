//
//  UIImage+write.swift
//  Filestack
//
//  Created by Mihály Papp on 31/07/2018.
//  Copyright © 2018 Filestack. All rights reserved.
//

import Foundation

extension UIImage {
  func with(written text: String, atPoint point: CGPoint) -> UIImage {
    let textSize = min(size.height, size.width)/20
    let textColor = UIColor.white
    let textFont = UIFont(name: "Helvetica Bold", size: textSize)!
    
    UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
    
    let textFontAttributes: [NSAttributedString.Key : Any] = [.font: textFont, .foregroundColor: textColor]
    draw(in: CGRect(origin: CGPoint.zero, size: size))
    
    let rect = CGRect(origin: point, size: size)
    text.draw(in: rect, withAttributes: textFontAttributes)
    
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return newImage ?? self
  }

}
