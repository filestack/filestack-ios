//
//  UIView+Constraints.swift
//  EditImage
//
//  Created by Mihály Papp on 05/07/2018.
//  Copyright © 2018 Mihály Papp. All rights reserved.
//

import UIKit

extension UIView {
  func fill(with subview: UIView,
            connectingEdges: [NSLayoutAttribute] = [.top, .bottom, .left, .right],
            inset: CGFloat = 0,
            withSafeAreaRespecting useSafeArea: Bool = false) {
    subview.translatesAutoresizingMaskIntoConstraints = false
    if !subviews.contains(subview) {
      addSubview(subview)
    }
    connect(edges: connectingEdges, of: subview, inset: inset, withSafeAreaRespecting: useSafeArea)
  }
  
  func connect(edges: [NSLayoutAttribute],
               of subview: UIView,
               inset: CGFloat = 0,
               withSafeAreaRespecting useSafeArea: Bool = false) {
    guard subviews.contains(subview) else { return }
    let primaryItem: Any
    if #available(iOS 11.0, *) {
      primaryItem = useSafeArea ? self.safeAreaLayoutGuide : self
    } else {
      primaryItem = self
    }
    for edge in edges {
      let reversedEdges: [NSLayoutAttribute] = [.top, .left, .topMargin, .leftMargin]
      let offset = reversedEdges.contains(edge) ? -inset : inset
      NSLayoutConstraint(item: primaryItem, attribute: edge, relatedBy: .equal,
                         toItem: subview, attribute: edge, multiplier: 1, constant: offset).isActive = true
    }
  }
}
