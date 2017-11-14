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

    var nextToken: String? = nil
    var path: String? = nil

    func configureViewController(_ viewController: CloudSourceDetailTableViewController) {

        // Inject the dependencies
        viewController.filestack = filestack
        viewController.source = source
        viewController.path = path ?? "/"
        viewController.nextToken = nextToken
    }
}


class CloudSourceDetailTableViewController: UITableViewController {

    var filestack: Filestack!
    var source: CloudSource!
    var path: String!
    var nextToken: String?

    private var items: [CloudItem] = [CloudItem]()
    private var currentRequest: CancellableRequest?

    private let thumbnailCache: NSCache<NSURL, UIImage> = {

        let cache = NSCache<NSURL, UIImage>()

        cache.countLimit = 2000

        return cache
    }()

    private var thumbnailRequests: [DataRequest] = [DataRequest]()


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

            guard let contents = response.contents else { return }

            let items = contents.flatMap { CloudItem(dictionary: $0) }

            self.items = items
            self.nextToken = response.nextToken
            self.tableView.reloadData()

            self.refreshControl = UIRefreshControl()
            self.refreshControl?.addTarget(self, action: #selector(self.refresh), for: UIControlEvents.valueChanged)
        }
    }

    override func viewWillAppear(_ animated: Bool) {

        super.viewWillAppear(animated)
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

            if items.count == 0 {
                return 1
            }

            return nextToken == nil ? items.count : items.count + 1

        default:

            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if indexPath.row == items.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "activityIndicatorTVC", for: indexPath) as! ActivityIndicatorTableViewCell

            cell.activityIndicator.startAnimating()

            return cell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: "sourceDetailTVC", for: indexPath)

        guard let item = items[safe: UInt(indexPath.row)] else { return cell }

        cell.textLabel?.text = item.name

        guard let cachedImage = thumbnailCache.object(forKey: item.thumbnailURL as NSURL) else {
            loadThumbnail(for: item, into: cell)

            return cell
        }

        cell.imageView?.image = cachedImage

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        guard let item = items[safe: UInt(indexPath.row)] else { return }

        if item.isFolder {
            let scene = CloudSourceDetailScene(filestack: filestack,
                                               source: source,
                                               nextToken: nil,
                                               path: item.path)

            if let vc = storyboard?.instantiateViewController(for: scene) {
                navigationController?.pushViewController(vc, animated: true)
            }
        }
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {

        if indexPath.row == items.count && currentRequest == nil {
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
            self.nextToken = response.nextToken
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

                // Obtain image from data, and square it.
                guard let data = response.data,
                      let image = UIImage(data: data)?.squared else {
                        return
                }

                // Update thumbnail cache with image.
                self.thumbnailCache.setObject(image, forKey: item.thumbnailURL as NSURL)

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

        guard let nextToken = nextToken, currentRequest == nil else { return }

        currentRequest = requestFolderList(source: source, path: path, pageToken: nextToken) { (response) in
            self.currentRequest = nil

            guard let contents = response.contents else { return }
            let items = contents.flatMap { CloudItem(dictionary: $0) }

            self.items.append(contentsOf: items)
            self.nextToken = response.nextToken
            self.tableView.reloadData()
        }
    }
}
