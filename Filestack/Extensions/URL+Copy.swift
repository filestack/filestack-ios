//
//  URL+Copy.swift
//  Filestack
//
//  Created by Ruben Nine on 7/15/19.
//  Copyright © 2019 Filestack. All rights reserved.
//

import Foundation

extension URL {
    func copy(to destinationURL: URL) -> Bool {
        let fm = FileManager.default

        do {
            try fm.copyItem(at: self, to: destinationURL)
            return true
        } catch {
            return false
        }
    }

    func copyIntoTemporaryLocation() -> URL? {
        let fm = FileManager.default

        let destinationURL = fm.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension(pathExtension)

        if copy(to: destinationURL) {
            return destinationURL
        } else {
            return nil
        }
    }
}
