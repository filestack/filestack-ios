//
//  Filestack.swift
//  Filestack
//
//  Created by Ruben Nine on 10/19/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation
import FilestackSDK


public typealias FolderListCompletionHandler = (_ response: FolderListResponse) -> Swift.Void
public typealias StoreCompletionHandler = (_ response: StoreResponse) -> Swift.Void
public typealias CompletionHandler = (_ response: CloudResponse) -> Swift.Void


/**
    The `Filestack` class provides an unified API to upload files and manage cloud contents using Filestack REST APIs.
 */
@objc(FSFilestack) public class Filestack: NSObject {


    // MARK: - Notifications

    /// This notification should be posted after an app receives an URL after authentication against a cloud provider.
    public static let resumeCloudRequestNotification = Notification.Name("resume-filestack-cloud-request")


    // MARK: - Properties

    /// An API key obtained from the [Developer Portal](http://dev.filestack.com).
    public let apiKey: String

    /// A `Security` object. `nil` by default.
    public let security: Security?


    // MARK: - Private Properties

    private let client: Client
    private let cloudService = CloudService()

    private var pendingRequests: [UUID: (CloudRequest, CompletionHandler)]
    private var lastToken: String?
    private var resumeCloudRequestNotificationObserver: NSObjectProtocol!


    // MARK: - Lifecyle Functions

    /**
        Default initializer.

        - Parameter apiKey: An API key obtained from the Developer Portal.
        - Parameter security: A `Security` object. `nil` by default.
        - Parameter token: A token obtained from `lastToken` to use initially. This could be useful to avoid
             authenticating against a cloud provider assuming that the passed token has not yet expired.
     */
    @objc public init(apiKey: String, security: Security? = nil, token: String? = nil) {

        self.apiKey = apiKey
        self.security = security
        self.lastToken = token
        self.client = Client(apiKey: apiKey, security: security)
        self.pendingRequests = [:]

        super.init()
    }


    // MARK: - Public Functions


    /**
        Uploads a file directly to a given storage location (currently only S3 is supported.)

        - Parameter localURL: The URL of the local file to be uploaded.
        - Parameter storeOptions: An object containing the store options (e.g. location, region, container, access, etc.
            If none given, S3 location with default options is assumed.
        - Parameter useIntelligentIngestionIfAvailable: Attempts to use Intelligent Ingestion for file uploading.
            Defaults to `true`.
        - Parameter queue: The queue on which the upload progress and completion handlers are dispatched.
        - Parameter uploadProgress: Sets a closure to be called periodically during the lifecycle of the upload process
            as data is uploaded to the server. `nil` by default.
        - Parameter completionHandler: Adds a handler to be called once the upload has finished.
     */
    @discardableResult public func upload(from localURL: URL,
                                          storeOptions: StorageOptions = StorageOptions(location: .s3),
                                          useIntelligentIngestionIfAvailable: Bool = true,
                                          queue: DispatchQueue = .main,
                                          uploadProgress: ((Progress) -> Void)? = nil,
                                          completionHandler: @escaping (NetworkJSONResponse?) -> Void) -> MultipartUpload {

        let mpu = client.multiPartUpload(from: localURL,
                                         storeOptions: storeOptions,
                                         useIntelligentIngestionIfAvailable: useIntelligentIngestionIfAvailable,
                                         queue: queue,
                                         startUploadImmediately: false,
                                         uploadProgress: uploadProgress,
                                         completionHandler: completionHandler)

        mpu.uploadFile()

        return mpu
    }

