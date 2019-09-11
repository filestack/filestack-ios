//
//  UploadMonitorViewController.swift
//  Filestack
//
//  Created by Ruben Nine on 11/9/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import FilestackSDK
import Foundation

struct UploadMonitorScene: Scene {
    var cancellableRequest: CancellableRequest?

    func configureViewController(_ viewController: UploadMonitorViewController) {
        viewController.cancellableRequest = cancellableRequest
    }
}

final class UploadMonitorViewController: UIViewController {
    @IBOutlet var progressView: UIProgressView!
    @IBOutlet var cancelButton: UIButton!

    var cancellableRequest: CancellableRequest?

    override func viewDidLoad() {
        super.viewDidLoad()
        progressView.progress = 0
    }

    func updateProgress(value: Float) {
        guard isViewLoaded else { return }
        progressView.progress = value
        cancelButton.isEnabled = progressView.progress < 1.0
    }

    @IBAction func cancel(_: AnyObject) {
        cancellableRequest?.cancel()
    }
}
