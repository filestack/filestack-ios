//
//  URL+Move.swift
//  Filestack
//
//  Created by Ruben Nine on 15/10/2020.
//  Copyright © 2020 Filestack. All rights reserved.
//

import Foundation

extension URL {
    func move(to destinationURL: URL) -> Bool {
        let fm = FileManager.default

        do {
            try fm.moveItem(at: self, to: destinationURL)
            return true
        } catch {
            return false
        }
    }

    func moveIntoTemporaryLocation() -> URL? {
        let fm = FileManager.default

        let destinationURL = fm.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension(pathExtension)

        if move(to: destinationURL) {
            return destinationURL
        } else {
            return nil
        }
    }
}
