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

    private var localSources = [LocalSource]()
    private var cloudSources = [CloudSource]()

    private var client: Client!
    private var storeOptions: StorageOptions!
    private var customSourceName: String? = nil
    private var useCustomSource: Bool = false

    private weak var uploadMonitorViewController: UploadMonitorViewController?


    // MARK: - View Overrides

    public override func viewDidLoad() {

        super.viewDidLoad()

        // Setup cancel button in navigation bar
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancel))
        navigationItem.rightBarButtonItem = cancelButton

        // Try to obtain `Client` object from navigation controller
        if let navigationController = navigationController as? PickerNavigationController {
            // Keep a reference to the `Client` object so we can use it later.
            self.client = navigationController.client
            // Keep a reference to the `StoreOptions` object so we can use it later.
            self.storeOptions = navigationController.storeOptions

            // Get available local sources from config
            self.localSources = client.config.availableLocalSources

            // Get available cloud sources from config, but discard "custom source" (if present)
            // We will add it later, only if it is actually enabled in the Developer Portal.
            self.cloudSources = client.config.availableCloudSources.filter { $0 != .customSource }

            let wantsToPresentCustomSource = client.config.availableCloudSources.contains(.customSource)

            // Fetch configuration info from the API — don't care if it fails.
            client.prefetch { (response) in
                guard let contents = response.contents else { return }

                // Custom source enabled?
                self.useCustomSource = contents["customsource"] as? Bool ?? false
                // Try to obtain custom source name
                self.customSourceName = contents["customsource_name"] as? String

                if self.useCustomSource && wantsToPresentCustomSource {
                    self.cloudSources.append(.customSource)
                }

                // Refresh the table view
                self.tableView.reloadSections([1], with: .automatic)
            }
        }
    }


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return localSources.count
        case 1: return cloudSources.count
        default: return 0
        }
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0: return localSources.count > 0 ? defaultSectionHeaderHeight : 0
        case 1: return cloudSources.count > 0 ? defaultSectionHeaderHeight : 0
        default: return 0
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return LocalSource.title()
        case 1: return CloudSource.title()
        default: return nil
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
        cell.accessoryType = .disclosureIndicator
        cell.imageView?.image = UIImage(named: source.iconName, in: Bundle(for: type(of: self)), compatibleWith: nil)

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let source = source(from: indexPath) else { return }

        switch source {
        case LocalSource.camera:
            upload(sourceType: .camera)
        case LocalSource.photoLibrary:
            upload(sourceType: .photoLibrary)
        case LocalSource.documents:
            upload()
        case let cloudSource as CloudSource:
            // Try to retrieve store view type from user defaults, or default to "list"
            let viewType = UserDefaults.standard.cloudSourceViewType() ?? .list
            // Navigate to given cloud's "/" path
            let scene = CloudSourceTabBarScene(client: client,
                                               storeOptions: storeOptions,
                                               source: cloudSource,
                                               customSourceName: customSourceName,
                                               path: nil,
                                               nextPageToken: nil,
                                               viewType: viewType)

            if let vc = storyboard?.instantiateViewController(for: scene) {
                navigationController?.pushViewController(vc, animated: true)
            }
        default:
            break
        }
    }

    // MARK: - Actions
    
    @IBAction func cancel(_ sender: AnyObject?) {
        
        dismiss(animated: true)
    }
    
    // MARK: - Private Functions
}

private extension SourceTableViewController {
    func upload(sourceType: UIImagePickerControllerSourceType? = nil) {
        var cancellableRequest: CancellableRequest? = nil

        // Disable user interaction on this view until the file is picked and uploaded.
        // We want to prevent any taps from happening during the short timeframe between tapping the local source
        // and the time the picker is presented on the screen.
        view.isUserInteractionEnabled = false

        let uploadProgressHandler: ((Progress) -> Void) = { (progress) in
            // Present upload monitor (if not already presented)
            if self.uploadMonitorViewController == nil {
                let scene = UploadMonitorScene(cancellableRequest: cancellableRequest)
                if let vc = self.storyboard?.instantiateViewController(for: scene) {
                    vc.modalPresentationStyle = self.client.config.modalPresentationStyle
                    self.uploadMonitorViewController = vc
                    self.present(vc, animated: true, completion: nil)
                }
            }

            // Send progress update to upload monitor
            let fractionCompleted = Float(progress.fractionCompleted)
            self.uploadMonitorViewController?.updateProgress(value: fractionCompleted)
        }

        let completionHandler: (([NetworkJSONResponse]) -> Void) = { (responses) in
            // Nil the reference to the request object, so the object can be properly deallocated.
            cancellableRequest = nil
            // Re-enable user interaction.
            self.view.isUserInteractionEnabled = true
          
          // Verify responses are available
          guard responses.count > 0 else {
              return
          }

          let errors = responses.compactMap { $0.error }
          if let error = errors.first {
              self.showErrorAlert(message: error.localizedDescription)
          } else {
              self.dismissMonitorViewController()
          }

          if let picker = self.navigationController as? PickerNavigationController {
              picker.pickerDelegate?.pickerUploadedFiles(picker: picker, responses: responses)
          }
        }

        if let sourceType = sourceType {
            cancellableRequest = client.uploadFromImagePicker(viewController: self,
                                                              sourceType: sourceType,
                                                              storeOptions: storeOptions,
                                                              uploadProgress: uploadProgressHandler,
                                                              completionHandler: completionHandler)
        } else {
            cancellableRequest = client.uploadFromDocumentPicker(viewController: self,
                                                                 storeOptions: storeOptions,
                                                                 uploadProgress: uploadProgressHandler,
                                                                 completionHandler: completionHandler)
        }
    }

    func source(from indexPath: IndexPath) -> CellDescriptibleSource? {
        switch indexPath.section {
        case 0: return localSources[indexPath.row]
        case 1: return cloudSources[indexPath.row]
        default: return nil
        }
    }

    func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Upload Failed", message: description, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            self.dismissMonitorViewController()
        }))
        uploadMonitorViewController?.present(alert, animated: true)
    }
    
    func dismissMonitorViewController() {
        uploadMonitorViewController?.dismiss(animated: true) {
            self.uploadMonitorViewController = nil
        }
    }

}
