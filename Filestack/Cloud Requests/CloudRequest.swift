//
//  CloudRequest.swift
//  Filestack
//
//  Created by Ruben Nine on 10/25/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation
import FilestackSDK


/// :nodoc:
@objc(FSCloudResponse) public protocol CloudResponse {

    var error: Error? { get }
    var authRedirectURL: URL? { get }
}

internal typealias CloudRequestCompletionHandler = (_ uuid: UUID, _ response: CloudResponse) -> Swift.Void

internal protocol CloudRequest {

    var token: String? { get }
    var provider: CloudProvider { get }
    var apiKey: String { get }
    var security: Security? { get }

    func perform(cloudService: CloudService, queue: DispatchQueue, completionBlock: @escaping CloudRequestCompletionHandler)
    func getResults(from json: [String: Any]) -> [String: Any]?
    func generateRequestUUID() -> UUID
}

internal extension CloudRequest {

    func getResults(from json: [String: Any]) -> [String: Any]? {

        return json[provider.description] as? [String: Any]
    }

    func generateRequestUUID() -> UUID {

        return UUID()
    }
}
