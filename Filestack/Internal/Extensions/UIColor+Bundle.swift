//
//  UIColor+Bundle.swift
//  Filestack
//
//  Created by Ruben Nine on 17/09/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import UIKit

extension UIColor {
    static func fromFilestackBundle(_ name: String) -> UIColor? {
        return UIColor(named: name, in: Bundle(for: Client.self), compatibleWith: nil)
    }
}
