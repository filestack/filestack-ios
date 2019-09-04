//
//  LocalSource.swift
//  Filestack
//
//  Created by Ruben Nine on 11/7/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation

/// :nodoc:
@objc(FSLocalProvider) public enum LocalProvider: UInt {
    /// Camera
    case camera

    /// Photo Library
    case photoLibrary

    /// Documents
    case documents
}

/**
 Represents a type of local source to be used in the picker.
 */
@objc(FSLocalSource) public class LocalSource: NSObject, CellDescriptibleSource {
    let provider: LocalProvider
    let iconImage: UIImage
    let textDescription: String

    @objc public init(description: String, image: UIImage, provider: LocalProvider) {
        self.textDescription = description
        self.iconImage = image
        self.provider = provider
    }

    /// Camera
    @objc public static var camera = LocalSource(description: "Camera",
                                                 image: .templatedFilestackImage("icon-camera"),
                                                 provider: .camera)

    /// Photo Library
    @objc public static var photoLibrary = LocalSource(description: "Photo Library",
                                                       image: .templatedFilestackImage("icon-photolibrary"),
                                                       provider: .photoLibrary)

    /// Documents
    @objc public static var documents = LocalSource(description: "iOS Files",
                                                    image: .templatedFilestackImage("icon-documents"),
                                                    provider: .documents)

    /// Returns all the supported sources.
    @objc public static func all() -> [LocalSource] {
        return [.camera, .photoLibrary, .documents]
    }

    static func title() -> String {
        return "Local"
    }
}
