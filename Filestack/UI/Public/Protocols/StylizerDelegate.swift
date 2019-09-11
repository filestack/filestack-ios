//
//  StylizerDelegate.swift
//  Filestack
//
//  Created by Ruben Nine on 11/09/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import Foundation

/// :nodoc:
@objc(FSStylizerDelegate) public protocol StylizerDelegate: AnyObject {
    @objc func updateStyle()
}
