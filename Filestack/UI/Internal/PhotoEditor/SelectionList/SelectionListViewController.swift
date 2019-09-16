//
//  SelectionListViewController.swift
//  EditImage
//
//  Created by Mihály Papp on 20/07/2018.
//  Copyright © 2018 Mihály Papp. All rights reserved.
//

import Photos
import UIKit

protocol UploadListDelegate: AnyObject {
    func resignFromUpload()
    func upload(_ elements: [SelectableElement])
}

class SelectionListViewController: UICollectionViewController {
    enum Mode {
        case edition
        case deletion
    }

    private var elements: [SelectableElement] = []
    private var config: Config
    private var mode: Mode = .edition
    private var markedToDelete: Set<Int> = []
    private weak var delegate: UploadListDelegate?

    init(assets: [PHAsset], config: Config, delegate: UploadListDelegate) {
        self.config = config

        for asset in assets {
            let element: SelectableElement = SelectableElement(asset: asset)

            element.imageExportQuality = config.imageExportQuality
            element.imageExportPreset = config.imageURLExportPreset
            element.videoExportPreset = config.videoExportPreset

            self.elements.append(element)
        }

        self.delegate = delegate
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
        setup()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView?.register(SelectionCell.self)

        if #available(iOS 13.0, *) {
            collectionView?.backgroundColor = .systemBackground
        } else {
            collectionView?.backgroundColor = .white
        }

        collectionView?.reloadData()
    }
}

// MARK: CollectionView User Triggered Events

extension SelectionListViewController {
    var numberOfCells: Int {
        return elements.count
    }

    func cellWasPressed(on row: Int) {
        switch mode {
        case .edition: edition(with: row)
        case .deletion: deletion(with: row)
        }
    }

    func cellWasLongPressed(on row: Int) {
        switch mode {
        case .deletion: break
        case .edition: startDeleteMode()
        }

        deletion(with: row)
    }

    func cellWasDisplayed(_ cell: SelectionCell, on row: Int) {
        cell.element = elements[row]

        switch mode {
        case .edition: cell.mode = .standard
        case .deletion: cell.mode = .deletion(markedToDelete: isMarketToDelete(row))
        }
    }
}

// MARK: ViewSetup

/// :nodoc:
private extension SelectionListViewController {
    func setup() {
        navigationItem.leftBarButtonItem = cancelItem
        navigationItem.rightBarButtonItem = uploadItem
    }

    var cancelItem: UIBarButtonItem {
        return UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonPressed))
    }

    var deleteItem: UIBarButtonItem {
        let item = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteButtonPressed))
        item.tintColor = .red
        item.isEnabled = false

        return item
    }

    var uploadItem: UIBarButtonItem {
        return UIBarButtonItem(image: .fromFilestackBundle("icon-upload"),
                               style: .plain,
                               target: self,
                               action: #selector(uploadButtonPressed))
    }

    @objc func uploadButtonPressed() {
        uploadAll()
    }

    @objc func deleteButtonPressed() {
        deleteAndRefresh()
    }

    @objc func cancelButtonPressed() {
        switch mode {
        case .edition: dismissAll()
        case .deletion: stopDeleteMode()
        }
    }
}

private extension SelectionListViewController {
    func uploadAll() {
        dismiss(animated: true) {
            self.delegate?.upload(self.elements)
        }
    }

    func dismissAll() {
        dismiss(animated: true) {
            self.delegate?.resignFromUpload()
        }
    }
}

private extension SelectionListViewController {
    func stopDeleteMode() {
        mode = .edition
        navigationItem.rightBarButtonItem = uploadItem
        markedToDelete = []
        updateAllVisibleCells()
    }

    func startDeleteMode() {
        mode = .deletion
        navigationItem.rightBarButtonItem = deleteItem

        allSelectionCells.forEach { cell in
            cell.mode = .deletion(markedToDelete: false)
        }
    }

    func deleteAndRefresh() {
        deleteSelected()

        UIView.animate(withDuration: 0.5, animations: {
            self.visibleCellsToDelete().forEach { cell in
                cell.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            }
        }, completion: { _ in
            DispatchQueue.main.async {
                self.stopDeleteMode()
                self.collectionView?.reloadData()
            }
        })
    }

    func deleteSelected() {
        elements = elements.enumerated().filter { (index, _) -> Bool in
            !markedToDelete.contains(index)
        }.map { (_, element) -> SelectableElement in
            element
        }
    }
}

private extension SelectionListViewController {
    func edition(with row: Int) {
        let element = elements[row]

        guard element.isEditable else { return }
        guard let image = element.editableImage else { return }

        let editor = EditorViewController(image: image) { editedImage in
            guard let editedImage = editedImage else { return }
            DispatchQueue.main.async {
                element.update(image: editedImage)
                self.collectionView?.reloadData()
            }
        }

        present(editor, animated: true)
    }

    func deletion(with row: Int) {
        if isMarketToDelete(row) {
            removeFromMarkedToDelete(row)
        } else {
            addToMarkedToDelete(row)
        }
        navigationItem.rightBarButtonItem?.isEnabled = markedToDelete.count > 0
    }

    func isMarketToDelete(_ row: Int) -> Bool {
        return markedToDelete.contains(row)
    }

    func addToMarkedToDelete(_ row: Int) {
        markedToDelete.insert(row)
        setMode(for: row)
    }

    func removeFromMarkedToDelete(_ row: Int) {
        markedToDelete.remove(row)
        setMode(for: row)
    }

    func setMode(for row: Int) {
        let cell = collectionView?.cellForItem(at: IndexPath(row: row, section: 0)) as? SelectionCell
        setMode(for: cell)
    }

    func setMode(for cell: SelectionCell?) {
        guard let cell = cell, let indexPath = collectionView?.indexPath(for: cell) else { return }
        switch mode {
        case .edition: cell.mode = .standard
        case .deletion: cell.mode = .deletion(markedToDelete: isMarketToDelete(indexPath.row))
        }
    }
}

extension SelectionListViewController {
    override func scrollViewDidScroll(_: UIScrollView) {
        updateAllVisibleCells()
    }

    func updateAllVisibleCells() {
        allSelectionCells.forEach { self.setMode(for: $0) }
    }

    func visibleCellsToDelete() -> [SelectionCell] {
        guard let collectionView = collectionView else {
            return []
        }
        return allSelectionCells.filter { (cell) -> Bool in
            if let index = collectionView.indexPath(for: cell) {
                return markedToDelete.contains(index.row)
            }
            return false
        }
    }

    var allSelectionCells: [SelectionCell] {
        return collectionView?.visibleCells as? [SelectionCell] ?? []
    }
}
