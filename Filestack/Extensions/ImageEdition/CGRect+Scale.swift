//
//  CGRect+Scale.swift
//  EditImage
//
//  Created by Mihály Papp on 02/07/2018.
//  Copyright © 2018 Mihály Papp. All rights reserved.
//

import UIKit

extension CGRect {
    func scaled(by scale: CGFloat) -> CGRect {
        return applying(CGAffineTransform(scaleX: scale, y: scale))
    }
}

extension CGPoint {
    func movedBy(x: CGFloat = 0, y: CGFloat = 0) -> CGPoint {
        return applying(CGAffineTransform(translationX: x, y: y))
    }
}
