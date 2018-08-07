//
//  BundleInfo.swift
//  Filestack
//
//  Created by Ruben Nine on 10/24/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation


final internal class BundleInfo {

    private init() {}

    static let thisBundle = Bundle(for: BundleInfo.self)

    /// Returns this bundle's build date
    static let buildDate: String? = thisBundle.infoDictionary?["BuildDate"] as? String

    /// Returns this bundle's name
    static let name: String? = thisBundle.infoDictionary?["CFBundleName"] as? String

    /// Returns this bundle's version
    static let version: String? = thisBundle.infoDictionary?["CFBundleShortVersionString"] as? String

    /// Returns this bundle's build number
    static let buildNumber: String? = thisBundle.infoDictionary?["CFBundleVersion"] as? String

    /// Returns this bundle's build information
    static func buildInfo() -> String? {

        guard let buildDate = buildDate, let name = name, let version = version, let buildNumber = buildNumber else {
            return nil
        }

        return "\(name) \(version) (build \(buildNumber)) built on \(buildDate)."
    }
}
