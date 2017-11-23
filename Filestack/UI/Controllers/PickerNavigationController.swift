//
//  NavigationController.swift
//  Filestack
//
//  Created by Ruben Nine on 11/8/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation
import FilestackSDK


internal struct PickerNavigationScene: Scene {

    let client: Client
    let storeOptions: StorageOptions

    func configureViewController(_ viewController: PickerNavigationController) {

        // Inject the dependencies
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
}
