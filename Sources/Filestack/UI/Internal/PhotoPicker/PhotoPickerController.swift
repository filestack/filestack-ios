//
//  PhotoPickerController.swift
//  Filestack
//
//  Created by Mihály Papp on 23/05/2018.
//  Copyright © 2018 Filestack. All rights reserved.
//

import Photos
import UIKit

protocol PhotoPickerControllerDelegate: AnyObject {
    func photoPickerControllerDidCancel(controller: UINavigationController)
    func photoPicker(controller: UINavigationController, didSelectAssets assets: [PHAsset])
}

class PhotoPickerController {
    // MARK: - Internal Properties

    let albumRepository = PhotoAlbumRepository()
    let maximumSelectionAllowed: UInt
    var isMaximumLimitSet: Bool { maximumSelectionAllowed != Config.kMaximumSelectionNoLimit }
    var selectedAssets = Set<PHAsset>()

    weak var delegate: PhotoPickerControllerDelegate?

    var assetCollection: AssetCollectionViewController {
        let vc = viewController(with: "AssetCollectionViewController")

        guard let assetCollection = vc as? AssetCollectionViewController else {
            fatalError("AssetCollectionViewController type is corrupted")
        }

        assetCollection.pickerController = self

        return assetCollection
    }

    lazy var navigation = UINavigationController(rootViewController: albumList)

    var cancelBarButton: UIBarButtonItem {
        return UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismissWithoutSelection))
    }

    var rightBarItems: [UIBarButtonItem] {
        guard !selectedAssets.isEmpty else { return [] }

        return [selectionCountBarButton, doneBarButton]
    }

    var doneBarButton: UIBarButtonItem {
        return UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissWithSelection))
    }

    var selectionCountBarButton: UIBarButtonItem {
        let maximum = isMaximumLimitSet ? "/\(maximumSelectionAllowed)" : ""
        let title = "(\(selectedAssets.count)\(maximum))"

        return UIBarButtonItem(title: title, style: .done, target: self, action: #selector(dismissWithSelection))
    }

    // MARK: - Private Properties

    private lazy var albumList: AlbumListViewController = {
        let vc = viewController(with: "AlbumListViewController")

        guard let albumList = vc as? AlbumListViewController else {
            fatalError("AlbumListViewController type is corrupted")
        }

        albumList.pickerController = self

        return albumList
    }()


    // MARK: - Lifecycle

    init(maximumSelection: UInt) {
        maximumSelectionAllowed = maximumSelection

        albumRepository.getAlbums { _ in
            DispatchQueue.main.async {
                self.albumList.tableView.reloadData()
            }
        }
    }
}

// MARK: - Private Functions

private extension PhotoPickerController {
    func viewController(with name: String) -> UIViewController {
        let storyboard = UIStoryboard(name: "PhotoPicker", bundle: bundle)

        return storyboard.instantiateViewController(withIdentifier: name)
    }
}

// MARK: - Navigation Bar Actions

private extension PhotoPickerController {
    @objc func dismissWithSelection() {
        delegate?.photoPicker(controller: navigation, didSelectAssets: Array(selectedAssets))
    }

    @objc func dismissWithoutSelection() {
        delegate?.photoPickerControllerDidCancel(controller: navigation)
    }
}

// MARK: - AssetSelectionDelegate Conformance

extension PhotoPickerController: AssetSelectionDelegate {
    func add(asset: PHAsset) {
        selectedAssets.insert(asset)

        if maximumSelectionAllowed == 1 {
            dismissWithSelection()
        } else {
            updateNavBar()
        }
    }

    func remove(asset: PHAsset) {
        selectedAssets.remove(asset)
        updateNavBar()
    }

    func updateNavBar() {
        for vc in navigation.viewControllers {
            vc.navigationItem.rightBarButtonItems = rightBarItems
        }
    }
}
