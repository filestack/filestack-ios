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
    public let authRedirectURL: URL?

    /// An error response. Optional.
    public let error: Error?


    // MARK: - Lifecyle Functions

    internal init(contents: [[String: Any]]? = nil,
                  nextToken: String? = nil,
                  authRedirectURL: URL? = nil,
                  error: Error? = nil) {

        self.contents = contents
        self.nextToken = nextToken
        self.authRedirectURL = authRedirectURL
        self.error = error
    }
}


internal final class FolderListRequest: CloudRequest {

    // MARK: - Properties

    let appURLScheme: String
    let apiKey: String
    let security: Security?
    let pageToken: String?
    let provider: CloudProvider
    let path: String

    private(set) var token: String?


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


    // MARK: - Internal Functions

    func perform(cloudService: CloudService, completionBlock: @escaping CloudRequestCompletionHandler) {

        let requestUUID = generateRequestUUID()

        let request = cloudService.folderListRequest(provider: provider,
                                                     path: path,
                                                     appURL: appURLWithRequestUUID(uuid: requestUUID),
                                                     apiKey: apiKey,
                                                     security: security,
                                                     token: token,
                                                     pageToken: pageToken)

        request.validate(statusCode: Config.validHTTPResponseCodes)

        request.responseJSON(completionHandler: { dataResponse in
            // Parse JSON, or return early with error if unable to parse.
            guard let data = dataResponse.data, let json = data.parseJSON() else {
                let response = FolderListResponse(error: dataResponse.error)
                completionBlock(requestUUID, response)

                return
            }

            // Store any token we receive so we can use it next time.
            self.token = json["token"] as? String

            if let authRedirectURL = self.getAuthRedirectURL(from: json) {
                // Auth is required — redirect to authentication URL
                let response = FolderListResponse(authRedirectURL: authRedirectURL)
                completionBlock(requestUUID, response)
            } else if let results = self.getResults(from: json) {
                // Results received — return response with contents, and, optionally next token
                let contents = results["contents"] as? [[String: Any]]
                let nextToken: String? = (results["next"] as? String).flatMap { $0.count > 0 ? $0 : nil }
                let response = FolderListResponse(contents: contents, nextToken: nextToken, error: dataResponse.error)

                completionBlock(requestUUID, response)
            }
        })
    }


    // MARK: - Private Functions

    private func appURLWithRequestUUID(uuid: UUID) -> URL {

        return URL(string: appURLScheme + "://Filestack/?requestUUID=" + uuid.uuidString)!
    }
}
