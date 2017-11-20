//
//  CloudService.swift
//  Filestack
//
//  Created by Ruben Nine on 10/24/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation
import Alamofire
import FilestackSDK


internal class CloudService {

    let sessionManager = SessionManager.filestackDefault
    let baseURL = Constants.cloudURL

    func folderListRequest(provider: CloudProvider,
                           path: String,
                           appURL: URL,
                           apiKey: String,
                           security: Security? = nil,
                           token: String? = nil,
                           pageToken: String? = nil) -> DataRequest {

        let url = baseURL.appendingPathComponent("folder/list")

        var params: [String: Any] = [
            "flow": "mobile",
            "appurl": appURL.absoluteString,
            "apikey": apiKey,
        ]

        if let token = token {
            params["token"] = token
        }

        if let pageToken = pageToken {
            params["clouds"] = [
                provider.description: [
                    "path": path,
                    "next": pageToken
                ]
            ]
        } else {
            params["clouds"] = [
                provider.description: [
                    "path": path
                ]
            ]
        }

        if let security = security {
            params["policy"] = security.encodedPolicy
            params["signature"] = security.signature
        }

        return sessionManager.request(url, method: HTTPMethod.post, parameters: params, encoding: JSONEncoding.default)
    }

    func storeRequest(provider: CloudProvider,
                      path: String,
                      apiKey: String,
                      security: Security? = nil,
                      token: String? = nil,
                      storeOptions: StorageOptions) -> DataRequest {

        let url = baseURL.appendingPathComponent("store/")

        var params: [String: Any] = [
            "flow": "mobile",
            "apikey": apiKey,
        ]

        if let token = token {
            params["token"] = token
        }

        var storeOptionsJSON: [String: Any] = [
            "location": storeOptions.location.description.lowercased()
        ]

        if let storeRegion = storeOptions.region {
            storeOptionsJSON["region"] = storeRegion
        }

        if let storeContainer = storeOptions.container {
            storeOptionsJSON["container"] = storeContainer
        }

        if let storePath = storeOptions.path {
            storeOptionsJSON["path"] = storePath
        }

        if let storeAccess = storeOptions.access {
            storeOptionsJSON["access"] = storeAccess.description
        }

        if let storeFilename = storeOptions.filename {
            storeOptionsJSON["filename"] = storeFilename
        }

        params["clouds"] = [
            provider.description: [
                "path": path,
                "store": storeOptionsJSON
            ]
        ]

        if let security = security {
            params["policy"] = security.encodedPolicy
            params["signature"] = security.signature
        }

        return sessionManager.request(url, method: HTTPMethod.post, parameters: params, encoding: JSONEncoding.default)
    }

    func prefetchRequest(apiKey: String) -> DataRequest {

        let url = baseURL.appendingPathComponent("prefetch")
        let params: [String: Any] = ["apikey": apiKey]

        return sessionManager.request(url, method: HTTPMethod.post, parameters: params, encoding: JSONEncoding.default)
    }
}
