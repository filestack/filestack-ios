//
//  Client.swift
//  Filestack
//
//  Created by Ruben Nine on 10/19/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import FilestackSDK
import Foundation
import SafariServices

private typealias CompletionHandler = (_ response: CloudResponse, _ safariError: Error?) -> Swift.Void

/// The `Client` class provides an unified API to upload files and manage cloud contents using Filestack REST APIs.
@objc(FSFilestackClient) public class Client: NSObject {
    // MARK: - Properties

    /// An API key obtained from the [Developer Portal](http://dev.filestack.com).
    @objc public let apiKey: String

    /// A `Security` object. `nil` by default.
    @objc public let security: Security?

    /// A `Config` object.
    @objc public let config: Config

    /// The Filestack SDK client used for uploads and transformations.
    @objc public var sdkClient: FilestackSDK.Client {
        return client
    }

    // MARK: - Private Properties

    private let client: FilestackSDK.Client
    private let cloudService = CloudService()

    private var lastToken: String?
    private var resumeCloudRequestNotificationObserver: NSObjectProtocol!
    private var safariAuthSession: AnyObject?

    // MARK: - Lifecyle Functions

    /// Default initializer.
    ///
    /// - Parameter apiKey: An API key obtained from the Developer Portal.
    /// - Parameter security: A `Security` object. `nil` by default.
    /// - Parameter config: A `Config` object. `nil` by default.
    /// - Parameter token: A token obtained from `lastToken` to use initially. This could be useful to avoid
    /// authenticating against a cloud provider assuming that the passed token has not yet expired.
    @objc public init(apiKey: String, security: Security? = nil, config: Config? = nil, token: String? = nil) {
        self.apiKey = apiKey
        self.security = security
        self.lastToken = token
        self.client = FilestackSDK.Client(apiKey: apiKey, security: security)
        self.config = config ?? Config()

        super.init()
    }

    // MARK: - Public Functions

    /// Returns an instance of a `PickerNavigationController` that will allow the user to interactively pick files from
    /// a local or cloud source and upload them to a given location.
    ///
    /// - Parameter storeOptions: An object containing the store options (e.g. location, region, container, access, etc.)
    /// If none given, S3 location with default options is assumed.
    ///
    /// - Returns: A `PickerNavigationController` that may be presented using `present(_:animated:)` from your view controller.
    @objc public func picker(storeOptions: StorageOptions = .defaults) -> PickerNavigationController {
        let storyboard = UIStoryboard(name: "Picker", bundle: Bundle(for: type(of: self)))
        let scene = PickerNavigationScene(client: self, storeOptions: storeOptions)

        return storyboard.instantiateViewController(for: scene)
    }

    /// Uploads a single `Uploadable` to a given storage location.
    ///
    /// Currently the only storage location supported is Amazon S3.
    ///
    /// - Important:
    /// If your uploadable can not return a MIME type (e.g. when passing `Data` as the uploadable), you **must** pass
    /// a custom `UploadOptions` with custom `storeOptions` initialized with a `mimeType` that better represents your
    /// uploadable, otherwise `text/plain` will be assumed.
    ///
    /// - Parameter uploadable: An item to upload conforming to `Uploadable`.
    /// - Parameter options: A set of upload options (see `UploadOptions` for more information.)
    /// - Parameter queue: The queue on which the upload progress and completion handlers are dispatched.
    /// - Parameter uploadProgress: Sets a closure to be called periodically during the lifecycle of the upload process
    /// as data is uploaded to the server. `nil` by default.
    /// - Parameter completionHandler: Adds a handler to be called once the upload has finished.
    ///
    /// - Returns: A `CancellableRequest` object that allows cancelling the upload request.
    @discardableResult
    public func upload(using uploadable: FilestackSDK.Uploadable,
                       options: UploadOptions = .defaults,
                       queue: DispatchQueue = .main,
                       uploadProgress: ((Progress) -> Void)? = nil,
                       completionHandler: @escaping (NetworkJSONResponse) -> Void) -> CancellableRequest {
        return client.upload(using: uploadable,
                             options: options,
                             queue: queue,
                             uploadProgress: uploadProgress,
                             completionHandler: completionHandler)
    }

