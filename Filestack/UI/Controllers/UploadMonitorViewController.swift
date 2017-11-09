//
//  UploadMonitorViewController.swift
//  Filestack
//
//  Created by Ruben Nine on 11/9/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation
import FilestackSDK


internal class UploadMonitorViewController: UIViewController {

    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var cancelButton: UIButton!

    weak var mpu: MultipartUpload?


    // MARK: - Internal Functions

    func updateProgress(value: Float) {

        progressView.progress = value
        cancelButton.isEnabled = progressView.progress < 1.0
    }


    // MARK: - Actions

    @IBAction func cancel(_ sender: AnyObject) {

        mpu?.cancel()
        self.dismiss(animated: true, completion: nil)
    }
}
