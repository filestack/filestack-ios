//
//  CancellableRequest.swift
//  Filestack
//
//  Created by Ruben Nine on 11/14/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation

/**
 This protocol is implemented by any classes representing a request that can be cancelled.
 */
@objc(FSCancellableRequest) public protocol CancellableRequest: AnyObject {
    /// Any cancellable requests must implement the `cancel()` function.
    @discardableResult func cancel() -> Bool
}
