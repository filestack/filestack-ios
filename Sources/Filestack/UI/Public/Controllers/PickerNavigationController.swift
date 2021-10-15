//
//  NavigationController.swift
//  Filestack
//
//  Created by Ruben Nine on 11/8/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import FilestackSDK
import UIKit

/// This class represents a navigation controller containing UI elements that allow picking files from local and cloud
/// sources.
@objc(FSPickerNavigationController) public class PickerNavigationController: UINavigationController {
    var client: Client!
    var storeOptions: StorageOptions!

    /// This setting determines what should happen after picking files (see `PickerBehavior` for more information.)
    ///
    /// The default value is `.uploadAndStore`
    public var behavior: PickerBehavior = .uploadAndStore(uploadOptions: .defaults)

    /// Stylizer used for changing default colors and fonts.
    @objc public lazy var stylizer = Stylizer(delegate: self)

    /// The picker delegate. Optional
    @objc public weak var pickerDelegate: PickerNavigationControllerDelegate?

    deinit {
        pickerDelegate?.pickerWasDismissed?(picker: self)
    }
}

/// This protocol contains the function signatures any `PickerNavigationController` delegate should conform to.
@objc(FSPickerNavigationControllerDelegate) public protocol PickerNavigationControllerDelegate: AnyObject {
    /// Called when the picker finishes picking files originating from the local device.
    @objc func pickerPickedFiles(picker: PickerNavigationController, fileURLs: [URL])

    /// Called when the picker finishes uploading files originating from the local device to the storage destination.
    @objc func pickerUploadedFiles(picker: PickerNavigationController, responses: [JSONResponse])

    /// Called when the picker finishes storing a file originating from a cloud source into the storage destination.
    @objc func pickerStoredFile(picker: PickerNavigationController, response: StoreResponse)

    /// Called when the picker reports progress during a file or set of files being uploaded.
    @objc optional func pickerReportedUploadProgress(picker: PickerNavigationController, progress: Float)

    /// Called after the picker was dismissed.
    @objc optional func pickerWasDismissed(picker: PickerNavigationController)
}

extension PickerNavigationController: StylizerDelegate {
    /// :nodoc:
    public func updateStyle() {
        navigationBar.tintColor = stylizer.navBar.tintColor
        navigationBar.titleTextAttributes = [.foregroundColor: stylizer.navBar.titleColor]
        navigationBar.barStyle = stylizer.navBar.style
    }
}
