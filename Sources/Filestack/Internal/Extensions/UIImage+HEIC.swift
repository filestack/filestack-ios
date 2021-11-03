//
//  UIImage+HEIC.swift
//  Filestack
//
//  Created by Ruben Nine on 11/20/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import AVFoundation
import UIKit

extension UIImage {
    func heicRepresentation(quality: Float) -> Data? {
        var imageData: Data?
        let destinationData = NSMutableData()

        guard
            let cgImage = cgImage,
            let destination = CGImageDestinationCreateWithData(destinationData, AVFileType.heic as CFString, 1, nil)
        else {
            return nil
        }

        let options: [CFString: Any] = [
            kCGImageDestinationLossyCompressionQuality: quality,
            kCGImagePropertyOrientation: cgImageOrientation.rawValue
        ]

        CGImageDestinationAddImage(destination, cgImage, options as CFDictionary)
        CGImageDestinationFinalize(destination)

        imageData = destinationData as Data

        return imageData
    }
}

extension UIImage {
    var cgImageOrientation: CGImagePropertyOrientation { .init(imageOrientation) }
}

extension CGImagePropertyOrientation {
    init(_ uiOrientation: UIImage.Orientation) {
        switch uiOrientation {
            case .up: self = .up
            case .upMirrored: self = .upMirrored
            case .down: self = .down
            case .downMirrored: self = .downMirrored
            case .left: self = .left
            case .leftMirrored: self = .leftMirrored
            case .right: self = .right
            case .rightMirrored: self = .rightMirrored
        @unknown default:
            fatalError()
        }
    }
}
