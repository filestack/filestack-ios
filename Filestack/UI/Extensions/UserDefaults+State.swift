//
//  UserDefaults+State.swift
//  Filestack
//
//  Created by Ruben Nine on 11/17/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation

private extension String {
    static let cloudSourceViewType = "FSCloudSourceViewType"
}

extension UserDefaults {
    func cloudSourceViewType() -> CloudSourceViewType? {
        return CloudSourceViewType(rawValue: integer(forKey: .cloudSourceViewType))
    }

    func set(cloudSourceViewType: CloudSourceViewType) {
        setValue(cloudSourceViewType.rawValue, forKeyPath: .cloudSourceViewType)
    }
}
