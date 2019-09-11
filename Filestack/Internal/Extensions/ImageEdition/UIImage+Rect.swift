//
//  UIImage+Rect.swift
//  EditImage
//
//  Created by Mihály Papp on 02/07/2018.
//  Copyright © 2018 Mihály Papp. All rights reserved.
//

import UIKit

extension UIImage {
    var cgRect: CGRect {
        return CGRect(origin: .zero, size: size)
    }
}
