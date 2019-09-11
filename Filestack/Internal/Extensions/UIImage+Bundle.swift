//
//  UIImage+Bundle.swift
//  Filestack
//
//  Created by Mihály Papp on 30/07/2018.
//  Copyright © 2018 Filestack. All rights reserved.
//

import UIKit

extension UIImage {
    static func fromFilestackBundle(_ name: String) -> UIImage {
        return UIImage(named: name, in: Bundle(for: Client.self), compatibleWith: nil) ?? UIImage()
    }

    static func templatedFilestackImage(_ name: String) -> UIImage {
        return fromFilestackBundle(name).withRenderingMode(.alwaysTemplate)
    }
}
