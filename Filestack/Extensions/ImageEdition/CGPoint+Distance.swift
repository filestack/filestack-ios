//
//  CGPoint+Distance.swift
//  EditImage
//
//  Created by Mihály Papp on 09/07/2018.
//  Copyright © 2018 Mihály Papp. All rights reserved.
//

import UIKit

extension CGPoint {
  enum Metric {
    case euclidean
    case manhattan
    case maximum
  }
  
  func distance(to point: CGPoint, metric: Metric = .euclidean) -> CGFloat {
    switch metric {
    case .euclidean: return euclideanDistance(to: point)
    case .manhattan: return manhattanDistance(to: point)
    case .maximum: return maximumDistance(to: point)
    }
  }
  
  func euclideanDistance(to point: CGPoint) -> CGFloat {
    return sqrt(pow(x - point.x, 2) + pow(y - point.y, 2))
  }
  
  func manhattanDistance(to point: CGPoint) -> CGFloat {
    return abs(x - point.x) + abs(y - point.y)
  }
  
  func maximumDistance(to point: CGPoint) -> CGFloat {
    return max(abs(x - point.x), abs(y - point.y))
  }
}