    /// Uploads an array of `Uploadable` items to a given storage location.
    ///
    /// Currently the only storage location supported is Amazon S3.
    ///
    /// - Important:
    /// If your uploadable can not return a MIME type (e.g. when passing `Data` as the uploadable), you **must** pass
    /// a custom `UploadOptions` with custom `storeOptions` initialized with a `mimeType` that better represents your
    /// uploadable, otherwise `text/plain` will be assumed.
    ///
    /// - Parameter uploadables: An array of items to upload conforming to `Uploadable`. May be `nil` if you intend to
    /// add them later to the returned `MultifileUpload` object.
    /// - Parameter options: A set of upload options (see `UploadOptions` for more information.)
    /// - Parameter queue: The queue on which the upload progress and completion handlers are dispatched.
    /// - Parameter uploadProgress: Sets a closure to be called periodically during the lifecycle of the upload process
    /// as data is uploaded to the server. `nil` by default.
    /// - Parameter completionHandler: Adds a handler to be called once the upload has finished.
    ///
    /// - Returns: A `CancellableRequest` object that allows cancelling the upload request.
    @discardableResult
    public func upload(using uploadables: [FilestackSDK.Uploadable],
                       options: UploadOptions = .defaults,
                       queue: DispatchQueue = .main,
                       uploadProgress: ((Progress) -> Void)? = nil,
                       completionHandler: @escaping ([NetworkJSONResponse]) -> Void) -> CancellableRequest {
        return client.upload(using: uploadables,
                             options: options,
                             queue: queue,
                             uploadProgress: uploadProgress,
                             completionHandler: completionHandler)
    }

    /// Uploads a file to a given storage location picked interactively from the camera or the photo library.
    ///
    /// - Parameter viewController: The view controller that will present the picker.
    /// - Parameter sourceType: The desired source type (e.g. camera, photo library.)
    /// - Parameter options: A set of upload options (see `UploadOptions` for more information.)
    /// - Parameter queue: The queue on which the upload progress and completion handlers are dispatched.
    /// - Parameter uploadProgress: Sets a closure to be called periodically during the lifecycle of the upload process
    /// as data is uploaded to the server. `nil` by default.
    /// - Parameter completionHandler: Adds a handler to be called once the upload has finished.
    ///
    /// - Returns: A `CancellableRequest` object that allows cancelling the upload request.
    @discardableResult
    public func uploadFromImagePicker(viewController: UIViewController,
                                      sourceType: UIImagePickerController.SourceType,
                                      options: UploadOptions = .defaults,
                                      queue: DispatchQueue = .main,
                                      uploadProgress: ((Progress) -> Void)? = nil,
                                      completionHandler: @escaping ([NetworkJSONResponse]) -> Void) -> CancellableRequest {
        options.startImmediately = false

        let mfu = client.upload(options: options,
                                queue: queue,
                                uploadProgress: uploadProgress,
                                completionHandler: completionHandler)

        let uploadController = ImagePickerUploadController(multifileUpload: mfu,
                                                           viewController: viewController,
                                                           sourceType: sourceType,
                                                           config: config)

        uploadController.filePickedCompletionHandler = { success in
            // Remove completion handler, so this `ImagePickerUploadController` object can be properly deallocated.
            uploadController.filePickedCompletionHandler = nil

            guard success else {
                // Picking from image picker was cancelled
                mfu.cancel()
                return
            }

            // As soon as a file is picked, let's send a progress update with 0% progress for faster feedback.
            let progress = Progress(totalUnitCount: 1)
            progress.completedUnitCount = 0

            uploadProgress?(progress)
        }

        uploadController.start()

        return mfu
    }

    /// Uploads a file to a given storage location picked interactively from the device's documents, iCloud Drive or
    /// other third-party cloud services.
    ///
    /// - Parameter viewController: The view controller that will present the picker.
    /// - Parameter options: A set of upload options (see `UploadOptions` for more information.)
    /// - Parameter queue: The queue on which the upload progress and completion handlers are dispatched.
    /// - Parameter uploadProgress: Sets a closure to be called periodically during the lifecycle of the upload process
    /// as data is uploaded to the server. `nil` by default.
    /// - Parameter completionHandler: Adds a handler to be called once the upload has finished.
    ///
    /// - Returns: A `CancellableRequest` object that allows cancelling the upload request.
    @discardableResult
    public func uploadFromDocumentPicker(viewController: UIViewController,
                                         options: UploadOptions = .defaults,
                                         queue: DispatchQueue = .main,
                                         uploadProgress: ((Progress) -> Void)? = nil,
                                         completionHandler: @escaping ([NetworkJSONResponse]) -> Void) -> CancellableRequest {
        options.startImmediately = false

        let mfu = client.upload(options: options, queue: queue, uploadProgress: uploadProgress, completionHandler: completionHandler)

        let uploadController = DocumentPickerUploadController(multifileUpload: mfu,
                                                              viewController: viewController,
                                                              config: config)

        uploadController.filePickedCompletionHandler = { success in
            // Remove completion handler, so this `DocumentPickerUploadController` object can be properly deallocated.
            uploadController.filePickedCompletionHandler = nil

            guard success else {
                // Picking from document picker was cancelled
                mfu.cancel()
                return
            }

            // As soon as a file is picked, let's send a progress update with 0% progress for faster feedback.
            let progress = Progress(totalUnitCount: 1)
            progress.completedUnitCount = 0

            uploadProgress?(progress)
        }

        uploadController.start()

        return mfu
    }

