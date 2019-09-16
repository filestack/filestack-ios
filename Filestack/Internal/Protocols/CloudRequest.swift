//
//  CloudRequest.swift
//  Filestack
//
//  Created by Ruben Nine on 10/25/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import FilestackSDK
import Foundation

typealias CloudRequestCompletion = (_ appRedirectURL: URL?, _ response: CloudResponse) -> Void

protocol CloudRequest {
    var token: String? { get }
    var provider: CloudProvider { get }
    var apiKey: String { get }
    var security: Security? { get }

    func perform(cloudService: CloudService, queue: DispatchQueue, completionBlock: @escaping CloudRequestCompletion)
    func getResults(from json: [String: Any]) -> [String: Any]?
}

extension CloudRequest {
    func getResults(from json: [String: Any]) -> [String: Any]? {
        return json[provider.description] as? [String: Any]
    }
}
