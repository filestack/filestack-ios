//
//  LocalSource.swift
//  Filestack
//
//  Created by Ruben Nine on 11/7/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation


/**
    Represents a type of local source to be used in the interactive uploader.
 */
@objc(FSLocalSource) public enum LocalSource: UInt {

    /// Camera
    case camera

    /// Photo Library
    case photoLibrary
}

extension LocalSource: CustomStringConvertible, CellDescriptibleSource {

    /// Returns all the supported sources.
    public static func all() -> [LocalSource] {

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


    // MARK: - CustomStringConvertible

    /// Returns a `String` representation of self.
    public var description: String {

        switch self {
        case .camera:

            return "Camera"

        case .photoLibrary:

            return "Photo Library"

        }
    }
}
