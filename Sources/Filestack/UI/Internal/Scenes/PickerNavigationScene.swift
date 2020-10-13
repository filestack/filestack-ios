//
//  PickerNavigationScene.swift
//  Filestack
//
//  Created by Ruben Nine on 11/09/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import FilestackSDK
import Foundation

struct PickerNavigationScene: Scene {
    let client: Client
    let storeOptions: StorageOptions

    func configureViewController(_ viewController: PickerNavigationController) {
        viewController.client = client
        viewController.storeOptions = storeOptions
    }
}
