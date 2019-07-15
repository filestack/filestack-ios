//
//  UIImage+Export.swift
//  Filestack
//
//  Created by Ruben Nine on 7/11/19.
//  Copyright © 2019 Filestack. All rights reserved.
//

import UIKit

extension UIImage {
    func exportHEICImage(to destinationURL: URL, quality: Float) -> Bool {
        guard let imageData = heicRepresentation(quality: quality) else { return false }

        return export(data: imageData, to: destinationURL)
    }

    func exportJPGImage(to destinationURL: URL, quality: Float) -> Bool {
        guard let imageData = jpegData(compressionQuality: CGFloat(quality)) else { return false }

        return export(data: imageData, to: destinationURL)
    }

    // MARK: - Private Functions

    private func export(data: Data, to destinationURL: URL) -> Bool {
        do {
            try data.write(to: destinationURL)
            return true
        } catch {
            return false
        }
    }
}
