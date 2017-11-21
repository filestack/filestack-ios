//
//  CloudSourceTabBarController.swift
//  Filestack
//
//  Created by Ruben Nine on 11/16/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import UIKit
import Alamofire
import FilestackSDK


internal struct CloudSourceTabBarScene: Scene {

    let filestack: Filestack
    let storeOptions: StorageOptions
    let source: CloudSource

    var customSourceName: String? = nil
    var path: String? = nil
    var nextPageToken: String? = nil
    var viewType: CloudSourceViewType

    func configureViewController(_ viewController: CloudSourceTabBarController) {

        // Inject the dependencies
        viewController.filestack = filestack
        viewController.storeOptions = storeOptions
        viewController.source = source
        viewController.customSourceName = customSourceName
        viewController.nextPageToken = nextPageToken
        viewController.path = path ?? "/"
        viewController.viewType = viewType
    }
}


internal class CloudSourceTabBarController: UITabBarController, CloudSourceDataSource {

    var filestack: Filestack!
    var storeOptions: StorageOptions!
    var source: CloudSource!
    var path: String!
    var nextPageToken: String?

    internal private(set) var items: [CloudItem]? = nil

    let thumbnailCache: NSCache<NSURL, UIImage> = {

        let cache = NSCache<NSURL, UIImage>()

        cache.countLimit = 1000

        return cache
    }()

    var viewType: CloudSourceViewType!

    private var requestInProgress: Bool {

        return currentRequest != nil
    }

    private let sessionManager = SessionManager.filestackDefault
    private var toggleViewTypeButton: UIBarButtonItem?
    private var currentRequest: CancellableRequest?
    private var thumbnailRequests: [DataRequest] = [DataRequest]()
    private weak var uploadMonitorViewController: UploadMonitorViewController?

    fileprivate var customSourceName: String? = nil


    // MARK: - View Overrides

    override func viewDidLoad() {

        super.viewDidLoad()

        // For all the sources except the custom source, we obtain its name by asking about its description,
        // however, for the custom source name we obtain this value separately.
        if source == .customSource && customSourceName != nil {
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
            let logoutImage = UIImage(named: "icon-logout", in: Bundle(for: type(of: self)), compatibleWith: nil)

            navigationItem.rightBarButtonItems = [
                UIBarButtonItem(image: logoutImage, style: .plain, target: self, action: #selector(logout))
            ]
        } else {
            navigationItem.rightBarButtonItems = []
        }
    }

    override func viewWillAppear(_ animated: Bool) {

        super.viewWillAppear(animated)

        selectedIndex = viewType.rawValue
        setupViewtypeButton()

        guard items == nil else { return }

        // Request folder list, and notify the selected view controller when done.
        currentRequest = requestFolderList(source: source, path: path) { (response) in
            self.currentRequest = nil

            // Got an error, pop to root view controller (i.e., source list selection)
            if response.error != nil {
                self.navigationController?.popToRootViewController(animated: true)
                return
            }

            // Ensure we got contents or return early
            guard let contents = response.contents else { return }
            // Flat map JSON array into CloudItem array.
            let items = contents.flatMap { CloudItem(dictionary: $0) }

            // Store next page token (or nil, if none)
            self.nextPageToken = response.nextToken
            // Finally, replace data source items with the latest received items
            self.items = items

            // Notify any data source consumer childs that the data source (this object) has received initial results.
            for child in self.childViewControllers {
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
            // Nil the reference to the request object, so it can be properly deallocated.
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

    func loadNextPage(completionHandler: @escaping (() -> Void)) {

        guard let nextPageToken = nextPageToken, !requestInProgress else { return }

        currentRequest = requestFolderList(source: source,
                                           path: path,
                                           pageToken: nextPageToken) { (response) in
                                            self.currentRequest = nil

                                            guard let contents = response.contents else { return }

                                            let items = contents.flatMap { CloudItem(dictionary: $0) }

                                            self.nextPageToken = response.nextToken
                                            self.items?.append(contentsOf: items)

                                            completionHandler()
        }
    }

    func refresh(completionHandler: @escaping (() -> Void)) {

        guard !requestInProgress && items != nil else { return }

        cancelPendingThumbnailRequests()

        currentRequest = requestFolderList(source: source, path: path) { (response) in
            self.currentRequest = nil

            guard let contents = response.contents else { return }
            let items = contents.flatMap { CloudItem(dictionary: $0) }

            self.nextPageToken = response.nextToken
            self.items = items

            completionHandler()
        }
    }

    func cacheThumbnail(for item: CloudItem, completionHandler: @escaping ((UIImage) -> Void)) {

        let cachePolicy = filestack.config.cloudThumbnailCachePolicy
        let urlRequest = URLRequest(url: item.thumbnailURL, cachePolicy: cachePolicy)

        var request: DataRequest! = nil

        // Request thumbnail

        request = sessionManager.request(urlRequest)
            .validate(contentType: ["image/*"])
            .responseData(completionHandler: { (response) in
                // Remove request from thumbnail requests
                if let idx = (self.thumbnailRequests.index { $0.task == request.task }) {
                    self.thumbnailRequests.remove(at: idx)
                }

                var image: UIImage!

                // Obtain image from data, and square it.
                if let data = response.data, let squareImage = UIImage(data: data)?.squared {
                    image = squareImage
                } else {
                    // Unable to obtain image, use file placeholder.
                    image = UIImage(named: "file", in: Bundle(for: type(of: self)), compatibleWith: nil)
                }

                // Update thumbnail cache with image.
                self.thumbnailCache.setObject(image, forKey: item.thumbnailURL as NSURL)

                // Call completion handler
                completionHandler(image)
            })

        // Add request to thumbnail requests.
        thumbnailRequests.append(request)
    }

    func navigate(to item: CloudItem) {

        let scene = CloudSourceTabBarScene(filestack: filestack,
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

        guard let image = UIImage(named: alternateViewtype.iconName, in: Bundle(for: type(of: self)), compatibleWith: nil) else {
            fatalError("Unable to find icon for view type \(alternateViewtype).")
        }

        return image
    }

    private func setupViewtypeButton() {

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
                                   completionHandler: @escaping FolderListCompletionHandler) -> CancellableRequest {

        return filestack.folderList(provider: source.provider,
                                    path: path,
                                    pageToken: pageToken,
                                    queue: .main,
                                    completionHandler: completionHandler)
    }

    private func cancelPendingThumbnailRequests() {

        for request in thumbnailRequests {
            request.cancel()
        }

        thumbnailRequests.removeAll()
    }


    // MARK: - Actions

    @IBAction func toggleViewType(_ sender: Any) {

        viewType = viewType.toggle()
        selectedIndex = viewType.rawValue
        setupViewtypeButton()
        // Store view type in user defaults
        UserDefaults.standard.set(cloudSourceViewType: viewType)
    }

    @IBAction func logout(_ sender: Any) {

        filestack.logout(provider: source.provider) { (response) in
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
