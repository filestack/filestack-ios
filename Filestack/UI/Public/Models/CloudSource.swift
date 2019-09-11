//
//  CloudSource.swift
//  Filestack
//
//  Created by Ruben Nine on 11/7/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation

/// Represents a type of cloud source to be used in the picker.
@objc(FSCloudSource) public class CloudSource: NSObject, CellDescriptibleSource {
    let provider: CloudProvider
    let iconImage: UIImage
    let textDescription: String

    /// Initializer for a `CloudSource`.
    ///
    /// - Parameter description: A `String` describing the cloud source.
    /// - Parameter image: An `UIImage` visually describing the cloud source.
    /// - Parameter provider: A `CloudProvider` that better represents the cloud source.
    @objc public init(description: String, image: UIImage, provider: CloudProvider) {
        self.textDescription = description
        self.iconImage = image
        self.provider = provider
    }

    /// Facebook
    @objc public static var facebook = CloudSource(description: "Facebook",
                                                   image: .templatedFilestackImage("icon-facebook"),
                                                   provider: .facebook)

    /// Instagram
    @objc public static var instagram = CloudSource(description: "Instagram",
                                                    image: .templatedFilestackImage("icon-instagram"),
                                                    provider: .instagram)

    /// Google Drive
    @objc public static var googleDrive = CloudSource(description: "Google Drive",
                                                      image: .templatedFilestackImage("icon-googledrive"),
                                                      provider: .googleDrive)

    /// Dropbox
    @objc public static var dropbox = CloudSource(description: "Dropbox",
                                                  image: .templatedFilestackImage("icon-dropbox"),
                                                  provider: .dropbox)

    /// Box
    @objc public static var box = CloudSource(description: "Box",
                                              image: .templatedFilestackImage("icon-box"),
                                              provider: .box)

    /// GitHub
    @objc public static var gitHub = CloudSource(description: "GitHub",
                                                 image: .templatedFilestackImage("icon-github"),
                                                 provider: .gitHub)

    /// Gmail
    @objc public static var gmail = CloudSource(description: "GMail",
                                                image: .templatedFilestackImage("icon-gmail"),
                                                provider: .gmail)

    /// Google Photos
    @objc public static var googlePhotos = CloudSource(description: "Google Photos",
                                                       image: .templatedFilestackImage("icon-picasa"),
                                                       provider: .googlePhotos)

    /// OneDrive
    @objc public static var oneDrive = CloudSource(description: "One Drive",
                                                   image: .templatedFilestackImage("icon-onedrive"),
                                                   provider: .oneDrive)

    /// Amazon Drive
    @objc public static var amazonDrive = CloudSource(description: "Cloud Drive",
                                                      image: .templatedFilestackImage("icon-clouddrive"),
                                                      provider: .amazonDrive)

    /// Custom Source
    @objc public static var customSource = CloudSource(description: "Custom Source",
                                                       image: .templatedFilestackImage("icon-customsource"),
                                                       provider: .customSource)

    /// Returns all the supported sources.
    @objc public static func all() -> [CloudSource] {
        return [.facebook, .instagram, .googleDrive, .dropbox, .box, .gitHub,
                .gmail, .googlePhotos, .oneDrive, .amazonDrive, .customSource]
    }

    /// Returns this source's title.
    @objc public static func title() -> String {
        return "Cloud"
    }

    /// Returns a `String` representation of self.
    public override var description: String {
        return textDescription
    }
}
