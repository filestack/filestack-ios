//
//  Config.swift
//  Filestack
//
//  Created by Ruben Nine on 11/14/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import AVFoundation.AVAssetExportSession
import Foundation
import UIKit.UIImagePickerController

/// The `Config` class is used together with `Client` to configure certain aspects of the API.
@objc(FSConfig) public class Config: NSObject {
    // MARK: - Config Builder

    /// Returns a `Builder` instance to help instantiating `Config` objects.
    @objc public static var builder = Builder()

    // MARK: - Config Options

    /// Change this flag to true if you want to allow user to edit photos before the upload.
    @objc public var showEditorBeforeUpload: Bool = false

    /// An URL scheme supported by the app. This is required to complete the cloud provider's authentication flow.
    @objc public var callbackURLScheme: String?

    /// This policy controls the thumbnail's caching behavior when browsing cloud contents in the picker.
    @objc public var cloudThumbnailCachePolicy: URLRequest.CachePolicy = .reloadIgnoringLocalCacheData

    /// Use this value if you want to allow user for selecting unlimited number of assets to upload.
    @objc public static let kMaximumSelectionNoLimit: UInt = 0

    /// This controls if user can select more than one image/document for upload.
    /// Set this value to `kMaximumSelectionNoLimit` if you want to remove this limit.
    /// Setting more then one will use custom ImagePicker in case of LocalSource.photoLibrary.
    /// The default value is 1.
    @objc public var maximumSelectionAllowed: UInt = 1

    /// This settings determines the way we want to present document picker, image pickers and upload monitor.
    /// The default presentation style is `.currentContext`
    @objc public var modalPresentationStyle: UIModalPresentationStyle = .currentContext

    /// This setting determines what cloud sources are available when using the picker.
    /// By default, it contains all the supported cloud sources.
    /// - Note: Please notice that a custom source will only be displayed if enabled on Filestack's
    /// [Developer Portal](http://dev.filestack.com), regardless of whether it is present in this list.
    @objc public var availableCloudSources: [CloudSource] = CloudSource.all()

    /// This setting determines what local sources are available when using the picker.
    /// By default, it contains all the supported local sources.
    @objc public var availableLocalSources: [LocalSource] = LocalSource.all()

    /// This setting determines what document types can be picked when using Apple's document picker.
    /// By default, this contains `["public.item"]`.
    @objc public var documentPickerAllowedUTIs: [String] = ["public.item"]

    /// This setting determines what document types can be picked from a cloud source.
    /// By default, this contains `["public.item"]`.
    @objc public var cloudSourceAllowedUTIs: [String] = ["public.item"]

    /// This setting determines the format used for exported images.
    /// Possible values are `.compatible` (for JPEG) and `.current` (for HEIF).
    @objc public var imageURLExportPreset: ImageURLExportPreset = .compatible

    /// This setting determines the quality setting for images taken using the camera and exported either as HEIC or JPEG.
    /// - Note: This setting has no effect on images picked from the photo library.
    @objc public var imageExportQuality: Float = 0.85

    /// This setting determines the format used for exported videos.
    ///
    /// Some possible values are:
    /// - `AVAssetExportPresetHEVCHighestQuality` (for highest quality HEVC)
    /// - `AVAssetExportPresetHighestQuality` (for highest quality H.264)
    ///
    /// For more possible values, please consult `AVAssetExportSession`.
    ///
    /// The default value is `AVAssetExportPresetHEVCHighestQuality`
    @objc public var videoExportPreset: String = AVAssetExportPresetHEVCHighestQuality

    /// This setting determines the video recording quality for videos recorded using the camera.
    /// It is also used whenever picking a recorded movie. Specifically, if the video quality setting is lower than the
    /// video quality of an existing movie, displaying that movie in the picker results in transcoding the movie to the
    /// lower quality.
    ///
    /// The default value is `.typeMedium`
    @objc public var videoQuality: UIImagePickerController.QualityType = .typeMedium
}

extension Config {
    /// A convenience class that allows easily building a new `Config` object.
    @objc(FSConfigBuilder) public class Builder: NSObject {
        private var showEditorBeforeUpload: Bool?
        private var callbackURLScheme: String?
        private var cloudThumbnailCachePolicy: URLRequest.CachePolicy?
        private var maximumSelectionAllowed: UInt?
        private var modalPresentationStyle: UIModalPresentationStyle?
        private var availableCloudSources: [CloudSource]?
        private var availableLocalSources: [LocalSource]?
        private var documentPickerAllowedUTIs: [String]?
        private var cloudSourceAllowedUTIs: [String]?
        private var imageURLExportPreset: ImageURLExportPreset?
        private var imageExportQuality: Float?
        private var videoExportPreset: String?
        private var videoQuality: UIImagePickerController.QualityType?

        override init() {}

        /// :nodoc:
        @objc public func with(callbackURLScheme: String) -> Self {
            self.callbackURLScheme = callbackURLScheme
            return self
        }

        @objc public func with(cloudThumbnailCachePolicy: URLRequest.CachePolicy) -> Self {
            self.cloudThumbnailCachePolicy = cloudThumbnailCachePolicy
            return self
        }

