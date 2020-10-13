//
//  CloudSourceCollectionViewController.swift
//  Filestack
//
//  Created by Ruben Nine on 11/17/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Alamofire
import FilestackSDK
import UIKit

private extension String {
    static let cloudItemReuseIdentifier = "CloudItemCollectionViewCell"
    static let activityIndicatorReuseIdentifier = "ActivityIndicatorCollectionViewCell"
    static let headerID = "SearchView"
}

class CloudSourceCollectionViewController: UICollectionViewController {
    private weak var dataSource: (CloudSourceDataSource)!
    private var refreshControl: UIRefreshControl?

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
            (collectionViewLayout as? UICollectionViewFlowLayout)?.headerReferenceSize = .zero
        }

        // Setup refresh control if we have items
        if dataSource.items != nil {
            setupRefreshControl()
        }

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        collectionView!.reloadData()

        if dataSource.source.provider.searchBased {
            focusOnSearchBar()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        refreshControl?.endRefreshing()

        super.viewWillDisappear(animated)
    }
}

// MARK: - UICollectionViewDataSource Conformance

extension CloudSourceCollectionViewController {
    override func numberOfSections(in _: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_: UICollectionView, numberOfItemsInSection section: Int) -> Int {
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

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell: UICollectionViewCell

        // If there's no items, or we are one past the item count, then dequeue an activity indicator cell,
        // else dequeue a regular cloud item cell.
        if dataSource.items == nil || (indexPath.row == dataSource.items?.count) {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: .activityIndicatorReuseIdentifier, for: indexPath)
        } else {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: .cloudItemReuseIdentifier, for: indexPath)
        }

        switch cell {
        case let cell as ActivityIndicatorCollectionViewCell:
            cell.activityIndicator.startAnimating()
        case let cell as CloudItemCollectionViewCell:
            guard let item = dataSource.items?[safe: UInt(indexPath.row)] else { return cell }

            // Configure the cell
            cell.label.text = item.name
            cell.label.isEnabled = dataSource.canSelect(item: item)

            cell.imageView?.alpha = dataSource.canSelect(item: item) ? 1 : 0.25

            guard let cachedImage = dataSource.thumbnailCache.object(forKey: item.thumbnailURL as NSURL) else {
                // Use a placeholder until we get the real thumbnail
                cell.imageView?.image = UIImage(named: "placeholder",
                                                in: bundle,
                                                compatibleWith: nil)

                dataSource.cacheThumbnail(for: item) { image in
                    // Update the cell's thumbnail picture.
                    // To find the right cell to update, first we try using collection view's `cellForItem(at:)`,
                    // which may or not return a cell. If it doesn't, we use collection view's `reloadItems(at:)`
                    // passing the index path for the cell.
                    // We should never update the cell we returned moments earlier directly since it may, have been
                    // reused to display a completely different item.
                    if let cell = self.collectionView!.cellForItem(at: indexPath) as? CloudItemCollectionViewCell {
                        cell.imageView?.image = image
                    } else {
                        self.collectionView!.reloadItems(at: [indexPath])
                    }
                }

                return cell
            }

            cell.imageView?.image = cachedImage
        default:
            break
        }

        return cell
    }

    override func collectionView(_: UICollectionView, willDisplay _: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == dataSource.items?.count {
            dataSource.loadNextPage {
                self.collectionView!.reloadData()
            }
        }
    }

    override func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource.items?[safe: UInt(indexPath.row)] else { return }

        if item.isFolder {
            dataSource.navigate(to: item)
        } else {
            dataSource.store(item: item)
        }
    }

    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                         withReuseIdentifier: .headerID,
                                                                         for: indexPath)
        return headerView
    }

    override func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath) {

        if view.reuseIdentifier == .headerID {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                guard let subview = view.subviews.first, !subview.isFirstResponder else { return }
                subview.becomeFirstResponder()
            }
        }
    }
}

// MARK: - UICollectionViewDelegate Conformance

extension CloudSourceCollectionViewController {
    override func collectionView(_: UICollectionView, shouldHighlightItemAt _: IndexPath) -> Bool {
        return true
    }

    override func collectionView(_: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard let item = dataSource.items?[safe: UInt(indexPath.row)] else { return false }

        if dataSource.canSelect(item: item) {
            return true
        } else {
            return false
        }
    }
}

// MARK: - UISearchBarDelegate Conformance

extension CloudSourceCollectionViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchTerm = searchBar.text else { return }

        dataSource.search(text: searchTerm) {
            self.collectionView!.reloadData()
        }
    }
}

// MARK: - CloudSourceDataSourceConsumer Conformance

extension CloudSourceCollectionViewController: CloudSourceDataSourceConsumer {
    func dataSourceReceivedInitialResults(dataSource _: CloudSourceDataSource) {
        // Reload collection view's data
        collectionView!.reloadData()
        // Setup refresh control
        setupRefreshControl()
    }
}

// MARK: - Actions

extension CloudSourceCollectionViewController {

    @IBAction func refresh(_: Any) {
        dataSource.refresh {
            self.refreshControl?.endRefreshing()
            self.collectionView!.reloadData()
        }
    }
}

// MARK: - Private Functions

private extension CloudSourceCollectionViewController {
    func setupRefreshControl() {
        guard refreshControl == nil else { return }

        refreshControl = UIRefreshControl()

        if let refreshControl = refreshControl {
            refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
            collectionView!.addSubview(refreshControl)
            collectionView!.alwaysBounceVertical = true
        }
    }

    func focusOnSearchBar() {
        let views = collectionView!.visibleSupplementaryViews(ofKind: UICollectionView.elementKindSectionHeader)

        if let searchBar = (views.first?.subviews.first as? UISearchBar) {
            searchBar.becomeFirstResponder()
        }
    }
}

