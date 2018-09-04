//
//  StoreRequest.swift
//  Filestack
//
//  Created by Ruben Nine on 10/27/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation
import FilestackSDK
import Alamofire


/**
     This class represents a response obtained from a cloud store request.
 */
@objc(FSStoreResponse) public class StoreResponse: NSObject, CloudResponse {


    // MARK: - Properties

    /// The contents payload as a dictionary containing details about the operation response.
    public let contents: [String: Any]?

    /// A redirect URL to a cloud provider's OAuth page. Typically this is only required internally.
    public let authURL: URL? = nil

    /// An error response. Optional.
    public let error: Error?


    // MARK: - Lifecyle Functions

    internal init(contents: [String: Any]? = nil, error: Error? = nil) {

        self.contents = contents
        self.error = error
    }
}


internal final class StoreRequest: CloudRequest, CancellableRequest {


    // MARK: - Properties

    let apiKey: String
    let security: Security?
    let provider: CloudProvider
    let path: String
    let storeOptions: StorageOptions

    private(set) var token: String?
    private weak var dataRequest: DataRequest?


    // MARK: - Lifecyle Functions

    init(apiKey: String,
         security: Security? = nil,
         token: String? = nil,
         provider: CloudProvider,
         path: String,
         storeOptions: StorageOptions) {

        self.apiKey = apiKey
        self.security = security
        self.token = token
        self.provider = provider
        self.path = path
        self.storeOptions = storeOptions
    }

    func cancel() {

        dataRequest?.cancel()
    }

    // MARK: - Internal Functions

    func perform(cloudService: CloudService, queue: DispatchQueue, completionBlock: @escaping CloudRequestCompletion) {

        let request = cloudService.storeRequest(provider: provider,
                                                path: path,
                                                apiKey: apiKey,
                                                security: security,
                                                token: token,
                                                storeOptions: storeOptions)

        dataRequest = request

        request.validate(statusCode: Constants.validHTTPResponseCodes)

        request.responseJSON(queue: queue) { dataResponse in
            // Parse JSON, or return early with error if unable to parse.
            guard let data = dataResponse.data, let json = data.parseJSON() else {
                let response = StoreResponse(error: dataResponse.error)
                completionBlock(nil, response)

                return
            }

            // Store any token we receive so we can use it next time.
            self.token = json["token"] as? String

            if let results = self.getResults(from: json) {
                // Results received — return response with contents
                let response = StoreResponse(contents: results, error: dataResponse.error)
                completionBlock(nil, response)
            }
        }
    }
}
