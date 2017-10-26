//
//  Config.swift
//  Filestack
//
//  Created by Ruben Nine on 10/24/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation


internal struct Config {

    static let cloudURL = URL(string: "https://cloud.filestackapi.com")!
    static let validHTTPResponseCodes = Array(200..<300)
}
