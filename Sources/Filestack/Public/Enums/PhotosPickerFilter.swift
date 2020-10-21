//
//  PhotosPickerFilter.swift
//  Filestack
//
//  Created by Ruben Nine on 15/10/2020.
//  Copyright © 2020 Filestack. All rights reserved.
//

import Foundation
import PhotosUI

/// Represents a cloud provider.
@objc(FSPhotosPickerFilter) public enum PhotosPickerFilter: UInt {
    /// The filter for images.
    case images

    /// The filter for live photos.
    case livePhotos

    /// The filter for videos.
    case videos
}

@available(iOS 14.0, *)
extension PhotosPickerFilter {
    var asPHFilter: PHPickerFilter {
        switch self {
        case .images:
            return .images
        case .livePhotos:
            return .livePhotos
        case .videos:
            return .videos
        }
    }
}