    /**
        Uploads a file to a given storage location picked interactively from the camera or the photo library.

        - Parameter viewController: The view controller that will present the picker.
        - Parameter sourceType: The desired source type (e.g. camera, photo library.)
        - Parameter storeOptions: An object containing the store options (e.g. location, region, container, access, etc.)
            If none given, S3 location with default options is assumed.
        - Parameter useIntelligentIngestionIfAvailable: Attempts to use Intelligent Ingestion for file uploading.
            Defaults to `true`.
        - Parameter queue: The queue on which the upload progress and completion handlers are dispatched.
        - Parameter uploadProgress: Sets a closure to be called periodically during the lifecycle of the upload process
            as data is uploaded to the server. `nil` by default.
        - Parameter completionHandler: Adds a handler to be called once the upload has finished.
     */
    @discardableResult public func uploadFromImagePicker(viewController: UIViewController,
                                                         sourceType: UIImagePickerControllerSourceType,
                                                         storeOptions: StorageOptions = StorageOptions(location: .s3),
                                                         useIntelligentIngestionIfAvailable: Bool = true,
                                                         queue: DispatchQueue = .main,
                                                         uploadProgress: ((Progress) -> Void)? = nil,
                                                         completionHandler: @escaping (NetworkJSONResponse?) -> Void) -> MultipartUpload {

        let mpu = client.multiPartUpload(storeOptions: storeOptions,
                                         useIntelligentIngestionIfAvailable: useIntelligentIngestionIfAvailable,
                                         queue: queue,
                                         startUploadImmediately: false,
                                         uploadProgress: uploadProgress,
                                         completionHandler: completionHandler)

        let uploadController = PickerUploadController(multipartUpload: mpu,
                                                      viewController: viewController,
                                                      sourceType: sourceType)

        uploadController.filePickedCompletionHandler = { (success) in
            // Remove completion handler, so this `PickerUploadController` object can be properly deallocated.
            uploadController.filePickedCompletionHandler = nil

            if success {
                // As soon as a file is picked, let's send a progress update with 0% progress for faster feedback.
                let progress = Progress(totalUnitCount: 1)
                progress.completedUnitCount = 0

                uploadProgress?(progress)
            }
        }

        uploadController.start()

        return mpu
    }

    /**
         Lists the content of a cloud provider at a given path. Results are paginated (see `pageToken` below.)

         - Parameter provider: The cloud provider to use (e.g. Dropbox, GoogleDrive, S3)
         - Parameter path: The path to list (be sure to include a trailing slash "/".)
         - Parameter pageToken: A token obtained from a previous call to this function. This token is included in every
             `FolderListResponse` returned by this function in a property called `nextToken`.
         - Parameter appURLScheme: An URL scheme supported by the app. This is required to complete the cloud provider's
             authentication flow.
         - Parameter completionHandler: Adds a handler to be called once the request has completed either with a success,
             or error response.
     */
    public func folderList(provider: CloudProvider,
                           path: String,
                           pageToken: String? = nil,
                           appURLScheme: String,
                           completionHandler: @escaping FolderListCompletionHandler) {

        let request = FolderListRequest(appURLScheme: appURLScheme,
                                        apiKey: apiKey,
                                        security: security,
                                        token:  lastToken,
                                        pageToken: pageToken,
                                        provider: provider,
                                        path: path)

        let genericCompletionHandler: CompletionHandler = { response in
            guard let response = response as? FolderListResponse else { return }
            completionHandler(response)
        }

        perform(request: request, completionBlock: genericCompletionHandler)
    }

    /**
        Stores a file from a given cloud provider and path at the desired store location.

        - Parameter provider: The cloud provider to use (e.g. Dropbox, GoogleDrive, S3)
        - Parameter path: The path to a file in the cloud provider.
        - Parameter storeOptions: An object containing the store options (e.g. location, region, container, access, etc.)
             If none given, S3 location is assumed.
        - Parameter completionHandler: Adds a handler to be called once the request has completed either with a success,
             or error response.
     */
    public func store(provider: CloudProvider,
                      path: String,
                      storeOptions: StorageOptions = StorageOptions(location: .s3),
                      completionHandler: @escaping StoreCompletionHandler) {

        let request = StoreRequest(apiKey: apiKey,
                                   security: security,
                                   token:  lastToken,
                                   provider: provider,
                                   path: path,
                                   storeOptions: storeOptions)

        let genericCompletionHandler: CompletionHandler = { response in
            guard let response = response as? StoreResponse else { return }
            completionHandler(response)
        }

        perform(request: request, completionBlock: genericCompletionHandler)
    }

