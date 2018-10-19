//
//  UploadMonitorViewController.swift
//  Filestack
//
//  Created by Ruben Nine on 11/9/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation
import FilestackSDK


struct UploadMonitorScene: Scene {

    var cancellableRequest: CancellableRequest?

    func configureViewController(_ viewController: UploadMonitorViewController) {

        // Inject the dependencies
        viewController.cancellableRequest = cancellableRequest
    }
}

class UploadMonitorViewController: UIViewController {

    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var cancelButton: UIButton!

    var cancellableRequest: CancellableRequest?


    // MARK: - View Overrides

    override func viewDidLoad() {

        progressView.progress = 0
    }


    // MARK: - Internal Functions

    func updateProgress(value: Float) {
        guard isViewLoaded else { return }
        progressView.progress = value
        cancelButton.isEnabled = progressView.progress < 1.0
    }


    // MARK: - Actions

    @IBAction func cancel(_ sender: AnyObject) {

        cancellableRequest?.cancel()
        self.dismiss(animated: true, completion: nil)
    }
}
