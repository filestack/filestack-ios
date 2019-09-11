//
//  StoreResponse.swift
//  Filestack
//
//  Created by Ruben Nine on 11/09/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import Foundation

/// This class represents a response obtained from a store request.
@objc(FSStoreResponse) public class StoreResponse: NSObject, CloudResponse {
    // MARK: - Properties

    /// The contents payload as a dictionary containing details about the operation response.
    @objc public let contents: [String: Any]?

    /// A redirect URL to a cloud provider's OAuth page. Typically this is only required internally.
    @objc public let authURL: URL? = nil

    /// An error response. Optional.
    @objc public let error: Error?

    // MARK: - Lifecyle Functions

    init(contents: [String: Any]? = nil, error: Error? = nil) {
        self.contents = contents
        self.error = error
    }
}