    /**
        Presents an interactive UI that will allow the user to pick files from a local or cloud source and upload them
        to a given location.

        - Parameter viewController: The view controller that will present the interactive UI.
        - Parameter storeOptions: An object containing the store options (e.g. location, region, container, access, etc.)
            If none given, S3 location is assumed.
     */
    public func presentInteractiveUploader(viewController: UIViewController,
                                           storeOptions: StorageOptions = StorageOptions(location: .s3)) {

        let storyboard = UIStoryboard(name: "InteractiveUploader", bundle: Bundle(for: self.classForCoder))
        let navigationController = storyboard.instantiateViewController(withIdentifier: "navigationController")

        guard let fsnc = navigationController as? FilestackNavigationController else {
            fatalError("Navigation controller must be an instance of FilestackNavigationController")
        }

        fsnc.filestack = self
        fsnc.storeOptions = storeOptions

        viewController.present(fsnc, animated: true)
    }


    // MARK: - Internal Functions

    internal func prefetch(completionBlock: @escaping PrefetchCompletionHandler) {

        let prefetchRequest = PrefetchRequest(apiKey: apiKey)

        prefetchRequest.perform(cloudService: cloudService, completionBlock: completionBlock)
    }


    // MARK: - Private Functions

    private func perform(request: CloudRequest, completionBlock: @escaping CompletionHandler) {

        // Perform request.
        // On success, store last token and call completion block.
        // Else, if auth is required, add request to pending requests, open Safari and request authentication.
        request.perform(cloudService: cloudService) { (requestUUID, response) in
            if let authRedirectURL = response.authRedirectURL {
                if #available(iOS 10, *) {
                    UIApplication.shared.open(authRedirectURL) { success in
                        if success {
                            self.pendingRequests[requestUUID] = (request, completionBlock)
                        }
                    }
                } else {
                    if UIApplication.shared.openURL(authRedirectURL) {
                        self.pendingRequests[requestUUID] = (request, completionBlock)
                    }
                }

                if !self.pendingRequests.isEmpty && self.resumeCloudRequestNotificationObserver == nil {
                    self.addResumeCloudRequestNotificationObserver()
                }
            } else {
                self.lastToken = request.token
                completionBlock(response)
            }
        }
    }

    @discardableResult private func resumeCloudRequest(using url: URL) -> Bool {

        // Compare the given URL's scheme to the app URL, then try to extract the request UUID from the URL.
        // If unable to find a match or if UUID is missing, return early.
        guard let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems,
            let idx = (queryItems.index { $0.name == "requestUUID" }),
            let requestUUIDString = queryItems[idx].value,
            let requestUUID = UUID(uuidString: requestUUIDString) else {
                return false
        }

        // Find pending request identified by `requestUUID` or return early.
        guard let (request, completionBlock) = pendingRequests[requestUUID] else {
            return false
        }

        // Perform pending request.
        // On success, store last token, remove pending request, and call completion block.
        // Else, if auth is still required, open Safari and request authentication.
        request.perform(cloudService: cloudService) { (requestUUID, response) in
            if let authRedirectURL = response.authRedirectURL {
                if #available(iOS 10, *) {
                    UIApplication.shared.open(authRedirectURL)
                } else {
                    UIApplication.shared.openURL(authRedirectURL)
                }
            } else {
                self.lastToken = request.token
                self.pendingRequests.removeValue(forKey: requestUUID)
                completionBlock(response)
            }

            if self.pendingRequests.isEmpty {
                self.removeResumeCloudRequestNotificationObserver()
            }
        }

        return true
    }

    private func addResumeCloudRequestNotificationObserver() {

        resumeCloudRequestNotificationObserver =
            NotificationCenter.default.addObserver(forName: Filestack.resumeCloudRequestNotification,
                                                   object: nil,
                                                   queue: .main) { (notification) in
                                                    if let url = notification.object as? URL {
                                                        self.resumeCloudRequest(using: url)
                                                    }
        }
    }

    private func removeResumeCloudRequestNotificationObserver() {

        if let resumeCloudRequestNotificationObserver = resumeCloudRequestNotificationObserver {
            NotificationCenter.default.removeObserver(resumeCloudRequestNotificationObserver)
        }

        resumeCloudRequestNotificationObserver = nil
    }
}

