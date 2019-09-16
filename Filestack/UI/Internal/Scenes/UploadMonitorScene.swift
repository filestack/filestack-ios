//
//  UploadMonitorScene.swift
//  Filestack
//
//  Created by Ruben Nine on 11/09/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import FilestackSDK
import Foundation

struct UploadMonitorScene: Scene {
    var cancellable: Cancellable?

    func configureViewController(_ viewController: UploadMonitorViewController) {
        viewController.cancellable = cancellable
    }
}
