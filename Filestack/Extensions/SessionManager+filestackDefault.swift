//
//  SessionManager+filestackDefault.swift
//  Filestack
//
//  Created by Ruben Nine on 10/24/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation
import Alamofire


internal extension SessionManager {

    class func filestackDefault() -> SessionManager {

        var defaultHeaders = SessionManager.defaultHTTPHeaders

        if let shortVersionString = BundleInfo.version {
            defaultHeaders["User-Agent"] = "filestack-ios \(shortVersionString)"
            defaultHeaders["Filestack-Source"] = "Swift-\(shortVersionString)"
        }

        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = defaultHeaders

        return SessionManager(configuration: configuration)
    }
}
