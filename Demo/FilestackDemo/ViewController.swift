//
//  ViewController.swift
//  FilestackDemo
//
//  Created by Ruben Nine on 10/19/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Filestack
import FilestackSDK
import UIKit

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
        guard let client = client else { return }

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

    /// Called when the picker reports progress during a file or set of files being uploaded.
    func pickerReportedUploadProgress(picker: PickerNavigationController, progress: Float) {
        print("Picker \(picker) reported upload progress: \(progress)")
    }
}
