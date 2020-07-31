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
        if let viewController = viewControllerToPresent as? PickerNavigationController {
            viewController.modalPresentationStyle = .pageSheet
            // If using `popover`, set `sourceView` and `sourceRect` to the control the popover should be anchored to.
            // viewController.popoverPresentationController?.sourceView = pickerButton
            // viewController.popoverPresentationController?.sourceRect = pickerButton.bounds
        }

        super.present(viewControllerToPresent, animated: true, completion: completion)
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
    func pickerStoredFile(picker: PickerNavigationController, response: StoreResponse) {
        if let handle = response.contents?["handle"] as? String {
            picker.dismiss(animated: true) {
                self.presentAlert(titled: "Success", message: "Finished storing file with handle: \(handle)")
            }
        }
    }

    /// Called when the picker finishes uploading a file originating from the local device in the destination storage location.
    func pickerUploadedFiles(picker: PickerNavigationController, responses: [JSONResponse]) {
        let handles = responses.compactMap { $0.json?["handle"] as? String }

        if !handles.isEmpty {
            picker.dismiss(animated: true) {
                let joinedHandles = handles.joined(separator: ", ")
                self.presentAlert(titled: "Success", message: "Finished uploading files with handles: \(joinedHandles)")
            }
        }
    }

    /// Called when the picker reports progress during a file or set of files being uploaded.
    func pickerReportedUploadProgress(picker: PickerNavigationController, progress: Float) {
        print("Picker \(picker) reported upload progress: \(progress)")
    }
}
