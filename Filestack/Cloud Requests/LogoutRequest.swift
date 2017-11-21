//
//  LogoutRequest.swift
//  Filestack
//
//  Created by Ruben Nine on 11/21/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation
import FilestackSDK
import Alamofire


internal typealias LogoutCompletionHandler = (_ response: LogoutResponse) -> Swift.Void

internal class LogoutResponse: NSObject {


    // MARK: - Properties

    public let contents: [String: Any]?
    public let error: Error?


    // MARK: - Lifecyle Functions

    internal init(contents: [String: Any]? = nil, error: Error? = nil) {

        self.contents = contents
        self.error = error
    }
}


internal final class LogoutRequest {


    // MARK: - Properties

    let provider: CloudProvider
    let apiKey: String
    let token: String


    // MARK: - Lifecyle Functions

    init(provider: CloudProvider, apiKey: String, token: String) {

        self.provider = provider
        self.apiKey = apiKey
        self.token = token
    }


    // MARK: - Internal Functions

    func perform(cloudService: CloudService, completionBlock: @escaping LogoutCompletionHandler) {

        let request = cloudService.logoutRequest(provider: provider, apiKey: apiKey, token: token)

        request.validate(statusCode: Constants.validHTTPResponseCodes)

        request.responseData { (dataResponse) in
            let response = LogoutResponse(contents: nil, error: dataResponse.error)

            completionBlock(response)
        }
    }
}
