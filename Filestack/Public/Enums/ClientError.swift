//
//  Errors.swift
//  Filestack
//
//  Created by Ruben Nine on 16/09/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import Foundation

public enum ClientError: Error {
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