        /// :nodoc:
        @objc public func with(maximumSelectionLimit: UInt) -> Self {
            maximumSelectionAllowed = maximumSelectionLimit
            return self
        }

        /// :nodoc:
        @objc public func withNoSelectionLimit() -> Self {
            maximumSelectionAllowed = Config.kMaximumSelectionNoLimit
            return self
        }

        /// :nodoc:
        @objc public func with(modalPresentationStyle: UIModalPresentationStyle) -> Self {
            self.modalPresentationStyle = modalPresentationStyle
            return self
        }

        /// :nodoc:
        @objc public func with(availableCloudSources: [CloudSource]) -> Self {
            self.availableCloudSources = availableCloudSources
            return self
        }

        /// :nodoc:
        @objc public func with(availableLocalSources: [LocalSource]) -> Self {
            self.availableLocalSources = availableLocalSources
            return self
        }

        /// :nodoc:
        @objc public func with(documentPickerAllowedUTIs: [String]) -> Self {
            self.documentPickerAllowedUTIs = documentPickerAllowedUTIs
            return self
        }

        /// :nodoc:
        @objc public func with(cloudSourceAllowedUTIs: [String]) -> Self {
            self.cloudSourceAllowedUTIs = cloudSourceAllowedUTIs
            return self
        }

        /// :nodoc:
        @objc public func with(imageURLExportPreset: ImageURLExportPreset) -> Self {
            self.imageURLExportPreset = imageURLExportPreset
            return self
        }

        /// :nodoc:
        @objc public func with(imageExportQuality: Float) -> Self {
            self.imageExportQuality = imageExportQuality
            return self
        }

        /// :nodoc:
        @objc public func with(videoExportPreset: String) -> Self {
            self.videoExportPreset = videoExportPreset
            return self
        }

        /// :nodoc:
        @objc public func with(videoQuality: UIImagePickerController.QualityType) -> Self {
            self.videoQuality = videoQuality
            return self
        }

        /// :nodoc:
        @objc public func withEditorEnabled() -> Self {
            showEditorBeforeUpload = true
            return self
        }

        /// Instantiates a new `Config` object using any user-supplied options.
        @objc public func build() -> Config {
            let config = Config()

            if let showEditorBeforeUpload = showEditorBeforeUpload {
                config.showEditorBeforeUpload = showEditorBeforeUpload
            }

            if let callbackURLScheme = callbackURLScheme {
                config.callbackURLScheme = callbackURLScheme
            }

            if let cloudThumbnailCachePolicy = cloudThumbnailCachePolicy {
                config.cloudThumbnailCachePolicy = cloudThumbnailCachePolicy
            }

            if let maximumSelectionAllowed = maximumSelectionAllowed {
                config.maximumSelectionAllowed = maximumSelectionAllowed
            }

            if let modalPresentationStyle = modalPresentationStyle {
                config.modalPresentationStyle = modalPresentationStyle
            }

            if let availableCloudSources = availableCloudSources {
                config.availableCloudSources = availableCloudSources
            }

            if let availableLocalSources = availableLocalSources {
                config.availableLocalSources = availableLocalSources
            }

            if let documentPickerAllowedUTIs = documentPickerAllowedUTIs {
                config.documentPickerAllowedUTIs = documentPickerAllowedUTIs
            }

            if let cloudSourceAllowedUTIs = cloudSourceAllowedUTIs {
                config.cloudSourceAllowedUTIs = cloudSourceAllowedUTIs
            }

            if let imageURLExportPreset = imageURLExportPreset {
                config.imageURLExportPreset = imageURLExportPreset
            }

            if let imageExportQuality = imageExportQuality {
                config.imageExportQuality = imageExportQuality
            }

            if let videoExportPreset = videoExportPreset {
                config.videoExportPreset = videoExportPreset
            }

            if let videoQuality = videoQuality {
                config.videoQuality = videoQuality
            }

            return config
        }
    }
}

// MARK: - Deprecated

/// :nodoc:
extension Config {
    @available(*, deprecated, message: "Marked for removal in version 3.0", renamed: "callbackURLScheme")
    @objc public var appURLScheme: String? {
        set { callbackURLScheme = newValue }
        get { callbackURLScheme }
    }
}

/// :nodoc:
extension Config.Builder {
    @available(*, deprecated, message: "Marked for removal in version 3.0", renamed: "with(callbackURLScheme:)")
    @objc public func with(appURLScheme: String) -> Self {
        self.callbackURLScheme = appURLScheme
        return self
    }

    @available(*, deprecated, message: "Marked for removal in version 3.0", renamed: "with(callbackURLScheme:)")
    public func with(appUrlScheme: String) -> Self {
        return with(appURLScheme: appUrlScheme)
    }

    @available(*, deprecated, message: "Marked for removal in version 3.0", renamed: "with(imageURLExportPreset:)")
    public func with(imageUrlExportPreset: ImageURLExportPreset) -> Self {
        return with(imageURLExportPreset: imageUrlExportPreset)
    }
}
