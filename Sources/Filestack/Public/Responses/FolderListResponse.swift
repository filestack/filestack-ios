//
//  FolderListResponse.swift
//  Filestack
//
//  Created by Ruben Nine on 11/09/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import Foundation

/// This class represents a response obtained from a folder list request.
@objc(FSFolderListResponse) public class FolderListResponse: NSObject, CloudResponse {
    // MARK: - Properties

    /// The contents payload as an array of dictionaries, where each dictionary represents an entry in the cloud.
    @objc public let contents: [[String: Any]]?

    /// A next token used for pagination purposes. Optional.
    @objc public let nextToken: String?

    /// A redirect URL to a cloud provider's OAuth page. Typically this is only required internally.
    @objc public let authURL: URL?

    /// An error response. Optional.
    @objc public let error: Error?

    // MARK: - Lifecyle Functions

    init(contents: [[String: Any]]? = nil,
         nextToken: String? = nil,
         authURL: URL? = nil,
         error: Error? = nil) {
        self.contents = contents
        self.nextToken = nextToken
        self.authURL = authURL
        self.error = error
    }
}
