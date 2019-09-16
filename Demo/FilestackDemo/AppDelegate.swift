//
//  AppDelegate.swift
//  FilestackDemo
//
//  Created by Ruben Nine on 10/19/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import AVFoundation.AVAssetExportSession
import Filestack
import FilestackSDK
import UIKit

// Set your app's URL scheme here.
let callbackURLScheme = "filestackdemo"
// Set your Filestack's API key here.
let filestackAPIKey = "YOUR-FILESTACK-API-KEY"
// Set your Filestack's app secret here.
let filestackAppSecret = "YOUR-FILESTACK-APP-SECRET"
// Filestack Client, nullable
var client: Filestack.Client?

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setupFilestackClient()

        return true
    }

    private func setupFilestackClient() {
        // In case your Filestack account has security enabled, you will need to instantiate a `Security` object.
        // We can do this by either configuring a `Policy` and instantiating a `Security` object by passing
        // the `Policy` and an `appSecret`, or by instantiating a `Security` object directly by passing an already
        // encoded policy together with its corresponding signature — in this example, we will use the 1st method.

        // Create `Policy` object with an expiry time and call permissions.
        let policy = Policy(expiry: .distantFuture,
                            call: [.pick, .read, .stat, .write, .writeURL, .store, .convert, .remove, .exif])

        // Create `Security` object based on our previously created `Policy` object and app secret obtained from
        // [Filestack Developer Portal](https://dev.filestack.com/).
        guard let security = try? Security(policy: policy, appSecret: filestackAppSecret) else {
            fatalError("Unable to instantiate Security object.")
        }

        // Create `Config` object.
        let config = Filestack.Config.builder
            // Make sure to assign a valid app scheme URL
            .with(callbackURLScheme: callbackURLScheme)
            // Video quality for video recording (and sometimes exporting.)
            .with(videoQuality: .typeHigh)
            // Starting in iOS 11, you can export images in HEIF or JPEG by setting this value to
            // `.current` or `.compatible` respectively.
            // Here we state we prefer HEIF for image export.
            .with(imageURLExportPreset: .current)
            // Starting in iOS 11, you can decide what format and quality will be used for exported videos.
            // Here we state we want to export HEVC at the highest quality.
            .with(videoExportPreset: AVAssetExportPresetHEVCHighestQuality)
            // Allow up to 10 files to be picked.
            .with(maximumSelectionLimit: 10)
            // Enable image editor for files picked from the photo library.
            .withEditorEnabled()
            // Enable a list of cloud sources.
            .with(availableCloudSources: [.dropbox, .googleDrive, .googlePhotos, .customSource])
            // Enable a list of local sources.
            .with(availableLocalSources: [.camera, .photoLibrary, .documents])
            // Specify what UTIs are allowed for documents picked from Apple's Document Picker (aka iOS Files.)
            .with(documentPickerAllowedUTIs: ["public.item"])
            // Specify what UTIs are allowed for files picked from cloud providers.
            .with(cloudSourceAllowedUTIs: ["public.item"])
            .build()

        // Instantiate the Filestack `Client` by passing an API key obtained from https://dev.filestack.com/,
        // together with a `Security` and `Config` object.
        // If your account does not have security enabled, then you can omit this parameter or set it to `nil`.
        client = Filestack.Client(apiKey: filestackAPIKey, security: security, config: config)
    }
}
