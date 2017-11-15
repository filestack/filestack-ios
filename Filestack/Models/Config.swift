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

    /// This setting determines what cloud sources are available when using the interactive uploader.
    /// By default, it contains all the supported cloud sources.
    /// - Note: Please notice that a custom source will only be displayed if enabled on Filestack's
    /// [Developer Portal](http://dev.filestack.com), regardless of whether it is present in this list.
    public var availableCloudSources: [CloudSource] = CloudSource.all()

    /// This setting determines what local sources are available when using the interactive uploader.
    /// By default, it contains all the supported local sources.
    public var availableLocalSources: [LocalSource] = LocalSource.all()
}
