//
//  SourceProvider.swift
//  SourceProvider
//
//  Created by Ruben Nine on 30/7/21.
//  Copyright © 2021 Filestack. All rights reserved.
//

import UIKit

/// `SourceProvider` defines the protocol that must be implemented by any view controllers that should be used to
/// pick files using an user-provided implementation.
public protocol SourceProvider: UIViewController {
    /// Defines the source provider delegate.
    var sourceProviderDelegate: SourceProviderDelegate? { set get }

    /// Initializer for this source provider.
    init()
}
