//
//  CloudSourceDetailTableViewController.swift
//  Filestack
//
//  Created by Ruben Nine on 11/10/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import UIKit
import Alamofire
import FilestackSDK


struct CloudSourceDetailScene: Scene {

    let filestack: Filestack
    let source: CloudSource
    let storeOptions: StorageOptions

    var pageToken: String? = nil
    var path: String? = nil

    func configureViewController(_ viewController: CloudSourceDetailTableViewController) {

        // Inject the dependencies
        viewController.filestack = filestack
        viewController.source = source
        viewController.path = path ?? "/"
        viewController.pageToken = pageToken
        viewController.storeOptions = storeOptions
    }
}


class CloudSourceDetailTableViewController: UITableViewController {

    var filestack: Filestack!
    var source: CloudSource!
    var path: String!
    var pageToken: String?
    var storeOptions: StorageOptions!

    private var items: [CloudItem]? = nil
    private var currentRequest: CancellableRequest?

    private let thumbnailCache: NSCache<NSURL, UIImage> = {

        let cache = NSCache<NSURL, UIImage>()

        cache.countLimit = 2000

        return cache
    }()

    private var thumbnailRequests: [DataRequest] = [DataRequest]()

    private weak var uploadMonitorViewController: UploadMonitorViewController?


    // MARK: - View Overrides

