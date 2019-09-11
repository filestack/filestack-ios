//
//  LocalProvider.swift
//  Filestack
//
//  Created by Ruben Nine on 11/09/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import Foundation

/// Represents a local provider to be used by a `LocalSource`.
@objc(FSLocalProvider) public enum LocalProvider: UInt {
    /// Camera
    case camera

    /// Photo Library
    case photoLibrary

    /// Documents
    case documents
}
