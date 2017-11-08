//
//  LocalSource.swift
//  Filestack
//
//  Created by Ruben Nine on 11/7/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation


internal enum LocalSource: CustomStringConvertible, CellDescriptibleSource {

    case camera
    case photoLibrary

    static func all() -> [LocalSource] {

        return [.camera, .photoLibrary]
    }

    static func title() -> String {

        return "Local"
    }

    var iconName: String {

        switch self {
        case .camera:

            return "icon-camera"

        case .photoLibrary:

            return "icon-photolibrary"

        }
    }

    var description: String {

        switch self {
        case .camera:

            return "Camera"

        case .photoLibrary:

            return "Photo Library"

        }
    }
}
