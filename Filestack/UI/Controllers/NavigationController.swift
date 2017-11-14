//
//  NavigationController.swift
//  Filestack
//
//  Created by Ruben Nine on 11/8/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation
import FilestackSDK

struct NavigationScene: Scene {

    let filestack: Filestack
    let storeOptions: StorageOptions

    func configureViewController(_ viewController: NavigationController) {

        // Inject the dependencies
        viewController.filestack = filestack
        viewController.storeOptions = storeOptions
    }
}


internal class NavigationController: UINavigationController {

    var filestack: Filestack!
    var storeOptions: StorageOptions!
}
