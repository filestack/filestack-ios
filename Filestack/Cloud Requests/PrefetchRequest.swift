//
//  PrefetchRequest.swift
//  Filestack
//
//  Created by Ruben Nine on 11/8/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Alamofire
import Foundation

internal typealias PrefetchCompletionHandler = (_ response: PrefetchResponse) -> Swift.Void

internal class PrefetchResponse: NSObject {
    // MARK: - Properties

    @objc public let contents: [String: Any]?
    @objc public let error: Error?

    // MARK: - Lifecyle Functions

    internal init(contents: [String: Any]? = nil, error: Error? = nil) {
        self.contents = contents
        self.error = error
    }
}

internal final class PrefetchRequest {
    // MARK: - Properties

    let apiKey: String

    // MARK: - Lifecyle Functions

    init(apiKey: String) {
        self.apiKey = apiKey
    }

    // MARK: - Internal Functions

    func perform(cloudService: CloudService, completionBlock: @escaping PrefetchCompletionHandler) {
        let request = cloudService.prefetchRequest(apiKey: apiKey)

        request.validate(statusCode: Constants.validHTTPResponseCodes)

        request.responseJSON(completionHandler: { dataResponse in

            // Parse JSON, or return early with error if unable to parse.
            guard let data = dataResponse.data, let json = data.parseJSON() else {
                let response = PrefetchResponse(error: dataResponse.error)
                completionBlock(response)

                return
            }

            // Results received — return response with contents
            let response = PrefetchResponse(contents: json, error: dataResponse.error)
            completionBlock(response)
        })
    }
}
