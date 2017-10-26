//
//  FolderListRequest.swift
//  Filestack
//
//  Created by Ruben Nine on 10/25/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation
import FilestackSDK
import Alamofire


@objc(FSFolderListResponse) public class FolderListResponse: NSObject, CloudResponse {

    public let contents: [[String: Any]]?
    public let nextToken: String?
    public let authRedirectURL: URL?
    public let error: Error?

    internal init(contents: [[String: Any]]? = nil, nextToken: String? = nil, authRedirectURL: URL? = nil, error: Error? = nil) {

        self.contents = contents
        self.nextToken = nextToken
        self.authRedirectURL = authRedirectURL
        self.error = error
    }
}


internal final class FolderListRequest: CloudRequest {

    // MARK: - Properties

    let apiKey: String
    let security: Security?
    let provider: CloudProvider
    let path: String
    let appURL: URL
    let pageToken: String?

    var token: String?


    // MARK: - Lifecyle Functions

    init(appURL: URL,
         apiKey: String,
         security: Security? = nil,
         token: String? = nil,
         pageToken: String? = nil,
         provider: CloudProvider,
         path: String) {

        self.appURL = appURL
        self.apiKey = apiKey
        self.security = security
        self.token = token
        self.pageToken = pageToken
        self.provider = provider
        self.path = path
    }


    // MARK: - Internal Functions

    func perform(cloudService: CloudService, completionBlock: @escaping CloudActionCompletionHandler) {

        let actionUUID = UUID().uuidString
        let appURLWithUUID = URL(string: "\(appURL.absoluteString)\(actionUUID)")!

        let request = cloudService.folderListRequest(provider: provider,
                                                     path: path,
                                                     appURL: appURLWithUUID,
                                                     apiKey: apiKey,
                                                     security: security,
                                                     token: token,
                                                     pageToken: pageToken)

        request.validate(statusCode: Config.validHTTPResponseCodes)

        request.responseJSON(completionHandler: { dataResponse in
            // Parse JSON, or return early with error if unable to parse.
            guard let data = dataResponse.data, let json = self.parseJSON(data: data) else {
                let response = FolderListResponse(error: dataResponse.error)
                completionBlock(actionUUID, response)

                return
            }

            // Store any token we receive so we can use it next time.
            self.token = json["token"] as? String

            if let authRedirectURL = self.getAuthRedirectURL(from: json) {
                // Auth is required — redirect to authentication URL
                let response = FolderListResponse(authRedirectURL: authRedirectURL)
                completionBlock(actionUUID, response)
            } else if let results = self.getResults(from: json) {
                // Results received — return response with contents, and, optionally next token
                let contents = results["contents"] as? [[String: Any]]
                let nextToken: String? = (results["next"] as? String).flatMap { $0.count > 0 ? $0 : nil }
                let response = FolderListResponse(contents: contents, nextToken: nextToken, error: dataResponse.error)

                completionBlock(actionUUID, response)
            }
        })
    }


    // MARK: - Private Functions

    private func getAuthRedirectURL(from json: [String: Any]) -> URL? {

        guard let providerJSON = json[provider.description] as? [String: Any] else { return nil }
        guard let authJSON = providerJSON["auth"] as? [String: Any] else { return nil }
        guard let redirectURLString = authJSON["redirect_url"] as? String else { return nil }

        return URL(string: redirectURLString)
    }

    private func getResults(from json: [String: Any]) -> [String: Any]? {

        return json[provider.description] as? [String: Any]
    }
}