    override func viewDidLoad() {

        super.viewDidLoad()

        title = source.description

        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancel))

        navigationItem.backBarButtonItem = backButton
        navigationItem.rightBarButtonItem = cancelButton

        currentRequest = requestFolderList(source: source, path: path) { (response) in
            self.currentRequest = nil

            if response.error != nil {
                self.navigationController?.popViewController(animated: true)
                return
            }

            guard let contents = response.contents else { return }

            let items = contents.flatMap { CloudItem(dictionary: $0) }

            self.items = items
            self.pageToken = response.nextToken
            self.tableView.reloadData()

            self.refreshControl = UIRefreshControl()
            self.refreshControl?.addTarget(self, action: #selector(self.refresh), for: UIControlEvents.valueChanged)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {

        refreshControl?.endRefreshing()
        currentRequest?.cancel()
        cancelPendingThumbnailRequests()

        super.viewWillDisappear(animated)
    }


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {

        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        switch section {
        case 0:

            if let items = items {
                return pageToken == nil ? items.count : items.count + 1
            } else {
                return 1
            }

        default:

            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let items = items else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "activityIndicatorTVC", for: indexPath) as! ActivityIndicatorTableViewCell

            cell.activityIndicator.startAnimating()

            return cell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: "sourceDetailTVC", for: indexPath)

        guard let item = items[safe: UInt(indexPath.row)] else { return cell }

        cell.textLabel?.text = item.name

        if item.isFolder {
            cell.accessoryType = .disclosureIndicator
        } else {
            cell.accessoryType = .none
        }

        guard let cachedImage = thumbnailCache.object(forKey: item.thumbnailURL as NSURL) else {
            loadThumbnail(for: item, into: cell)

            return cell
        }

        cell.imageView?.image = cachedImage

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        guard let item = items?[safe: UInt(indexPath.row)] else { return }

        if item.isFolder {
            let scene = CloudSourceDetailScene(filestack: filestack,
                                               source: source,
                                               storeOptions: storeOptions,
                                               pageToken: nil,
                                               path: item.path)

            if let vc = storyboard?.instantiateViewController(for: scene) {
                navigationController?.pushViewController(vc, animated: true)
            }
        } else {
            // Store at destination store location
            self.store(item: item)
        }
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {

        if indexPath.row == items?.count && currentRequest == nil {
            loadNextPage()
        }
    }


    // MARK - Actions

    @IBAction func cancel(_ sender: Any) {

        dismiss(animated: true)
    }

    @IBAction func refresh(_ sender: Any) {

        guard currentRequest == nil else { return }

        currentRequest = requestFolderList(source: source, path: path) { (response) in
            self.currentRequest = nil

            guard let contents = response.contents else { return }
            let items = contents.flatMap { CloudItem(dictionary: $0) }

            self.items = items
            self.pageToken = response.nextToken
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
        }
    }

    // MARK - Private Functions

    func requestFolderList(source: CloudSource,
                           path: String,
                           pageToken: String? = nil,
                           completionHandler: @escaping FolderListCompletionHandler) -> CancellableRequest {

        cancelPendingThumbnailRequests()

        return filestack.folderList(provider: source.provider,
                                    path: path,
                                    pageToken: pageToken,
                                    queue: .main,
                                    completionHandler: completionHandler)
    }

    private func loadThumbnail(for item: CloudItem, into cell: UITableViewCell) {

        // Use a placeholder until we get the real thumbnail
        cell.imageView?.image = UIImage(named: "placeholder", in: Bundle(for: classForCoder), compatibleWith: nil)

        var request: DataRequest! = nil

        let urlRequest = URLRequest(url: item.thumbnailURL, cachePolicy: filestack.config.cloudThumbnailCachePolicy)

        // Request thumbnail
        request = Alamofire.request(urlRequest)
            .validate(contentType: ["image/*"])
            .responseData(completionHandler: { (response) in
                // Remove request from thumbnail requests
                if let idx = (self.thumbnailRequests.index { $0.task == request.task }) {
                    self.thumbnailRequests.remove(at: idx)
                }

                var image: UIImage?

                // Obtain image from data, and square it.
                if let data = response.data, let squareImage = UIImage(data: data)?.squared {
                    image = squareImage
                    // Update thumbnail cache with image.
                    self.thumbnailCache.setObject(squareImage, forKey: item.thumbnailURL as NSURL)
                } else {
                    // Unable to obtain image, use file placeholder.
                    image = UIImage(named: "file", in: Bundle(for: self.classForCoder), compatibleWith: nil)
                }

                // Update cell's image with thumbnail.
                DispatchQueue.main.async {
                    cell.imageView?.image = image
                }
            })

        // Add request to thumbnail requests.
        thumbnailRequests.append(request)
    }

    private func cancelPendingThumbnailRequests() {

        for request in thumbnailRequests {
            request.cancel()
        }

        thumbnailRequests.removeAll()
    }

    private func loadNextPage() {

        guard let pageToken = pageToken, currentRequest == nil else { return }

        currentRequest = requestFolderList(source: source, path: path, pageToken: pageToken) { (response) in
            self.currentRequest = nil

            guard let contents = response.contents else { return }
            
            let items = contents.flatMap { CloudItem(dictionary: $0) }

            self.items?.append(contentsOf: items)
            self.pageToken = response.nextToken
            self.tableView.reloadData()
        }
    }

    private func store(item: CloudItem) {

        var cancellableRequest: CancellableRequest? = nil

        // Instantiate upload monitor controller
        let scene = UploadMonitorScene(cancellableRequest: cancellableRequest)

        guard let uploadMonitorViewController = storyboard?.instantiateViewController(for: scene) else { return }

        self.uploadMonitorViewController = uploadMonitorViewController

        present(uploadMonitorViewController, animated: true) {
            // Since we can not measure progress here, we will have to fake it.
            // Set progress to 50% after 0.25 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                uploadMonitorViewController.updateProgress(value: 0.5)
            }
        }

        let completionHandler: ((StoreResponse) -> Void) = { (response) in
            // Nil the reference to the request object, so the object can be properly deallocated.
            cancellableRequest = nil

            if let error = response.error {
                let alert = UIAlertController(title: "Upload Failed",
                                              message: error.localizedDescription,
                                              preferredStyle: .alert)

                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    // Dismiss monitor view controller, and remove strong reference to it
                    uploadMonitorViewController.dismiss(animated: true) {
                        self.uploadMonitorViewController = nil
                    }
                }))

                uploadMonitorViewController.present(alert, animated: true)
            } else {
                // Set progress to 100%
                uploadMonitorViewController.updateProgress(value: 1.0)
                // After 0.25 seconds, dismiss monitor view controller, and remove strong reference to it.
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    uploadMonitorViewController.dismiss(animated: true) {
                        self.uploadMonitorViewController = nil
                    }
                }
            }
        }

        cancellableRequest = filestack.store(provider: source.provider,
                                             path: item.path,
                                             storeOptions: storeOptions,
                                             completionHandler: completionHandler)
    }
}
