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

    let filestack: Filestack
    let storeOptions: StorageOptions

    func configureViewController(_ viewController: PickerNavigationController) {

        // Inject the dependencies
        viewController.filestack = filestack
        viewController.storeOptions = storeOptions
    }
}


@objc(FSPickerNavigationController)
public class PickerNavigationController: UINavigationController {

    var filestack: Filestack!
    var storeOptions: StorageOptions!
}
