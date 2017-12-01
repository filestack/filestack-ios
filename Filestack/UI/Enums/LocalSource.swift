//
//  LocalSource.swift
//  Filestack
//
//  Created by Ruben Nine on 11/7/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation


/**
    Represents a type of local source to be used in the picker.
 */
@objc(FSLocalSource) public enum LocalSource: UInt {

    /// Camera
    case camera

    /// Photo Library
    case photoLibrary

    /// Documents
    case documents
}

extension LocalSource: CustomStringConvertible, CellDescriptibleSource {

    /// Returns all the supported sources.
    public static func all() -> [LocalSource] {

        return [.camera, .photoLibrary, .documents]
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

        case .documents:

            return "icon-documents"

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

        case .documents:

            return "iOS Files"

        }
    }
}
