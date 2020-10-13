//
//  CellDescriptibleSource.swift
//  Filestack
//
//  Created by Ruben Nine on 11/7/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import UIKit

protocol CellDescriptibleSource {
    var iconImage: UIImage { get }
    var textDescription: String { get }
}

func == (lhs: CellDescriptibleSource, rhs: CellDescriptibleSource) -> Bool {
    return lhs.textDescription == rhs.textDescription
}
