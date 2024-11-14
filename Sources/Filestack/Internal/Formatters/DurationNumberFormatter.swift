//
//  DurationNumberFormatter.swift
//  Filestack
//
//  Created by Mihály Papp on 02/08/2018.
//  Copyright © 2018 Filestack. All rights reserved.
//

import Foundation

class DurationFormatter: NumberFormatter, @unchecked Sendable {
    func string(from seconds: Double) -> String {
        let hours = Int(seconds / 3600)
        let minutes = Int(seconds.truncatingRemainder(dividingBy: 3600) / 60)
        let seconds = Int(seconds.truncatingRemainder(dividingBy: 60))
        if hours > 0 {
            return String(format: "%i:%02i:%02i", hours, minutes, seconds)
        } else {
            return String(format: "%i:%02i", minutes, seconds)
        }
    }
}
