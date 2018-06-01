//
//  AlbumListViewController.swift
//  Filestack
//
//  Created by Mihály Papp on 23/05/2018.
//  Copyright © 2018 Filestack. All rights reserved.
//

import UIKit

class AlbumListViewController: UITableViewController {
  private var activityIndicator: UIActivityIndicatorView?
  
  private var albumList = [Album]()
  var pickerController: PhotoPickerController!
  var repository: PhotoAlbumRepository {
    return pickerController.albumRepository
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupView()
  }  
}

private extension AlbumListViewController {
  func setupView() {
    setupNavigation()
    configureAndShowEmptyTableView()
    createAndStartLaodingView()
    fetchData()
  }
  
  func setupNavigation() {
    navigationItem.leftBarButtonItem = pickerController.cancelBarButton
    navigationItem.rightBarButtonItems = pickerController.rightBarItems
  }
}

extension AlbumListViewController {
  func set(_ albums: [Album]) {
    albumList = albums
    stopLoading()
    if albumList.count > 0 {
      configureTableViewWithContent()
    }
    DispatchQueue.main.async {
      self.tableView.reloadData()
    }
  }
  
  func fetchData() {
    repository.getAlbums { albums in self.set(albums) }
  }
}

// MARK: - Empty Table
private extension AlbumListViewController {
  func configureAndShowEmptyTableView() {
    DispatchQueue.main.async {
      self.tableView.backgroundView = UIView(frame: self.tableView.frame)
      self.tableView.backgroundView?.backgroundColor = .white
      self.tableView.separatorStyle = .none
    }
  }
  
  func configureTableViewWithContent() {
    DispatchQueue.main.async {
      self.tableView.separatorStyle = .singleLine
    }
  }
}

// MARK: - Loading Indicator
private extension AlbumListViewController {
  func createAndStartLaodingView() {
    DispatchQueue.main.async {
      let indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
      indicator.center = self.view.center
      indicator.startAnimating()
      self.view.addSubview(indicator)
      self.activityIndicator = indicator
    }
  }
  
  func stopLoading() {
    DispatchQueue.main.async {
      self.activityIndicator?.stopAnimating()
      self.activityIndicator?.removeFromSuperview()
    }
  }
}

// MARK: - TableView Delegate & DataSource
extension AlbumListViewController {
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return albumList.count
  }
  
  override func tableView(_ tableView: UITableView,
                          cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "AlbumCell") as? AlbumCell else {
      return UITableViewCell()
    }
    let album = albumList[indexPath.row]
    cell.configure(for: album)
    return cell
  }
  
  override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    return UIView()
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let album = albumList[indexPath.row]
    let collectionView = pickerController.assetCollection
    collectionView.configure(with: album)
    self.navigationController?.pushViewController(collectionView, animated: true)
  }
}
