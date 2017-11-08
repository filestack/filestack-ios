//
//  SourceTableViewController.swift
//  Filestack
//
//  Created by Ruben Nine on 11/7/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import UIKit


internal class SourceTableViewController: UITableViewController {

    private let defaultSectionHeaderHeight: CGFloat = 32
    private let localSources = LocalSource.all()

    private var cloudSources = CloudSource.all().filter { $0 != .customSource }
    private var filestack: Filestack? = nil
    private var customSourceName: String? = nil
    private var useCustomSource: Bool = false


    // MARK: - View Overrides

    public override func viewDidLoad() {

        super.viewDidLoad()

        // Try to obtain `Filestack` object from navigation controller
        if let navigationController = navigationController as? FilestackNavigationController {
            guard let filestack = navigationController.filestack else { return }

            // Keep a reference to the `Filestack` object so we can use it later.
            self.filestack = filestack

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
        var source: CellDescriptibleSource?

        switch indexPath.section {
        case 0:

            source = localSources[indexPath.row]

        case 1:

            source = cloudSources[indexPath.row]

        default:

            break
        }

        if let source = source {
            if source == CloudSource.customSource && useCustomSource {
                cell.textLabel?.text = customSourceName ?? source.description
            } else {
                cell.textLabel?.text = source.description
            }

            cell.imageView?.image = UIImage(named: source.iconName, in: Bundle(for: classForCoder), compatibleWith: nil)
        }

        return cell
    }


    // MARK: - Actions

    @IBAction func cancel(_ sender: AnyObject?) {

        dismiss(animated: true)
    }
}
