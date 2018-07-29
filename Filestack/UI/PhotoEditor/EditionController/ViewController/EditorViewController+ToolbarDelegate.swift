//
//  EditorViewController+ToolbarDelegate.swift
//  EditImage
//
//  Created by Mihály Papp on 23/07/2018.
//  Copyright © 2018 Mihály Papp. All rights reserved.
//

import Foundation

extension EditorViewController: EditorToolbarDelegate {
  func cancelSelected() {
    dismiss(animated: true)
  }
  
  func rotateSelected() {
    editImage(to: currentImage.rotated(clockwise: false))
    cropHandler.rotateCounterClockwise()
    circleHandler.rotateCounterClockwise()
  }
  
  func cropSelected() {
    switch editMode {
    case .crop: editMode = .none
    case .circle, .none: editMode = .crop
    }
  }
  
  func circleSelected() {
    switch editMode {
    case .circle: editMode = .none
    case .crop, .none: editMode = .circle
    }
  }
  
  func saveSelected() {
    switch editMode {
    case .crop: editImage(to: currentImage.cropped(by: cropHandler.actualEdgeInsets))
    case .circle: editImage(to: currentImage.circled(center: circleHandler.actualCenter, radius: circleHandler.actualRadius))
    case .none: return
    }
    editMode = .none
  }
  
  func doneSelected() {
    completion(currentImage)
    dismiss(animated: true)
  }
  
  func undoSelected() {
    changeImage(to: currentImageIndex - 1)
  }
  
  func redoSelected() {
    changeImage(to: currentImageIndex + 1)
  }
}
