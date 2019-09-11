//
//  SelectionListViewController+UICollectionView.swift
//  EditImage
//
//  Created by Mihály Papp on 26/07/2018.
//  Copyright © 2018 Mihály Papp. All rights reserved.
//

import UIKit

extension SelectionListViewController {
    override func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return numberOfCells
    }

    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.reuse(SelectionCell.self, for: indexPath) else { return UICollectionViewCell() }
        cellWasDisplayed(cell, on: indexPath.row)
        return cell
    }

    override func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        cellWasPressed(on: indexPath.row)
    }
}

// MARK: LongPress handling

extension SelectionListViewController {
    override func collectionView(_: UICollectionView,
                                 shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        cellWasLongPressed(on: indexPath.row)
        return true
    }

    override func collectionView(_: UICollectionView,
                                 canPerformAction _: Selector,
                                 forItemAt _: IndexPath,
                                 withSender _: Any?) -> Bool {
        return false
    }

    override func collectionView(_: UICollectionView,
                                 performAction _: Selector,
                                 forItemAt _: IndexPath,
                                 withSender _: Any?) {
        return
    }
}
