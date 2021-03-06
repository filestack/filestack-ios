//
//  CloudProvider.swift
//  Filestack
//
//  Created by Ruben Nine on 10/26/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation

/// Represents a cloud provider.
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

    /// Unsplash
    case unsplash

    /// Custom Source
    case customSource
}

extension CloudProvider {
    /// :nodoc:
    public var searchBased: Bool {
        switch self {
        case .unsplash:
            return true
        default:
            return false
        }
    }

    /// :nodoc:
    var viewType: CloudSourceViewType? {
        switch self {
        case .unsplash:
            return .grid
        default:
            return nil
        }
    }
}

extension CloudProvider {
    /// :nodoc:
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
        case .unsplash:
            return "unsplash"
        case .customSource:
            return "customsource"
        }
    }
}
