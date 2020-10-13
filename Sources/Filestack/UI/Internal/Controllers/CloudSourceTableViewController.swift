//
//  CloudSourceTableViewController.swift
//  Filestack
//
//  Created by Ruben Nine on 11/10/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Alamofire
import FilestackSDK
import UIKit

private extension String {
    static let cloudItemReuseIdentifier = "CloudItemTableViewCell"
    static let activityIndicatorReuseIdentifier = "ActivityIndicatorTableViewCell"
}

private let rowHeight: CGFloat = 52

class CloudSourceTableViewController: UITableViewController {
    @IBOutlet weak var searchBar: UISearchBar?
    private weak var dataSource: (CloudSourceDataSource)!

    // MARK: - View Overrides

    override func viewDidLoad() {
        super.viewDidLoad()

        // Get reference to data source
        if let dataSource = parent as? CloudSourceDataSource {
            self.dataSource = dataSource
        } else {
            fatalError("Parent must adopt the CloudSourceDataSource protocol.")
        }

        // Toggle search header on/off.
        if !dataSource.source.provider.searchBased {
            tableView.tableHeaderView = nil
        }

        // Setup refresh control if we have items
        if dataSource.items != nil {
            // Setup refresh control
            setupRefreshControl()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        tableView.reloadData()
        focusOnSearchBar()
    }

    override func viewWillDisappear(_ animated: Bool) {
        refreshControl?.endRefreshing()

        super.viewWillDisappear(animated)
    }
}

// MARK: - UITableViewDataSource Conformance

extension CloudSourceTableViewController {
    override func numberOfSections(in _: UITableView) -> Int {
        return 1
    }

    override func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:

            if let items = dataSource.items {
                return dataSource.nextPageToken == nil ? items.count : items.count + 1
            } else {
                return 1
            }

        default:

            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell

        // If there's no items, or we are one past the item count, then dequeue an activity indicator cell,
        // else dequeue a regular cloud item cell.
        if dataSource.items == nil || (indexPath.row == dataSource.items?.count) {
            cell = tableView.dequeueReusableCell(withIdentifier: .activityIndicatorReuseIdentifier, for: indexPath)
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: .cloudItemReuseIdentifier, for: indexPath)
        }

        switch cell {
        case let cell as ActivityIndicatorTableViewCell:

            cell.activityIndicator.startAnimating()

        case let cell as CloudItemTableViewCell:

            guard let item = dataSource.items?[safe: UInt(indexPath.row)] else { return cell }

            cell.textLabel?.text = item.name
            cell.textLabel?.isEnabled = dataSource.canSelect(item: item)

            if item.isFolder {
                cell.accessoryType = .disclosureIndicator
            } else {
                cell.accessoryType = .none
            }

            cell.imageView?.alpha = dataSource.canSelect(item: item) ? 1 : 0.25

            guard let cachedImage = dataSource.thumbnailCache.object(forKey: item.thumbnailURL as NSURL) else {
                // Use a placeholder until we get the real thumbnail
                cell.imageView?.image = UIImage(named: "placeholder", in: bundle, compatibleWith: nil)

                dataSource.cacheThumbnail(for: item, completionHandler: { image in
                    // Update the cell's thumbnail picture.
                    // To find the right cell to update, first we try using table view's `cellForRow(at:)`, which may
                    // or not return a cell. If it doesn't, we use collection view's `reloadRows(at:)` passing the index path
                    // for the cell.
                    // We should never update the cell we returned moments earlier directly since it may, have been reused
                    // to display a completely different item.
                    if let cell = tableView.cellForRow(at: indexPath) as? CloudItemTableViewCell {
                        cell.imageView?.image = image
                    } else {
                        tableView.reloadRows(at: [indexPath], with: .automatic)
                    }
                })

                return cell
            }

            cell.imageView?.image = cachedImage

        default:

            break
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return rowHeight
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return rowHeight
    }
}

// MARK: - UITableViewDelegate Conformance

extension CloudSourceTableViewController {
    override func tableView(_: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        guard let item = dataSource.items?[safe: UInt(indexPath.row)] else { return false }

        return dataSource.canSelect(item: item)
    }

    override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = dataSource.items?[safe: UInt(indexPath.row)] else { return }

        if item.isFolder {
            dataSource.navigate(to: item)
        } else {
            dataSource.store(item: item)
        }
    }

    override func tableView(_: UITableView, willDisplay _: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == dataSource.items?.count {
            dataSource.loadNextPage {
                self.tableView.reloadData()
            }
        }
    }
}

// MARK: - UISearchBarDelegate Conformance

extension CloudSourceTableViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchTerm = searchBar.text else { return }

        dataSource.search(text: searchTerm) {
            self.tableView.reloadData()
        }
    }
}

// MARK: - CloudSourceDataSourceConsumer Conformance

extension CloudSourceTableViewController: CloudSourceDataSourceConsumer {
    func dataSourceReceivedInitialResults(dataSource _: CloudSourceDataSource) {
        // Reload table view's data
        tableView.reloadData()
        // Setup refresh control
        setupRefreshControl()
    }
}

// MARK: - Actions

extension CloudSourceTableViewController {
    @IBAction func refresh(_: Any) {
        dataSource.refresh {
            self.refreshControl?.endRefreshing()
            self.tableView.reloadData()
        }
    }
}

// MARK: - Private Functions

private extension CloudSourceTableViewController {
    func setupRefreshControl() {
        guard refreshControl == nil else { return }

        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
    }

    func focusOnSearchBar() {
        searchBar?.becomeFirstResponder()
    }
}

