//
//  Array+SafeIndex.swift
//  Filestack
//
//  Created by Ruben Nine on 11/13/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation

extension Array {
    //  Originally written by Erica Sadun, and Mike Ash
    //  Source: http://ericasadun.com/2015/06/01/swift-safe-array-indexing-my-favorite-thing-of-the-new-week/
    subscript(safe index: UInt) -> Element? {
        return Int(index) < count ? self[Int(index)] : nil
    }
}
