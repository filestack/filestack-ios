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

/**
 This class represents a response obtained from a cloud folder list request.
 */
@objc(FSFolderListResponse) public class FolderListResponse: NSObject, CloudResponse {
    // MARK: - Properties

    /// The contents payload as an array of dictionaries, where each dictionary represents an entry in the cloud.
    public let contents: [[String: Any]]?

    /// A next token used for pagination purposes. Optional.
    public let nextToken: String?

    /// A redirect URL to a cloud provider's OAuth page. Typically this is only required internally.
    public let authURL: URL?

    /// An error response. Optional.
    public let error: Error?

    // MARK: - Lifecyle Functions

    internal init(contents: [[String: Any]]? = nil,
                  nextToken: String? = nil,
                  authURL: URL? = nil,
                  error: Error? = nil) {
        self.contents = contents
        self.nextToken = nextToken
        self.authURL = authURL
        self.error = error
    }
}

internal final class FolderListRequest: CloudRequest, CancellableRequest {
    // MARK: - Properties

    let appURLScheme: String
    let apiKey: String
    let security: Security?
    let pageToken: String?
    let provider: CloudProvider
    let path: String

    private(set) var token: String?
    private weak var dataRequest: DataRequest?

    // MARK: - Lifecyle Functions

    init(appURLScheme: String,
         apiKey: String,
         security: Security? = nil,
         token: String? = nil,
         pageToken: String? = nil,
         provider: CloudProvider,
         path: String) {
        self.appURLScheme = appURLScheme
        self.apiKey = apiKey
        self.security = security
        self.token = token
        self.pageToken = pageToken
        self.provider = provider
        self.path = path
    }

    func cancel() {
        dataRequest?.cancel()
    }

    // MARK: - Internal Functions

    func perform(cloudService: CloudService, queue: DispatchQueue, completionBlock: @escaping CloudRequestCompletion) {
        let appRedirectURL = generateAppRedirectURL(using: UUID())

        let request = cloudService.folderListRequest(provider: provider,
                                                     path: path,
                                                     appURL: appRedirectURL,
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

                completionBlock(appRedirectURL, response)
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

    private func generateAppRedirectURL(using uuid: UUID) -> URL {
        return URL(string: appURLScheme.lowercased() + "://Filestack/?requestUUID=" + uuid.uuidString)!
    }
}
