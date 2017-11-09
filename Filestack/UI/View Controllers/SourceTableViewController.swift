//
//  SourceTableViewController.swift
//  Filestack
//
//  Created by Ruben Nine on 11/7/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import UIKit
import FilestackSDK


internal class SourceTableViewController: UITableViewController {

    private let defaultSectionHeaderHeight: CGFloat = 32
    private let localSources = LocalSource.all()

    private var cloudSources = CloudSource.all().filter { $0 != .customSource }
    private var filestack: Filestack!
    private var storeOptions: StorageOptions!
    private var customSourceName: String? = nil
    private var useCustomSource: Bool = false
    private weak var uploadMonitorViewController: UploadMonitorViewController?


    // MARK: - View Overrides

    public override func viewDidLoad() {

        super.viewDidLoad()

        // Try to obtain `Filestack` object from navigation controller
        if let navigationController = navigationController as? FilestackNavigationController {
            // Keep a reference to the `Filestack` object so we can use it later.
            self.filestack = navigationController.filestack
            // Keep a reference to the `StoreOptions` object so we can use it later.
            self.storeOptions = navigationController.storeOptions

            // Fetch configuration info from the API — don't care if it fails.
            filestack.prefetch { (response) in
                guard let contents = response.contents else { return }

                // Custom source enabled?
                self.useCustomSource = contents["customsource"] as? Bool ?? false
                // Try to obtain custom source name
                self.customSourceName = contents["customsource_name"] as? String

                if self.useCustomSource {
                    self.cloudSources = CloudSource.all()
                }

                self.tableView.reloadData()
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if let destination = segue.destination as? UploadMonitorViewController {
            self.uploadMonitorViewController = destination

            if let mpu = sender as? MultipartUpload {
                destination.mpu = mpu
            }
        }
    }


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {

        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        switch section {
        case 0:

            return localSources.count

        case 1:

            return cloudSources.count

        default:

            return 0
        }
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {

        switch section {
        case 0:

            return localSources.count > 0 ? defaultSectionHeaderHeight : 0

        case 1:

            return cloudSources.count > 0 ? defaultSectionHeaderHeight : 0

        default:

            return 0
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

        switch section {
        case 0:

            return LocalSource.title()

        case 1:

            return CloudSource.title()

        default:

            return nil
        }

    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "sourceTVC", for: indexPath)

        guard let source = source(from: indexPath) else { return cell }

        if source == CloudSource.customSource && useCustomSource {
            cell.textLabel?.text = customSourceName ?? source.description
        } else {
            cell.textLabel?.text = source.description
        }

        cell.imageView?.image = UIImage(named: source.iconName, in: Bundle(for: classForCoder), compatibleWith: nil)

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        guard let source = source(from: indexPath) else { return }

        switch source {
        case LocalSource.camera:

            upload(sourceType: .camera)

        case LocalSource.photoLibrary:

            upload(sourceType: .photoLibrary)

        default:

            fatalError("Not yet implemented.")
        }
    }


    // MARK: - Private Functions

    private func upload(sourceType: UIImagePickerControllerSourceType) {

        var mpu: MultipartUpload? = nil

        // Disable user interaction on this view until the file is picked and uploaded.
        // We want to prevent any taps from happening during the short timeframe between tapping the local source
        // and the time the picker is presented on the screen.
        view.isUserInteractionEnabled = false

        mpu = filestack.uploadFromImagePicker(viewController: self,
                                              sourceType: sourceType,
                                              storeOptions: storeOptions,
                                              uploadProgress: { (progress) in
                                                // Present upload monitor (if not already presented)
                                                if self.uploadMonitorViewController == nil {
                                                    self.performSegue(withIdentifier: "uploadMonitor", sender: mpu)
                                                }

                                                // Send progress update to upload monitor
                                                let fractionCompleted = Float(progress.fractionCompleted)
                                                self.uploadMonitorViewController?.updateProgress(value: fractionCompleted)
        },
                                              completionHandler: { (response) in
                                                // Upon completion, re-enable user interaction...
                                                self.view.isUserInteractionEnabled = true

                                                // ... and dismiss monitor view (if present)
                                                self.uploadMonitorViewController?.dismiss(animated: true) {
                                                    self.uploadMonitorViewController = nil
                                                }

                                                // Finally, nil the reference to the `MultipartUpload` object, so the
                                                // object can be properly deallocated.
                                                mpu = nil
        })
    }

    private func source(from indexPath: IndexPath) -> CellDescriptibleSource? {

        switch indexPath.section {
        case 0:

            return localSources[indexPath.row]

        case 1:

            return cloudSources[indexPath.row]

        default:

            return nil
        }
    }


    // MARK: - Actions

    @IBAction func cancel(_ sender: AnyObject?) {

        dismiss(animated: true)
    }
}
