//
//  Data+JSON.swift
//  Filestack
//
//  Created by Ruben Nine on 11/8/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation

extension Data {
    func parseJSON() -> [String: Any]? {
        return (try? JSONSerialization.jsonObject(with: self)) as? [String: Any]
    }
}
