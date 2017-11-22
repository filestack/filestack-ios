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

        // Inject the dependencies
        viewController.client = client
        viewController.storeOptions = storeOptions
    }
}


@objc(FSPickerNavigationController)
public class PickerNavigationController: UINavigationController {

    var client: Client!
    var storeOptions: StorageOptions!
}
