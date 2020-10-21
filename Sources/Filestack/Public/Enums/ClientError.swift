//
//  Errors.swift
//  Filestack
//
//  Created by Ruben Nine on 16/09/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import Foundation

/// A specific kind of `Error` that may be returned by the `Client`.
public enum ClientError: Error {
    /// Authentication failed.
    case authenticationFailed
}

extension ClientError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .authenticationFailed:
            return NSLocalizedString("Unable to authenticate.", comment: "")
        }
    }
}
