//
//  AssetCollectionViewController.swift
//  Filestack
//
//  Created by Mihály Papp on 04/06/2018.
//  Copyright © 2018 Filestack. All rights reserved.
//

import Photos
import UIKit

protocol AssetSelectionDelegate {
    func add(asset: PHAsset)
    func remove(asset: PHAsset)
}

class AssetCollectionViewController: UICollectionViewController {
    weak var pickerController: PhotoPickerController?

    var elements: [PHAsset]?
    var shouldScrollDown: Bool = true

    var selectedAssets: Set<PHAsset>? {
        return pickerController?.selectedAssets
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.rightBarButtonItems = pickerController?.rightBarItems
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if shouldScrollDown {
            shouldScrollDown = false
            let lastItem = IndexPath(item: collectionView.numberOfItems(inSection: 0) - 1, section: 0)
            collectionView.scrollToItem(at: lastItem, at: .top, animated: false)
        }
    }

    func configure(with album: Album) {
        title = album.title
        elements = album.elements
    }
}

extension AssetCollectionViewController {
    func setupView() {
        collectionView?.contentInsetAdjustmentBehavior = .always
        collectionView?.collectionViewLayout = CollectionViewFlowLayout()
    }
}

extension AssetCollectionViewController {
    override func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return elements?.count ?? 0
    }

    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AssetCell",
                                                            for: indexPath) as? AssetCell else {
            return UICollectionViewCell()
        }
        let asset = elements![indexPath.row]
        let isSelected = selectedAssets?.contains(asset) ?? false
        cell.configure(for: asset, isSelected: isSelected)
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let asset = elements![indexPath.row]
        let isSelecting = !(selectedAssets?.contains(asset) ?? true)
        let cell = collectionView.cellForItem(at: indexPath) as! AssetCell
        if isSelecting, maximumReached {
            return
        }
        cell.set(selected: isSelecting)

        if let pickerController = pickerController {
            isSelecting ? pickerController.add(asset: asset) : pickerController.remove(asset: asset)
        }
    }
}

extension AssetCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_: UICollectionView,
                        layout _: UICollectionViewLayout,
                        insetForSectionAt _: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: cellSpacing, left: cellSpacing, bottom: cellSpacing, right: cellSpacing)
    }

    func collectionView(_: UICollectionView,
                        layout _: UICollectionViewLayout,
                        sizeForItemAt _: IndexPath) -> CGSize {
        return cellSize
    }

    func collectionView(_: UICollectionView,
                        layout _: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt _: Int) -> CGFloat {
        return cellSpacing
    }

    func collectionView(_: UICollectionView,
                        layout _: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt _: Int) -> CGFloat {
        return cellSpacing
    }
}

/// :nodoc:
private extension AssetCollectionViewController {
    var cellSize: CGSize {
        return CGSize(width: cellSide, height: cellSide)
    }

    var cellSide: CGFloat {
        let totalSpacing = cellSpacing * (columnsCount + 1)
        return (totalWidth - totalSpacing) / columnsCount
    }

    var totalWidth: CGFloat {
        return view.safeAreaLayoutGuide.layoutFrame.width
    }

    var columnsCount: CGFloat {
        return (totalWidth / targetSide).rounded(.down)
    }

    var targetSide: CGFloat {
        return 100.0
    }

    var cellSpacing: CGFloat {
        return 6
    }

    var maximumReached: Bool {
        if let pickerController = pickerController, let selectedAssets = selectedAssets {
            return pickerController.isMaximumLimitSet && selectedAssets.count >= pickerController.maximumSelectionAllowed
        } else {
            return true
        }
    }
}
