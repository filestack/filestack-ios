//
//  UIImage+HEIC.swift
//  Filestack
//
//  Created by Ruben Nine on 11/20/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import AVFoundation
import UIKit

internal extension UIImage {
    @available(iOS 11.0, *)
    func heicRepresentation(quality: Float) -> Data? {
        var imageData: Data?
        let destinationData = NSMutableData()

        if let destination = CGImageDestinationCreateWithData(destinationData, AVFileType.heic as CFString, 1, nil),
            let cgImage = cgImage {
            let options = [kCGImageDestinationLossyCompressionQuality: quality]
            CGImageDestinationAddImage(destination, cgImage, options as CFDictionary)
            CGImageDestinationFinalize(destination)

            imageData = destinationData as Data

            return imageData
        }

        return nil
    }
}
