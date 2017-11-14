//
//  Config.swift
//  Filestack
//
//  Created by Ruben Nine on 11/14/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation

/**
    The `Config` class is used together with `Filestack` to configure certain aspects of the API.
 */
@objc(FSConfig) public class Config: NSObject {

    /// An URL scheme supported by the app. This is required to complete the cloud provider's authentication flow.
    public var appURLScheme: String? = nil

    /// This policy controls the thumbnail's caching behavior when browsing cloud contents in the interactive uploader.
    public var cloudThumbnailCachePolicy: URLRequest.CachePolicy = .reloadIgnoringLocalCacheData
}
