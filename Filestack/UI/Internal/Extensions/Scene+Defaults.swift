//
//  Scene+Defaults.swift
//  Filestack
//
//  Created by Ruben Nine on 11/13/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation

extension Scene {
    var identifier: String {
        return String(describing: ViewController.self)
    }
}
