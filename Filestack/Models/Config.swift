//
//  Config.swift
//  Filestack
//
//  Created by Ruben Nine on 11/14/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation
import UIKit.UIImagePickerController
import AVFoundation.AVAssetExportSession

/**
    The `Config` class is used together with `Client` to configure certain aspects of the API.
 */
@objc(FSConfig) public class Config: NSObject {
  
    /// An URL scheme supported by the app. This is required to complete the cloud provider's authentication flow.
    public var appURLScheme: String? = nil

    /// This policy controls the thumbnail's caching behavior when browsing cloud contents in the picker.
    public var cloudThumbnailCachePolicy: URLRequest.CachePolicy = .reloadIgnoringLocalCacheData

    /// Use this value if you want to allow user for selecting unlimited number of assets to upload.
    public static let kMaximumSelectionNoLimit: UInt = 0

    /// This controls if user can select more than one image/document for upload.
    /// Set this value to `kMaximumSelectionNoLimit` if you want to remove this limit.
    /// Setting more then one will use custom ImagePicker in case of LocalSource.photoLibrary.
    /// The default value is 1.
    public var maximumSelectionAllowed: UInt = 1

    /// This setting determines what cloud sources are available when using the picker.
    /// By default, it contains all the supported cloud sources.
    /// - Note: Please notice that a custom source will only be displayed if enabled on Filestack's
    /// [Developer Portal](http://dev.filestack.com), regardless of whether it is present in this list.
    public var availableCloudSources: [CloudSource] = CloudSource.all()

    /// This setting determines what local sources are available when using the picker.
    /// By default, it contains all the supported local sources.
    public var availableLocalSources: [LocalSource] = LocalSource.all()

    /// This setting determines what document types can be picked when using Apple's document picker.
    /// By default, this contains `["public.item"]`.
    public var documentPickerAllowedUTIs: [String] = ["public.item"]

    /// This setting determines the format used for exported images (available only in iOS 11.)
    /// Possible values are `.compatible` (for JPEG) and `.current` (for HEIF).
    /// In iOS versions earlier than 11.0, JPEG will always be used.
    @available(iOS 11.0, *)
    public var imageURLExportPreset: ImageURLExportPreset {
        // This ugly workaround is required because Swift does not currently allow marking stored properties'
        // availability.
        get {
            return _imageURLExportPreset ?? .compatible
        }

        set {
            _imageURLExportPreset = newValue
        }
    }

    private var _imageURLExportPreset: ImageURLExportPreset?

    /// This setting determines the quality setting for images taken using the camera and exported either as HEIC or JPEG.
    /// - Note: This setting has no effect on images picked from the photo library.
    public var imageExportQuality: Float = 0.85

    /// This setting determines the format used for exported videos (available only in iOS 11.)
    ///
    /// Some possible values are:
    /// - `AVAssetExportPresetHEVCHighestQuality` (for highest quality HEVC)
    /// - `AVAssetExportPresetHighestQuality` (for highest quality H.264)
    ///
    /// For more possible values, please consult `AVAssetExportSession`.
    ///
    /// The default value is `AVAssetExportPresetHEVCHighestQuality`
    @available(iOS 11.0, *)
    public var videoExportPreset: String {
        // This ugly workaround is required because Swift does not currently allow marking stored properties'
        // availability.
        get {
            return _videoExportPreset ?? AVAssetExportPresetHEVCHighestQuality
        }

        set {
            _videoExportPreset = newValue
        }
    }

    private var _videoExportPreset: String?

    /// This setting determines the video recording quality for videos recorded using the camera.
    /// It is also used whenever picking a recorded movie. Specifically, if the video quality setting is lower than the
    /// video quality of an existing movie, displaying that movie in the picker results in transcoding the movie to the
    /// lower quality.
    ///
    /// The default value is `.typeMedium`
    public var videoQuality: UIImagePickerControllerQualityType = .typeMedium
}
