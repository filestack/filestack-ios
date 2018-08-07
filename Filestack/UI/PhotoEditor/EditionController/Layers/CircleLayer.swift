//
//  CropLayer.swift
//  EditImage
//
//  Created by Mihály Papp on 12/07/2018.
//  Copyright © 2018 Mihály Papp. All rights reserved.
//

import UIKit

class CircleLayer: CALayer {
  
  var imageFrame = CGRect.zero {
    didSet {
      updateSublayers()
    }
  }
  
  var circleRadius: CGFloat = 0 {
    didSet {
      updateSublayers()
    }
  }
  
  var circleCenter = CGPoint.zero {
    didSet {
      updateSublayers()
    }
  }
  
  override init() {
    super.init()
    addSublayer(outsideLayer)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private lazy var outsideLayer: CAShapeLayer = {
    let layer = CAShapeLayer()
    layer.path = outsidePath
    layer.fillRule = kCAFillRuleEvenOdd
    layer.backgroundColor = UIColor.black.cgColor
    layer.opacity = 0.7
    return layer
  }()
}

private extension CircleLayer {
  
  func updateSublayers() {
    outsideLayer.path = outsidePath
  }
  
  var outsidePath: CGPath {
    let origin = CGPoint(x: circleCenter.x - circleRadius, y: circleCenter.y - circleRadius)
    let rect = CGRect(origin: origin, size: CGSize(width: circleRadius * 2, height: circleRadius * 2))
    let path = UIBezierPath(ovalIn: rect)
    path.append(UIBezierPath(rect: imageFrame))
    return path.cgPath
  }
}
