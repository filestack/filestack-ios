//
//  FolderListRequest.swift
//  Filestack
//
//  Created by Ruben Nine on 10/25/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Alamofire
import FilestackSDK
import Foundation

final class FolderListRequest: CloudRequest, Cancellable {
    // MARK: - Properties

    let authCallbackURL: URL
    let apiKey: String
    let security: Security?
    let pageToken: String?
    let provider: CloudProvider
    let path: String

    private(set) var token: String?
    private weak var dataRequest: DataRequest?

    // MARK: - Lifecyle Functions

    init(authCallbackURL: URL,
         apiKey: String,
         security: Security? = nil,
         token: String? = nil,
         pageToken: String? = nil,
         provider: CloudProvider,
         path: String) {
        self.authCallbackURL = authCallbackURL
        self.apiKey = apiKey
        self.security = security
        self.token = token
        self.pageToken = pageToken
        self.provider = provider
        self.path = path
    }

    // MARK: - Cancellable Protocol Implementation

    @discardableResult func cancel() -> Bool {
        guard let dataRequest = dataRequest else { return false }
        dataRequest.cancel()

        return true
    }

    // MARK: - Internal Functions

    func perform(cloudService: CloudService, queue: DispatchQueue, completionBlock: @escaping CloudRequestCompletion) -> DataRequest {
        let request = cloudService.folderListRequest(provider: provider,
                                                     path: path,
                                                     authCallbackURL: authCallbackURL,
                                                     apiKey: apiKey,
                                                     security: security,
                                                     token: token,
                                                     pageToken: pageToken)

        dataRequest = request

        request.validate(statusCode: Constants.validHTTPResponseCodes)

        request.responseJSON(queue: queue) { dataResponse in
            // Parse JSON, or return early with error if unable to parse.
            guard let data = dataResponse.data, let json = data.parseJSON() else {
                let response = FolderListResponse(error: dataResponse.error)

                completionBlock(nil, response)

                return
            }

            // Store any token we receive so we can use it next time.
            self.token = json["token"] as? String

            if let authURL = self.getAuthURL(from: json) {
                // Auth is required — redirect to authentication URL
                let response = FolderListResponse(authURL: authURL)

                completionBlock(self.authCallbackURL, response)
            } else if let results = self.getResults(from: json) {
                // Results received — return response with contents, and, optionally next token
                let contents = results["contents"] as? [[String: Any]]
                let nextToken: String? = self.token(from: results["next"] as? String)
                let response = FolderListResponse(contents: contents, nextToken: nextToken, error: dataResponse.error)

                completionBlock(nil, response)
            } else {
                let response = FolderListResponse(contents: nil, nextToken: nil, error: dataResponse.error)

                completionBlock(nil, response)
            }
        }

        return request
    }

    private func token(from string: String?) -> String? {
        guard let string = string, !string.isEmpty else { return nil }
        return string
    }

    // MARK: - Private Functions

    func getAuthURL(from json: [String: Any]) -> URL? {
        guard let providerJSON = json[provider.description] as? [String: Any] else { return nil }
        guard let authJSON = providerJSON["auth"] as? [String: Any] else { return nil }
        guard let redirectURLString = authJSON["redirect_url"] as? String else { return nil }

        return URL(string: redirectURLString)
    }
}
