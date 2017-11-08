//
//  CellDescriptibleSource.swift
//  Filestack
//
//  Created by Ruben Nine on 11/7/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation


internal protocol CellDescriptibleSource {

    var iconName: String { get }
    var description: String { get }
}

func ==(lhs: CellDescriptibleSource, rhs: CellDescriptibleSource) -> Bool {
    return lhs.description == rhs.description
}
