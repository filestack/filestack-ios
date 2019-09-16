//
//  StoreRequest.swift
//  Filestack
//
//  Created by Ruben Nine on 10/27/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Alamofire
import FilestackSDK
import Foundation

final class StoreRequest: CloudRequest, Cancellable {
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

    // MARK: - Cancellable Protocol Implementation

    @discardableResult func cancel() -> Bool {
        guard let dataRequest = dataRequest else { return false }
        dataRequest.cancel()

        return true
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
