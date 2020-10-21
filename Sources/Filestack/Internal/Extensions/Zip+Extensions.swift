//
//  QuickZip+Extensions.swift
//  Filestack
//
//  Created by Ruben Nine on 16/10/2020.
//  Copyright © 2020 Filestack. All rights reserved.
//

import Foundation
import Zip

extension Zip {
    class func quickZipFiles(_ paths: [URL], directory: URL, fileName: String, progress: ((_ progress: Double) -> ())? = nil) throws -> URL {
        let destinationUrl = directory.appendingPathComponent("\(fileName).zip")
        try self.zipFiles(paths: paths, zipFilePath: destinationUrl, password: nil, progress: progress)
        return destinationUrl
    }
}
