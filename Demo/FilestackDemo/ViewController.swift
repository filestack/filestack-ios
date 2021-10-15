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

        // Upload options for any uploaded files.
        let uploadOptions: UploadOptions = .defaults
        // Store options for any uploaded files.
        uploadOptions.storeOptions = StorageOptions(location: .s3, access: .public)

        // Instantiate picker using a custom `StorageOptions` object.
        let picker = client.picker(storeOptions: uploadOptions.storeOptions)
        // Optional. Set the picker's delegate.
        picker.pickerDelegate = self
        // Optional. Set the picker's behavior (see `PickerBehavior` for more details.)
        picker.behavior = .uploadAndStore(uploadOptions: uploadOptions)

        // Finally, present the picker on the screen.
        present(picker, animated: true)
    }
}

extension ViewController: PickerNavigationControllerDelegate {
    /// Called when the picker finishes picking files originating from the local device.
    func pickerPickedFiles(picker: PickerNavigationController, fileURLs: [URL]) {
        switch picker.behavior {
        case .storeOnly:
            // IMPORTANT: Copy, move, or access the contents of the returned files at this point while they are still available.
            // Once this delegate function call returns, all the files will be automatically removed.

            // Dismiss the picker since we have finished picking files from the local device, and, in `storeOnly` mode,
            // there's no upload phase.
            DispatchQueue.main.async {
                picker.dismiss(animated: true) {
                    self.presentAlert(titled: "Success", message: "Finished picking files: \(fileURLs)")
                }
            }
        default:
            break
        }
    }

    /// Called when the picker finishes uploading files originating from the local device to the storage destination.
    func pickerUploadedFiles(picker: PickerNavigationController, responses: [JSONResponse]) {
        // IMPORTANT: Copy, move, or access the contents of the returned files at this point while they are still available.
        // Once this delegate function call returns, all the files will be automatically removed.
        //
        // Every `JSONResponse` entry contains a `context` property with the file URL that was uploaded, and you may
        // get all the file URLs like this:
        let fileURLs = responses.compactMap { $0.context as? URL }

        print("Uploaded file URLs: \(fileURLs)")

        // Dismiss the picker since we finished uploading picked files.
        picker.dismiss(animated: true) {
            let handles = responses.compactMap { $0.json?["handle"] as? String }

            if !handles.isEmpty {
                let joinedHandles = handles.joined(separator: ", ")

                self.presentAlert(titled: "Success",
                                  message: "Finished uploading files with handles: \(joinedHandles)")
            }
        }
    }

    /// Called when the picker finishes storing a file originating from a cloud source into the storage destination.
    func pickerStoredFile(picker: PickerNavigationController, response: StoreResponse) {
        if let handle = response.contents?["handle"] as? String {
            picker.dismiss(animated: true) {
                self.presentAlert(titled: "Success", message: "Finished storing file with handle: \(handle)")
            }
        }
    }

    /// Called when the picker reports progress during a file or set of files being uploaded.
    func pickerReportedUploadProgress(picker: PickerNavigationController, progress: Float) {
        print("Picker \(picker) reported upload progress: \(progress)")
    }

    /// Called after the picker was dismissed.
    func pickerWasDismissed(picker: PickerNavigationController) {
        print("Picker \(picker) was dismissed.")
    }
}
