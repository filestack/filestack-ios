//
//  ViewController.swift
//  FilestackDemo
//
//  Created by Ruben Nine on 10/19/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import AVFoundation.AVAssetExportSession
import Filestack
import FilestackSDK
import UIKit

// Set your Filestack's API key here.
private let filestackAPIKey = "YOUR-FILESTACK-API-KEY"
// Set your Filestack's app secret here.
private let filestackAppSecret = "YOUR-FILESTACK-APP-SECRET"

class ViewController: UIViewController {
    @IBOutlet var pickerButton: UIButton!

    override func present(_ viewControllerToPresent: UIViewController, animated _: Bool, completion: (() -> Void)? = nil) {
        // On the iPad, present the picker as a popover — this is totally optional.
        if let viewController = viewControllerToPresent as? PickerNavigationController {
            viewController.modalPresentationStyle = .popover
            viewController.popoverPresentationController?.sourceView = pickerButton
            viewController.popoverPresentationController?.sourceRect = pickerButton.bounds
        }

        super.present(viewControllerToPresent, animated: true, completion: completion)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func presentPicker(_: AnyObject) {
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
        let config = Filestack.Config()

        // IMPORTANT: - Make sure to assign an app scheme URL that matches the one(s) configured in your info.plist.
        // In our demo this is "filestackdemo".
        config.appURLScheme = appURLScheme

        // Video quality for video recording (and sometimes exporting.)
        config.videoQuality = .typeHigh

        if #available(iOS 11.0, *) {
            // On iOS 11, you can export images in HEIF or JPEG by setting this value to `.current` or `.compatible`
            // respectively.
            // Here we state we prefer HEIF for image export.
            config.imageURLExportPreset = .current
            // On iOS 11, you can decide what format and quality will be used for exported videos.
            // Here we state we want to export HEVC at the highest quality.
            config.videoExportPreset = AVAssetExportPresetHEVCHighestQuality
        }

        // Here you can enumerate the available local sources for the picker.
        // If you simply want to enumerate all the local sources, you may use `LocalSource.all()`, but if you would
        // like to enumerate, let's say the camera source only, you could set it like this:
        //
        //   config.availableLocalSources = [.camera]
        //
        config.availableLocalSources = LocalSource.all()

        // Here you can enumerate the available cloud sources for the picker.
        // If you simply want to enumerate all the cloud sources, you may use `CloudSource.all()`, but if you would
        // like to enumerate selected cloud sources, you could set these like this:
        //
        //   config.availableCloudSources = [.dropbox, .googledrive, .googlephotos, .customSource]
        //
        config.availableCloudSources = CloudSource.all()

        // Here you can decide what document types can be picked when using Apple's document picker.
        config.documentPickerAllowedUTIs = ["public.item"]
        // In the same fashion, you can decide what document types can be picked from cloud sources.
        config.cloudSourceAllowedUTIs = ["public.item"]
        // In both cases we have used ["public.item"], which means we allow picking any files or bundles.

        // Instantiate the Filestack `Client` by passing an API key obtained from [Filestack Developer Portal](https://dev.filestack.com/),
        // together with a `Security` and `Config` object.
        // If your account does not have security enabled, then you can omit this parameter or set it to `nil`.
        let client = Filestack.Client(apiKey: filestackAPIKey, security: security, config: config)

        // Store options for your uploaded files.
        // Here we are saying our storage location is S3 and access for uploaded files should be public.
        let storeOptions = StorageOptions(location: .s3, access: .public)

        // Instantiate picker by passing the `StorageOptions` object we just set up.
        let picker = client.picker(storeOptions: storeOptions)

        // Optional. Set the picker's delegate.
        picker.pickerDelegate = self

        // Finally, present the picker on the screen.
        present(picker, animated: true)
    }
}

extension ViewController: PickerNavigationControllerDelegate {
    /// Called when the picker finishes storing a file originating from a cloud source in the destination storage location.
    func pickerStoredFile(picker _: PickerNavigationController, response: StoreResponse) {
        if let contents = response.contents {
            // Our cloud file was stored into the destination location.
            print("Stored file response: \(contents)")
        } else if let error = response.error {
            // The store operation failed.
            print("Error storing file: \(error)")
        }
    }

    /// Called when the picker finishes uploading a file originating from the local device in the destination storage location.
    func pickerUploadedFiles(picker _: PickerNavigationController, responses: [NetworkJSONResponse]) {
        for response in responses {
            if let contents = response.json {
                // Our local file was stored into the destination location.
                print("Uploaded file response: \(contents)")
            } else if let error = response.error {
                // The upload operation failed.
                print("Error uploading file: \(error)")
            }
        }
    }
}
