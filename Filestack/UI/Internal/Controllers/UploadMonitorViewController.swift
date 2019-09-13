//
//  UploadMonitorViewController.swift
//  Filestack
//
//  Created by Ruben Nine on 11/9/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import FilestackSDK
import Foundation

final class UploadMonitorViewController: UIViewController {
    @IBOutlet var progressView: UIProgressView!
    @IBOutlet var cancelButton: UIButton!
    @IBOutlet var messageLabel: UILabel!

    var cancellableRequest: CancellableRequest?

    override func viewDidLoad() {
        super.viewDidLoad()
        progressView.progress = 0
    }

    func update(progress: Progress) {
        guard isViewLoaded else { return }

        progressView.progress = Float(progress.fractionCompleted)
        updateLabel(using: progress)

        cancelButton.isEnabled = progressView.progress < 1.0
    }

    @IBAction func cancel(_: AnyObject) {
        cancellableRequest?.cancel()
    }

    private func updateLabel(using progress: Progress) {
        if progress.totalUnitCount > 1 {
            messageLabel.text = "Uploaded \(progress.completedUnitCount) of \(progress.totalUnitCount) files to storage location"
        } else {
            messageLabel.text = "Uploading file to storage location"
        }
    }
}
