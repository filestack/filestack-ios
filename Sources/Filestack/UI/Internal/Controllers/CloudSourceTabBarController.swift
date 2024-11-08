//
//  CloudSourceTabBarController.swift
//  Filestack
//
//  Created by Ruben Nine on 11/16/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import FilestackSDK
import UIKit

private struct URLSessionTaskTracker {
    private var tasks: [URLSessionTask] = [URLSessionTask]()
    private let queue = DispatchQueue(label: "com.filestack.URLSessionTaskTracker")

    mutating func add(_ task: URLSessionTask) {
        queue.sync { tasks.append(task) }
    }

    mutating func remove(_ task: URLSessionTask) {
        queue.sync { tasks.removeAll { $0 == task } }
    }

    mutating func cancelPendingAndRemove() {
        queue.sync {
            for request in tasks {
                request.cancel()
            }

            tasks.removeAll()
        }
    }
}

class CloudSourceTabBarController: UITabBarController, CloudSourceDataSource {
    var client: Client!
    var storeOptions: StorageOptions!
    var source: CloudSource!
    var path: String!
    var nextPageToken: String?
    var customSourceName: String?
    var viewType: CloudSourceViewType!

    let thumbnailCache: NSCache<NSURL, UIImage> = {
        let cache = NSCache<NSURL, UIImage>()

        cache.countLimit = 1000

        return cache
    }()

    private(set) var items: [CloudItem]?

    private var requestInProgress: Bool {
        return currentRequest != nil
    }

    private let session = URLSession.filestackDefault
    private var toggleViewTypeButton: UIBarButtonItem?
    private var currentRequest: Cancellable?
    private var thumbnailTasks = URLSessionTaskTracker()
    private weak var uploadMonitorViewController: MonitorViewController?
    private var uploaderObserver: NSKeyValueObservation?

    // MARK: - View Overrides

