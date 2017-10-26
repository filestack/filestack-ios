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
}
