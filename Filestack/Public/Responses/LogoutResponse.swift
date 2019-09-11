//
//  LogoutResponse.swift
//  Filestack
//
//  Created by Ruben Nine on 11/09/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import Foundation

/// This class represents a response obtained from a logout request.
@objc(FSLogoutResponse) public class LogoutResponse: NSObject {
    // MARK: - Properties

    /// An error response. Optional.
    @objc public let error: Error?

    // MARK: - Lifecyle Functions

    init(error: Error? = nil) {
        self.error = error
    }
}
