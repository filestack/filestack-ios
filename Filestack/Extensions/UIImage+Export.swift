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
        if let imageData = heicRepresentation(quality: quality) {
            do {
                try imageData.write(to: destinationURL)
                return true
            } catch {
                return false
            }
        }

        return false
    }

    func exportJPGImage(to destinationURL: URL, quality: Float) -> Bool {
        if let imageData = jpegData(compressionQuality: CGFloat(quality)) {
            do {
                try imageData.write(to: destinationURL)
                return true
            } catch {
                return false
            }
        }

        return false
    }
}
