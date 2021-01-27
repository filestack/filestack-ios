//
//  CloudService.swift
//  Filestack
//
//  Created by Ruben Nine on 10/24/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import FilestackSDK
import Foundation

class CloudService {
    let session = URLSession.filestackDefault
    let baseURL = Constants.cloudURL

    func folderListRequest(provider: CloudProvider,
                           path: String,
                           authCallbackURL: URL,
                           apiKey: String,
                           security: Security? = nil,
                           token: String? = nil,
                           pageToken: String? = nil) -> URLRequest {
        let url = baseURL.appendingPathComponent("folder/list")

        var params: [String: Any] = [
            "apikey": apiKey,
            "appurl": authCallbackURL.absoluteString,
            "flow": "mobile",
        ]

        if let token = token {
            params["token"] = token
        }

        if let pageToken = pageToken {
            params["clouds"] = [
                provider.description: [
                    "path": path,
                    "next": pageToken,
                ],
            ]
        } else {
            params["clouds"] = [
                provider.description: [
                    "path": path,
                ],
            ]
        }

        if let security = security {
            params["policy"] = security.encodedPolicy
            params["signature"] = security.signature
        }

        return session.jsonRequest(url, payload: params)
    }

    func storeRequest(provider: CloudProvider,
                      path: String,
                      apiKey: String,
                      security: Security? = nil,
                      token: String? = nil,
                      storeOptions: StorageOptions) -> URLRequest {
        let url = baseURL.appendingPathComponent("store/")

        var params: [String: Any] = [
            "apikey": apiKey,
            "flow": "mobile",
            "clouds": [
                provider.description: [
                    "path": path,
                    "store": storeOptions.asDictionary(),
                ],
            ]
        ]

        if let token = token {
            params["token"] = token
        }

        if let security = security {
            params["policy"] = security.encodedPolicy
            params["signature"] = security.signature
        }

        return session.jsonRequest(url, payload: params)
    }

    func prefetchRequest(apiKey: String) -> URLRequest {
        let url = baseURL.appendingPathComponent("prefetch")
        let params: [String: Any] = ["apikey": apiKey]

        return session.jsonRequest(url, payload: params)
    }

    func logoutRequest(provider: CloudProvider, apiKey: String, token: String) -> URLRequest {
        let url = baseURL.appendingPathComponent("auth/logout")

        let params: [String: Any] = [
            "apikey": apiKey,
            "token": token,
            "flow": "mobile",
            "clouds": [
                provider.description: [:],
            ],
        ]

        return session.jsonRequest(url, payload: params)
    }
}
