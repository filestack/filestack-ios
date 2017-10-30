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


@objc(FSFilestack) public class Filestack: NSObject {

    /// This notification should be posted after an app receives an URL after authentication against a cloud provider.
    public static let resumeCloudRequestNotification = Notification.Name("resume-filestack-cloud-request")

    // MARK: - Properties

    /// An API key obtained from the [Developer Portal](http://dev.filestack.com).
    public let apiKey: String

    public let appURLScheme: String

    /// A `Security` object. `nil` by default.
    public let security: Security?


    // MARK: - Private Properties

    private let client: Client
    private let cloudService = CloudService()

    private var pendingRequests: [UUID: (CloudRequest, CompletionHandler)]
    private var lastToken: String?

    fileprivate var uploadControllers: [PickerUploadController] = []


    // MARK: - Lifecyle Functions

    /**
        Default initializer.

        - SeeAlso: `Security`

        - Parameter apiKey: An API key obtained from the Developer Portal.
        - Parameter security: A `Security` object. `nil` by default.
     */
    @objc public init(appURLScheme: String, apiKey: String, security: Security? = nil, lastToken: String? = nil) {

        self.appURLScheme = appURLScheme
        self.apiKey = apiKey
        self.security = security
        self.lastToken = lastToken
        self.client = Client(apiKey: apiKey, security: security)
        self.pendingRequests = [:]

        super.init()

        NotificationCenter.default.addObserver(forName: Filestack.resumeCloudRequestNotification, object: nil, queue: .main) { (notification) in
            if let url = notification.object as? URL {
                self.resumeCloudRequest(using: url)
            }
        }
    }

    deinit {

        NotificationCenter.default.removeObserver(self, name: Filestack.resumeCloudRequestNotification, object: nil)
    }


    // MARK: - Public Functions


    /**
        Uploads a file directly to a given storage location (currently only S3 is supported.)

        - Parameter localURL: The URL of the local file to be uploaded.
        - Parameter storage: The storage location. Defaults to `s3`.
        - Parameter useIntelligentIngestionIfAvailable: Attempts to use Intelligent Ingestion
        for file uploading. Defaults to `true`.
        - Parameter queue: The queue on which the upload progress and completion handlers are
        dispatched.
        - Parameter uploadProgress: Sets a closure to be called periodically during the lifecycle
        of the upload process as data is uploaded to the server. `nil` by default.
        - Parameter completionHandler: Adds a handler to be called once the upload has finished.
     */
    @discardableResult public func upload(from localURL: URL,
                                          storage: StorageLocation = .s3,
                                          useIntelligentIngestionIfAvailable: Bool = true,
                                          queue: DispatchQueue = .main,
                                          uploadProgress: ((Progress) -> Void)? = nil,
                                          completionHandler: @escaping (NetworkJSONResponse?) -> Void) -> MultipartUpload {

        let mpu = client.multiPartUpload(from: localURL,
                                         storage: storage,
                                         useIntelligentIngestionIfAvailable: useIntelligentIngestionIfAvailable,
                                         queue: queue,
                                         startUploadImmediately: false,
                                         uploadProgress: uploadProgress,
                                         completionHandler: completionHandler)

        mpu.uploadFile()

        return mpu
    }

    @discardableResult public func uploadFromImagePicker(viewController: UIViewController,
                                                         sourceType: UIImagePickerControllerSourceType,
                                                         storage: StorageLocation = .s3,
                                                         useIntelligentIngestionIfAvailable: Bool = true,
                                                         queue: DispatchQueue = .main,
                                                         uploadProgress: ((Progress) -> Void)? = nil,
                                                         completionHandler: @escaping (NetworkJSONResponse?) -> Void) -> MultipartUpload {

        let mpu = client.multiPartUpload(storage: storage,
                                         useIntelligentIngestionIfAvailable: useIntelligentIngestionIfAvailable,
                                         queue: queue,
                                         startUploadImmediately: false,
                                         uploadProgress: uploadProgress,
                                         completionHandler: completionHandler)

        let uploadController = PickerUploadController(multipartUpload: mpu,
                                                      viewController: viewController,
                                                      sourceType: sourceType)

        uploadController.delegate = self
        uploadController.start()
        uploadControllers.append(uploadController)

        return mpu
    }

    public func folderList(provider: CloudProvider,
                           path: String,
                           pageToken: String? = nil,
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

    public func store(provider: CloudProvider,
                      path: String,
                      storeLocation: StorageLocation = .s3,
                      storeRegion: String? = nil,
                      storeContainer: String? = nil,
                      storePath: String? = nil,
                      storeAccess: StorageAccess? = nil,
                      storeFilename: String? = nil,
                      completionHandler: @escaping StoreCompletionHandler) {

        let request = StoreRequest(appURLScheme: appURLScheme,
                                   apiKey: apiKey,
                                   security: security,
                                   token:  lastToken,
                                   provider: provider,
                                   path: path,
                                   storeLocation: storeLocation,
                                   storeRegion: storeRegion,
                                   storeContainer: storeContainer,
                                   storePath: storePath,
                                   storeAccess: storeAccess,
                                   storeFilename: storeFilename)

        let genericCompletionHandler: CompletionHandler = { response in
            guard let response = response as? StoreResponse else { return }
            completionHandler(response)
        }

        perform(request: request, completionBlock: genericCompletionHandler)
    }


    // MARK: - Private Functions

    private func perform(request: CloudRequest, completionBlock: @escaping CompletionHandler) {

        // Perform request.
        // On success, store last token and call completion block.
        // Else, if auth is required, add request to pending requests, open Safari and request authentication.
        request.perform(cloudService: cloudService) { (requestUUID, response) in
            if let authRedirectURL = response.authRedirectURL {
                UIApplication.shared.open(authRedirectURL, options: [:], completionHandler: { success in
                    if success {
                        self.pendingRequests[requestUUID] = (request, completionBlock)
                    }
                })
            } else {
                self.lastToken = request.token
                completionBlock(response)
            }
        }
    }

    /// To be called by the app delegate's `application(_:,url:,options:)`
    @discardableResult private func resumeCloudRequest(using url: URL) -> Bool {

        // Compare the given URL's scheme to the app URL, then try to extract the request UUID from the URL.
        // If unable to find a match or if UUID is missing, return early.
        guard url.scheme?.lowercased() == appURLScheme.lowercased(), url.host == "Filestack",
            let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems,
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
                UIApplication.shared.open(authRedirectURL, options: [:], completionHandler: nil)
            } else {
                self.lastToken = request.token
                self.pendingRequests.removeValue(forKey: requestUUID)
                completionBlock(response)
            }
        }

        return true
    }
}

extension Filestack: PickerUploadControllerDelegate {

    func pickerUploadControllerDidFinish(_ pickerUploadController: PickerUploadController) {

        if let index = uploadControllers.index(of: pickerUploadController) {
            uploadControllers.remove(at: index)
        }
    }
}
