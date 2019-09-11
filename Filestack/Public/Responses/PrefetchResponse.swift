//
//  PrefetchResponse.swift
//  Filestack
//
//  Created by Ruben Nine on 11/09/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import Foundation

/// :nodoc:
@objc(FSPrefetchResponse) public class PrefetchResponse: NSObject {
    // MARK: - Properties

    @objc public let contents: [String: Any]?
    @objc public let error: Error?

    // MARK: - Lifecyle Functions

    init(contents: [String: Any]? = nil, error: Error? = nil) {
        self.contents = contents
        self.error = error
    }
}
