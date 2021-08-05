//
//  SourceProviderDelegate.swift
//  SourceProviderDelegate
//
//  Created by Ruben Nine on 30/7/21.
//  Copyright © 2021 Filestack. All rights reserved.
//

import UIKit

public protocol SourceProviderDelegate: AnyObject {
    /// Called when one or more URLs were picked by this source provider.
    func sourceProviderPicked(urls: [URL])

    /// Called when source provider is cancelled (either by the user or programmatically.)
    func sourceProviderCancelled()
}
