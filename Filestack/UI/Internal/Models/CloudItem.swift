//
//  CloudItem.swift
//  Filestack
//
//  Created by Ruben Nine on 11/10/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation

internal struct CloudItem {
    let isFolder: Bool
    let name: String
    let path: String
    let thumbnailURL: URL

    init?(dictionary: [String: Any]) {
        guard let isFolder = dictionary["folder"] as? Bool,
            let name = dictionary["name"] as? String,
            let path = dictionary["path"] as? String,
            let thumbnailURLString = dictionary["thumbnail"] as? String,
            let thumbnailURL = URL(string: thumbnailURLString) else {
            return nil
        }

        self.isFolder = isFolder
        self.name = name

        if isFolder {
            // Ensure items representing folders contain a trailing slash.
            // Sometimes, results from some providers (e.g. using GitHub) do not include it.
            self.path = path.last == "/" ? path : "\(path)/"
        } else {
            self.path = path
        }

        self.thumbnailURL = thumbnailURL
    }
}
