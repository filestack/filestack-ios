//
//  CloudRequest.swift
//  Filestack
//
//  Created by Ruben Nine on 10/25/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation

@objc(FSCloudResponse) public protocol CloudResponse {

    var error: Error? { get }
    var authRedirectURL: URL? { get }
}

internal typealias CloudActionCompletionHandler = (_ uuid: String, _ response: CloudResponse) -> Swift.Void

internal protocol CloudRequest {

    var token: String? { get }

    func perform(cloudService: CloudService, completionBlock: @escaping CloudActionCompletionHandler)
    func parseJSON(data: Data) -> [String: Any]?
}

internal extension CloudRequest {

    func parseJSON(data: Data) -> [String: Any]? {

        return (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
    }
}
