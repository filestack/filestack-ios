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

    let sessionManager = SessionManager.filestackDefault()
    let baseURL = Config.cloudURL

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
                      appURL: URL,
                      apiKey: String,
                      security: Security? = nil,
                      token: String? = nil,
                      storeLocation: StorageLocation = .s3,
                      storeRegion: String? = nil,
                      storeContainer: String? = nil,
                      storePath: String? = nil,
                      storeAccess: StorageAccess? = nil,
                      storeFilename: String? = nil) -> DataRequest {

        let url = baseURL.appendingPathComponent("store/")

        var params: [String: Any] = [
            "flow": "mobile",
            "appurl": appURL.absoluteString,
            "apikey": apiKey,
        ]

        if let token = token {
            params["token"] = token
        }

        var storeOptions: [String: Any] = [
            "location": storeLocation.description.lowercased()
        ]

        if let storeRegion = storeRegion {
            storeOptions["region"] = storeRegion
        }

        if let storeContainer = storeContainer {
            storeOptions["container"] = storeContainer
        }

        if let storePath = storePath {
            storeOptions["path"] = storePath
        }

        if let storeAccess = storeAccess {
            storeOptions["access"] = storeAccess.description
        }

        if let storeFilename = storeFilename {
            storeOptions["filename"] = storeFilename
        }

        params["clouds"] = [
            provider.description: [
                "path": path,
                "store": storeOptions
            ]
        ]

        if let security = security {
            params["policy"] = security.encodedPolicy
            params["signature"] = security.signature
        }

        return sessionManager.request(url, method: HTTPMethod.post, parameters: params, encoding: JSONEncoding.default)
    }
}
