//
//  URL+IsDirectory.swift
//  Filestack
//
//  Created by Ruben Nine on 17/09/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import Foundation

extension URL {
    var isDirectory: Bool {
        var isDirectory: ObjCBool = false
        FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory)

        return isDirectory.boolValue
    }
}
