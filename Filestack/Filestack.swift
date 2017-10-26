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
public typealias CompletionHandler = (_ response: CloudResponse) -> Swift.Void


@objc(FSFilestack) public class Filestack: NSObject {

    // MARK: - Properties

    /// An API key obtained from the [Developer Portal](http://dev.filestack.com).
    public let apiKey: String

    public let appURL: URL

    /// A `Security` object. `nil` by default.
    public let security: Security?


    // MARK: - Private Properties

    private let client: Client
    private let cloudService = CloudService()

    private var pendingRequests: [String: (CloudRequest, CompletionHandler)]
    private var lastToken: String?

    fileprivate var uploadControllers: [PickerUploadController] = []


    // MARK: - Lifecyle Functions

    /**
        Default initializer.

        - SeeAlso: `Security`

        - Parameter apiKey: An API key obtained from the Developer Portal.
        - Parameter security: A `Security` object. `nil` by default.
     */
    @objc public init(appURL: URL, apiKey: String, security: Security? = nil, lastToken: String? = nil) {

        self.appURL = appURL
        self.apiKey = apiKey
        self.security = security
        self.lastToken = lastToken
        self.client = Client(apiKey: apiKey, security: security)
        self.pendingRequests = [:]

        super.init()
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
                           completionBlock: @escaping FolderListCompletionHandler) {

        let request = FolderListRequest(appURL: appURL,
                                       apiKey: apiKey,
                                       security: security,
                                       token:  lastToken,
                                       pageToken: pageToken,
                                       provider: provider,
                                       path: path)

        let genericCompletionBlock: CompletionHandler = { response in
            guard let response = response as? FolderListResponse else { return }
            completionBlock(response)
        }

        perform(request: request, completionBlock: genericCompletionBlock)
    }

    /// To be called by the app delegate's `application(_:,url:,options:)`
    public func resumeCloudRequest(using url: URL) {

        // Compare the given URL's scheme to the app URL, then try to extract the request UUID from the URL.
        // If unable to find a match or if UUID is missing, return early.
        guard url.scheme?.lowercased() == appURL.scheme?.lowercased(), let requestUUID = url.host else {
            return
        }

        // Find pending request identified by `requestUUID` or return early.
        guard let (request, completionBlock) = pendingRequests[requestUUID] else {
            return
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
}

extension Filestack: PickerUploadControllerDelegate {

    func pickerUploadControllerDidFinish(_ pickerUploadController: PickerUploadController) {

        if let index = uploadControllers.index(of: pickerUploadController) {
            uploadControllers.remove(at: index)
        }
    }
}
