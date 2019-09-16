//
//  NavigationController.swift
//  Filestack
//
//  Created by Ruben Nine on 11/8/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import FilestackSDK
import Foundation

/// This class represents a navigation controller containing UI elements that allow picking files from local and cloud
/// sources.
@objc(FSPickerNavigationController) public class PickerNavigationController: UINavigationController {
    var client: Client!
    var storeOptions: StorageOptions!

    /// Stylizer used for changing default colors and fonts.
    @objc public lazy var stylizer = Stylizer(delegate: self)

    /// The picker delegate. Optional
    @objc public weak var pickerDelegate: PickerNavigationControllerDelegate?
}

/// This protocol contains the function signatures any `PickerNavigationController` delegate should conform to.
@objc(FSPickerNavigationControllerDelegate) public protocol PickerNavigationControllerDelegate: AnyObject {
    /// Called when the picker finishes storing a file originating from a cloud source in the destination storage location.
    @objc func pickerStoredFile(picker: PickerNavigationController, response: StoreResponse)

    /// Called when the picker finishes uploading a file originating from the local device in the destination storage location.
    @objc func pickerUploadedFiles(picker: PickerNavigationController, responses: [NetworkJSONResponse])

    /// Called when the picker reports progress during a file or set of files being uploaded.
    @objc optional func pickerReportedUploadProgress(picker: PickerNavigationController, progress: Float)
}

extension PickerNavigationController: StylizerDelegate {
    /// :nodoc:
    public func updateStyle() {
        navigationBar.tintColor = stylizer.navBar.tintColor
        navigationBar.titleTextAttributes = [.foregroundColor: stylizer.navBar.titleColor]
        navigationBar.barStyle = stylizer.navBar.style
    }
}