    override func viewDidLoad() {
        super.viewDidLoad()

        // For all the sources except the custom source, we obtain its name by asking about its description,
        // however, for the custom source name we obtain this value separately.
        if source == .customSource, customSourceName != nil {
            title = customSourceName
        } else {
            title = source.description
        }
        // Hide tab bar (we will toggle between views using our custom list/grid toggle button.)
        tabBar.isHidden = true
        // Replace default back button with one with a custom title
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
        // Add logout button (unless we are displaying the custom source)
        if source != .customSource {
            let logoutImage = UIImage(named: "icon-logout", in: bundle, compatibleWith: nil)

            navigationItem.rightBarButtonItems = [
                UIBarButtonItem(image: logoutImage, style: .plain, target: self, action: #selector(logout)),
            ]
        } else {
            navigationItem.rightBarButtonItems = []
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        selectedIndex = (source.provider.viewType ?? viewType).rawValue

        if source.provider.viewType == nil {
            setupViewTypeButton()
        }

        guard items == nil else { return }

        // Request folder list, and notify the selected view controller when done.
        currentRequest = requestFolderList(source: source, path: path) { response in
            self.currentRequest = nil

            // Got an error, present error and pop to root view controller (i.e., source list selection)
            if let error = response.error {
                let alert = UIAlertController(title: "Error",
                                              message: error.localizedDescription,
                                              preferredStyle: .alert)

                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                    // Dismiss monitor view controller, and remove strong reference to it
                    self.navigationController?.popToRootViewController(animated: true)
                }))

                self.present(alert, animated: true)

                return
            }

            // Ensure we got contents or return early
            guard let contents = response.contents else { return }
            // Flat map JSON array into CloudItem array.
            let items = contents.compactMap { CloudItem(dictionary: $0) }

            // Store next page token (or nil, if none)
            self.nextPageToken = response.nextToken
            // Finally, replace data source items with the latest received items
            self.items = items

            // Notify any data source consumer childs that the data source (this object) has received initial results.
            for child in self.children {
                (child as? CloudSourceDataSourceConsumer)?.dataSourceReceivedInitialResults(dataSource: self)
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        currentRequest?.cancel()
        cancelPendingThumbnailRequests()

        super.viewWillDisappear(animated)
    }

    // MARK: - CloudSourceDataSource Protocol Functions

    func store(item: CloudItem) {
        guard let picker = navigationController as? PickerNavigationController else { return }

        let completionHandler: ((StoreResponse) -> Void) = { response in
            self.uploaderObserver = nil

            self.uploadMonitorViewController?.dismiss(animated: true) {
                self.uploadMonitorViewController = nil

                if let error = response.error {
                    let alert = UIAlertController(title: "Upload Failed",
                                                  message: error.localizedDescription,
                                                  preferredStyle: .alert)

                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                        picker.pickerDelegate?.pickerStoredFile(picker: picker, response: response)
                    }))

                    picker.present(alert, animated: true)
                } else {
                    picker.pickerDelegate?.pickerStoredFile(picker: picker, response: response)
                }
            }
        }

        let request = client.store(provider: source.provider,
                                   path: item.path,
                                   storeOptions: storeOptions,
                                   completionHandler: completionHandler)

        if uploadMonitorViewController == nil {
            let monitorViewController = MonitorViewController(progressable: request)
            monitorViewController.modalPresentationStyle = .currentContext

            self.uploadMonitorViewController = monitorViewController

            picker.present(monitorViewController, animated: true, completion: nil)
        }
    }

    func loadNextPage(completionHandler: @escaping (() -> Void)) {
        guard let nextPageToken = nextPageToken, !requestInProgress else { return }

        currentRequest = requestFolderList(source: source,
                                           path: path,
                                           pageToken: nextPageToken) { response in
            self.currentRequest = nil

            guard let contents = response.contents else { return }

            let items = contents.compactMap { CloudItem(dictionary: $0) }

            self.nextPageToken = response.nextToken
            self.items?.append(contentsOf: items)

            completionHandler()
        }
    }

    func refresh(completionHandler: @escaping (() -> Void)) {
        guard !requestInProgress, items != nil else { return }

        cancelPendingThumbnailRequests()

        currentRequest = requestFolderList(source: source, path: path) { response in
            self.currentRequest = nil

            guard let contents = response.contents else { return }
            let items = contents.compactMap { CloudItem(dictionary: $0) }

            self.nextPageToken = response.nextToken
            self.items = items

            completionHandler()
        }
    }

    func cacheThumbnail(for item: CloudItem, completionHandler: @escaping ((UIImage) -> Void)) {
        let cachePolicy = client.config.cloudThumbnailCachePolicy
        let urlRequest = URLRequest(url: item.thumbnailURL, cachePolicy: cachePolicy)

        // Request thumbnail
        var task: URLSessionDataTask!

        task = URLSession.filestackDefault.dataTask(with: urlRequest) {[weak self,weak task] (data, response, error) in
            // Remove request from thumbnail requests
            guard let self, let task else { return }
            self.thumbnailTasks.remove(task)

            var image: UIImage!

            // Obtain image from data, and square it.
            if error == nil, let data = data, let squareImage = UIImage(data: data)?.squared {
                image = squareImage
            } else {
                // Unable to obtain image, use file placeholder.
                image = UIImage(named: "file", in: bundle, compatibleWith: nil)
            }

            // Update thumbnail cache with image.
            self.thumbnailCache.setObject(image, forKey: item.thumbnailURL as NSURL)

            // Call completion handler
            DispatchQueue.main.async { completionHandler(image) }
        }

        task.resume()

        // Add request to thumbnail requests.
        thumbnailTasks.add(task)
    }

    func search(text: String, completionHandler: @escaping (() -> Void)) {
        guard let escapedText = text.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else { return }

        path = "/\(escapedText)/"

        refresh(completionHandler: completionHandler)
    }

    func navigate(to item: CloudItem) {
        let scene = CloudSourceTabBarScene(client: client,
                                           storeOptions: storeOptions,
                                           source: source,
                                           customSourceName: customSourceName,
                                           path: item.path,
                                           nextPageToken: nil,
                                           viewType: viewType)

        if let vc = storyboard?.instantiateViewController(for: scene) {
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    // MARK: - Private Functions

    private func alternateIcon() -> UIImage {
        let alternateViewtype = viewType.toggle()

        return UIImage.fromFilestackBundle(alternateViewtype.iconName)
    }

    private func setupViewTypeButton() {
        if toggleViewTypeButton == nil {
            toggleViewTypeButton = UIBarButtonItem(image: alternateIcon(), style: .plain, target: self, action: #selector(toggleViewType))
            navigationItem.rightBarButtonItems?.append(toggleViewTypeButton!)
        } else {
            toggleViewTypeButton?.image = alternateIcon()
        }
    }

    private func requestFolderList(source: CloudSource,
                                   path: String,
                                   pageToken: String? = nil,
                                   completionHandler: @escaping FolderListCompletionHandler) -> Cancellable {
        return client.folderList(provider: source.provider,
                                 path: path,
                                 pageToken: pageToken,
                                 queue: .main,
                                 completionHandler: completionHandler)
    }

    private func cancelPendingThumbnailRequests() {
        thumbnailTasks.cancelPendingAndRemove()
    }

    // MARK: - Actions

    @IBAction func toggleViewType(_: Any) {
        viewType = viewType.toggle()
        selectedIndex = viewType.rawValue
        setupViewTypeButton()
        // Store view type in user defaults
        UserDefaults.standard.set(cloudSourceViewType: viewType)
    }

    @IBAction func logout(_: Any) {
        client.logout(provider: source.provider) { response in
            if let error = response.error {
                let alert = UIAlertController(title: "Logout Failed",
                                              message: error.localizedDescription,
                                              preferredStyle: .alert)

                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

                self.present(alert, animated: true)
            } else {
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
    }
}
