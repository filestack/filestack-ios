//
//  Bundle.swift
//  Filestack
//
//  Created by Ruben Nine on 13/10/2020.
//  Copyright © 2020 Filestack. All rights reserved.
//

import Foundation

private class BundleFinder {}

/// Returns the bundle that is associated to this module (supports SPM.)
let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleFinder.self)
    #endif
}()
