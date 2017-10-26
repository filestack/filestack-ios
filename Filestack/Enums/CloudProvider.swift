//
//  CloudProvider.swift
//  Filestack
//
//  Created by Ruben Nine on 10/26/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation


/**
    Represents a cloud provider.
 */
@objc(FSCloudProvider) public enum CloudProvider: UInt, CustomStringConvertible {

    /// Facebook
    case facebook

    /// Instagram
    case instagram

    /// Google Drive
    case googleDrive

    /// Dropbox
    case dropbox

    /// Box
    case box

    /// GitHub
    case gitHub

    /// Gmail
    case gmail

    /// Google Photos
    case googlePhotos

    /// OneDrive
    case oneDrive

    /// Amazon Drive
    case amazonDrive

    /// Custom Source
    case customSource


    // MARK: - CustomStringConvertible

    /// Returns a `String` representation of self.
    public var description: String {

        switch self {
        case .facebook:

            return "facebook"

        case .instagram:

            return "instagram"

        case .googleDrive:

            return "googledrive"

        case .dropbox:

            return "dropbox"

        case .box:

            return "box"

        case .gitHub:

            return "github"

        case .gmail:

            return "gmail"

        case .googlePhotos:

            return "picasa"

        case .oneDrive:

            return "onedrive"

        case .amazonDrive:

            return "clouddrive"

        case .customSource:

            return "customsource"
        }
    }
}
