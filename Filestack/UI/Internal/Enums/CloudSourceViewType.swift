//
//  CloudSourceViewType.swift
//  Filestack
//
//  Created by Ruben Nine on 11/17/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation

enum CloudSourceViewType: Int {
    case list = 0
    case grid = 1
}

extension CloudSourceViewType {
    var iconName: String {
        switch self {
        case .list:
            return "icon-list"
        case .grid:
            return "icon-grid"
        }
    }

    func toggle() -> CloudSourceViewType {
        switch self {
        case .list:
            return .grid
        case .grid:
            return .list
        }
    }
}
