//
//  LocalSource.swift
//  Filestack
//
//  Created by Ruben Nine on 11/7/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import UIKit
import FilestackSDK

/// Represents a type of local source to be used in the picker.
@objc(FSLocalSource) public class LocalSource: NSObject, CellDescriptibleSource {
    let provider: LocalProvider
    let iconImage: UIImage
    let textDescription: String
    let sourceProvider: SourceProvider?

    /// Initializer for a `LocalSource` accepting a `LocalProvider`.
    ///
    /// - Parameter description: A `String` describing the local source.
    /// - Parameter image: An `UIImage` visually describing the local source.
    /// - Parameter provider: A `LocalProvider` that better represents the local source.
    @objc public init(description: String, image: UIImage, provider: LocalProvider) {
        self.textDescription = description
        self.iconImage = image
        self.provider = provider
        self.sourceProvider = nil
    }

    /// Initializer for a `LocalSource` accepting a `SourceProvider`.
    ///
    /// - Parameter description: A `String` describing the local source.
    /// - Parameter image: An `UIImage` visually describing the local source.
    /// - Parameter sourceProvider: A `SourceProvider` that presents a custom user-provided view controller.
    public init(description: String, image: UIImage, sourceProvider: SourceProvider) {
        self.textDescription = description
        self.iconImage = image
        self.provider = .customSource
        self.sourceProvider = sourceProvider
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

    /// Returns this source's title.
    @objc public static func title() -> String {
        return "Local"
    }

    /// Returns an user-provided local source that uses a custom `SourceProvider`.
    public static func custom(description: String, image: UIImage, provider: SourceProvider) -> LocalSource {
        return LocalSource(description: description,
                           image: image,
                           sourceProvider: provider)
    }
}
