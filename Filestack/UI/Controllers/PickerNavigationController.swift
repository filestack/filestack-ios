//
//  NavigationController.swift
//  Filestack
//
//  Created by Ruben Nine on 11/8/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation
import FilestackSDK

struct PickerNavigationScene: Scene {

  let client: Client
  let storeOptions: StorageOptions

  func configureViewController(_ viewController: PickerNavigationController) {
    viewController.client = client
    viewController.storeOptions = storeOptions
  }
}

/**
    This class represents a navigation controller containing UI elements that allow picking files from local and cloud
    sources.
 */
@objc(FSPickerNavigationController) public class PickerNavigationController: UINavigationController {

  internal var client: Client!
  internal var storeOptions: StorageOptions!
  
  /// Stylizer used for changing default colors and fonts.
  public lazy var stylizer = Stylizer(delegate: self)

  /// The picker delegate. Optional
  public weak var pickerDelegate: PickerNavigationControllerDelegate?
}

/**
    This protocol contains the function signatures any `PickerNavigationController` delegate should conform to.
 */
@objc(FSPickerNavigationControllerDelegate) public protocol PickerNavigationControllerDelegate : class {

  /// Called when the picker finishes storing a file originating from a cloud source in the destination storage location.
  func pickerStoredFile(picker: PickerNavigationController, response: StoreResponse)

  /// Called when the picker finishes uploading a file originating from the local device in the destination storage location.
  func pickerUploadedFiles(picker: PickerNavigationController, responses: [NetworkJSONResponse])
}

extension PickerNavigationController: StylizerDelegate {
  func updateStyle() {
    navigationBar.tintColor = stylizer.navBar.tintColor
    navigationBar.titleTextAttributes = [.foregroundColor: stylizer.navBar.titleColor]
    navigationBar.barStyle = stylizer.navBar.style
  }
}
