//
//  CloudSource.swift
//  Filestack
//
//  Created by Ruben Nine on 11/7/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation


internal enum CloudSource: UInt, CustomStringConvertible, CellDescriptibleSource {

    case facebook
    case instagram
    case googleDrive
    case dropbox
    case box
    case gitHub
    case gmail
    case googlePhotos
    case oneDrive
    case amazonDrive
    case customSource

    static func all() -> [CloudSource] {

        return [.facebook, .instagram, .googleDrive, .dropbox, .box, .gitHub,
                .gmail, .googlePhotos, .oneDrive, .amazonDrive, .customSource]
    }

    static func title() -> String {

        return "Cloud"
    }

    var provider: CloudProvider {

        return CloudProvider(rawValue: self.rawValue)!
    }

    var iconName: String {

        return "icon-\(provider.description)"
    }

    var description: String {

        switch self {
        case .facebook:

            return "Facebook"

        case .instagram:

            return "Instagram"

        case .googleDrive:

            return "Google Drive"

        case .dropbox:

            return "Dropbox"

        case .box:

            return "Box"

        case .gitHub:

            return "GitHub"

        case .gmail:

            return "GMail"

        case .googlePhotos:

            return "Google Photos"

        case .oneDrive:

            return "One Drive"

        case .amazonDrive:

            return "Cloud Drive"

        case .customSource:

            return "Custom Source"
        }
    }
}

