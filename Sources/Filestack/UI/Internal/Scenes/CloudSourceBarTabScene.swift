//
//  CloudSourceBarTabScene.swift
//  Filestack
//
//  Created by Ruben Nine on 11/09/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import FilestackSDK
import Foundation

struct CloudSourceTabBarScene: Scene {
    let client: Client
    let storeOptions: StorageOptions
    let source: CloudSource

    var customSourceName: String?
    var path: String?
    var nextPageToken: String?
    var viewType: CloudSourceViewType

    func configureViewController(_ viewController: CloudSourceTabBarController) {
        // Inject the dependencies
        viewController.client = client
        viewController.storeOptions = storeOptions
        viewController.source = source
        viewController.customSourceName = customSourceName
        viewController.nextPageToken = nextPageToken
        viewController.path = path ?? "/"
        viewController.viewType = viewType
    }
}