    /// Lists the content of a cloud provider at a given path. Results are paginated (see `pageToken` below.)
    ///
    /// - Parameter provider: The cloud provider to use (e.g. Dropbox, GoogleDrive, S3)
    /// - Parameter path: The path to list (be sure to include a trailing slash "/".)
    /// - Parameter pageToken: A token obtained from a previous call to this function. This token is included in every
    /// `FolderListResponse` returned by this function in a property called `nextToken`.
    /// - Parameter queue: The queue on which the completion handler is dispatched.
    /// - Parameter completionHandler: Adds a handler to be called once the request has completed either with a success,
    /// or error response.
    ///
    /// - Returns: A `CancellableRequest` object that allows cancelling the folder list request.
    @objc
    @discardableResult
    public func folderList(provider: CloudProvider,
                           path: String,
                           pageToken: String? = nil,
                           queue: DispatchQueue = .main,
                           completionHandler: @escaping FolderListCompletionHandler) -> CancellableRequest {
        guard let appURLScheme = config.appURLScheme else {
            fatalError("Please make sure your Filestack config object has an appURLScheme set.")
        }

        let request = FolderListRequest(appURLScheme: appURLScheme,
                                        apiKey: apiKey,
                                        security: security,
                                        token: lastToken,
                                        pageToken: pageToken,
                                        provider: provider,
                                        path: path)

        perform(request: request, queue: queue) { response, safariError in
            switch (response, safariError) {
            case (let response as FolderListResponse, nil):
                completionHandler(response)
            case let (_, error):
                completionHandler(FolderListResponse(error: error))
            }
        }

        return request
    }

    /// Stores a file from a given cloud provider and path at the desired store location.
    ///
    /// - Parameter provider: The cloud provider to use (e.g. Dropbox, GoogleDrive, S3)
    /// - Parameter path: The path to a file in the cloud provider.
    /// - Parameter storeOptions: An object containing the store options (e.g. location, region, container, access, etc.)
    /// If none given, S3 location with default options is assumed.
    /// - Parameter queue: The queue on which the completion handler is dispatched.
    /// - Parameter completionHandler: Adds a handler to be called once the request has completed either with a success,
    /// or error response.
    ///
    /// - Returns: A `CancellableRequest` object that allows cancelling the store request.
    @objc
    @discardableResult
    public func store(provider: CloudProvider,
                      path: String,
                      storeOptions: StorageOptions = .defaults,
                      queue: DispatchQueue = .main,
                      completionHandler: @escaping StoreCompletionHandler) -> CancellableRequest {
        let request = StoreRequest(apiKey: apiKey,
                                   security: security,
                                   token: lastToken,
                                   provider: provider,
                                   path: path,
                                   storeOptions: storeOptions)

        perform(request: request, queue: queue) { response, _ in
            guard let response = response as? StoreResponse else { return }
            completionHandler(response)
        }

        return request
    }

    /// Logs out the user from a given provider.
    ///
    /// - Parameter provider: The `CloudProvider` to logout from.
    /// - Parameter completionHandler: Adds a handler to be called once the request has completed. The response will
    /// either contain an error (on failure) or nothing at all (on success.)
    @objc public func logout(provider: CloudProvider, completionHandler: @escaping LogoutCompletionHandler) {
        guard let token = lastToken else { return }

        let logoutRequest = LogoutRequest(provider: provider, apiKey: apiKey, token: token)

        logoutRequest.perform(cloudService: cloudService, completionBlock: completionHandler)
    }

    // MARK: - Internal Functions

    func prefetch(completionBlock: @escaping PrefetchCompletionHandler) {
        let prefetchRequest = PrefetchRequest(apiKey: apiKey)

        prefetchRequest.perform(cloudService: cloudService, completionBlock: completionBlock)
    }

    // MARK: - Private Functions

    private func perform(request: CloudRequest, queue: DispatchQueue = .main, completionBlock: @escaping CompletionHandler) {
        // Perform request.
        // On success, store last token and call completion block.
        // Else, if auth is required, authenticate against web service.
        request.perform(cloudService: cloudService, queue: queue) { authRedirectURL, response in
            if let token = request.token {
                self.lastToken = token
            }

            guard let authURL = response.authURL, let authRedirectURL = authRedirectURL else {
                completionBlock(response, nil)
                return
            }

            DispatchQueue.main.async {
                let completion: SFAuthenticationSession.CompletionHandler = { url, error in
                    // Remove strong reference, so object can be deallocated.
                    self.safariAuthSession = nil

                    if let safariError = error {
                        completionBlock(response, safariError)
                    } else if let url = url, url.absoluteString.starts(with: authRedirectURL.absoluteString) {
                        self.perform(request: request, queue: queue, completionBlock: completionBlock)
                    }
                }

                let safariAuthSession = SFAuthenticationSession(url: authURL,
                                                                callbackURLScheme: self.config.appURLScheme,
                                                                completionHandler: completion)

                // Keep a strong reference to the auth session.
                self.safariAuthSession = safariAuthSession

                safariAuthSession.start()
            }
        }
    }
}
