//
//  UploadMonitorScene.swift
//  Filestack
//
//  Created by Ruben Nine on 11/09/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import Foundation

struct UploadMonitorScene: Scene {
    var cancellableRequest: CancellableRequest?

    func configureViewController(_ viewController: UploadMonitorViewController) {
        viewController.cancellableRequest = cancellableRequest
    }
}
