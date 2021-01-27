//
//  URLSession+FilestackDefault.swift
//  Filestack
//
//  Created by Ruben Nine on 10/24/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation

#if SWIFT_PACKAGE
#else
private class BundleFinder {}
#endif

extension URLSession {
    static var filestackDefault: URLSession {
        let configuration = URLSessionConfiguration.default

        configuration.isDiscretionary = false
        configuration.shouldUseExtendedBackgroundIdleMode = true
        configuration.httpMaximumConnectionsPerHost = 20
        configuration.httpShouldUsePipelining = true
        configuration.httpAdditionalHeaders = customHTTPHeaders

        return URLSession(configuration: configuration)
    }

    func jsonRequest(_ url: URL, payload: [String: Any], method: String = "POST") -> URLRequest {
        var request = URLRequest(url: url)

        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = method
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload, options: [])

        return request
    }
}

// MARK: - Private Functions

private extension URLSession {
    static var customHTTPHeaders: [String: String] {
        var defaultHeaders: [String: String] = [:]

        defaultHeaders["User-Agent"] = "filestack-ios \(shortVersionString)"
        defaultHeaders["Filestack-Source"] = "Swift-\(shortVersionString)"

        return defaultHeaders
    }

    static var shortVersionString: String {
        #if SWIFT_PACKAGE
        if let url = Bundle.module.url(forResource: "VERSION", withExtension: nil),
           let data = try? Data(contentsOf: url),
           let version = String(data: data, encoding: .utf8)?.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        {
            return version
        }
        #else
        if let info = Bundle(for: BundleFinder.self).infoDictionary,
           let version = info["CFBundleShortVersionString"] as? String {
            return version
        }
        #endif

        return "0.0.0"
    }
}
