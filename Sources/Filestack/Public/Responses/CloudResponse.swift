//
//  CloudResponse.swift
//  Filestack
//
//  Created by Ruben Nine on 11/09/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import Foundation

/// :nodoc:
@objc(FSCloudResponse) public protocol CloudResponse {
    @objc var error: Error? { get }
    @objc var authURL: URL? { get }
}
