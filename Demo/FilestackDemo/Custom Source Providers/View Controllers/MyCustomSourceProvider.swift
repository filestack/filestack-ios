//
//  UnsplashSourceProvider.swift
//  MyCustomSourceProvider
//
//  Created by Ruben Nine on 2/8/21.
//  Copyright © 2021 Filestack. All rights reserved.
//

import UIKit
import Filestack
import FilestackSDK

/// Sample `SourceProvider` implementation that presents a collection made of 5 images that may be interactively
/// picked by the user.
///
/// Picked images will be uploaded to Filestack if user presses the `Upload` button, or cancelled if the `Cancel` button
/// is pressed instead.
class MyCustomSourceProvider: UICollectionViewController, SourceProvider {
    // MARK: - Public Properties

    weak var sourceProviderDelegate: SourceProviderDelegate?
    var availableURLs: [URL] = []

    // MARK: - Private Properties

    private let customCellID = "customCellID"
    private var cellSpacing: CGFloat = 5
    private var cellSize = CGSize(width: 100, height: 100)

    private var urls: Set<URL> = Set<URL>() {
        didSet { updateUploadButton() }
    }

    private lazy var cancelBarButton: UIBarButtonItem = {
        UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancel))
    }()

    private lazy var uploadBarButton: UIBarButtonItem = {
        UIBarButtonItem(title: "Upload", style: .plain, target: self, action: #selector(upload))
    }()

    // MARK: - Lifecycle

    required init() {
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Actions

extension MyCustomSourceProvider {
    @objc func upload() {
        let urls = Array(urls)

        dismiss(animated: true) {
            self.sourceProviderDelegate?.sourceProviderPicked(urls: urls)
        }
    }

    @objc func cancel() {
        dismiss(animated: true) {
            self.sourceProviderDelegate?.sourceProviderCancelled()
        }
    }
}

// MARK: - Private Functions

private extension MyCustomSourceProvider {
    func updateUploadButton() {
        uploadBarButton.title = "Upload (\(urls.count)/\(availableURLs.count))"
    }
}

// MARK: - View Overrides

extension MyCustomSourceProvider {
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem = cancelBarButton
        navigationItem.rightBarButtonItem = uploadBarButton

        collectionView?.backgroundColor = UIColor.black
        collectionView?.register(CustomCell.self, forCellWithReuseIdentifier: customCellID)
        collectionView?.allowsMultipleSelection = true

        updateUploadButton()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        urls.removeAll()
        collectionView.reloadData()
    }
}

// MARK: - UICollectionViewDelegate Protocol

extension MyCustomSourceProvider {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return availableURLs.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: customCellID,
                                                      for: indexPath) as! CustomCell

        cell.imageView.image = UIImage(contentsOfFile: availableURLs[indexPath.item].path)

        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        urls.insert(availableURLs[indexPath.item])
    }

    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        urls.remove(availableURLs[indexPath.item])
    }
}

// MARK: - UICollectionViewDelegateFlowLayout Protocol

extension MyCustomSourceProvider: UICollectionViewDelegateFlowLayout {
    func collectionView(_: UICollectionView,
                        layout _: UICollectionViewLayout,
                        insetForSectionAt _: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: cellSpacing, left: cellSpacing, bottom: cellSpacing, right: cellSpacing)
    }

    func collectionView(_: UICollectionView,
                        layout _: UICollectionViewLayout,
                        sizeForItemAt _: IndexPath) -> CGSize {
        cellSize
    }

    func collectionView(_: UICollectionView,
                        layout _: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt _: Int) -> CGFloat {
        cellSpacing
    }

    func collectionView(_: UICollectionView,
                        layout _: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt _: Int) -> CGFloat {
        cellSpacing
    }
}
