//
//  CancellableRequest.swift
//  Filestack
//
//  Created by Ruben Nine on 11/14/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation


public protocol CancellableRequest {

    func cancel()
}
