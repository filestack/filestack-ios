//
//  EditorViewController+EditDataSource.swift
//  EditImage
//
//  Created by Mihály Papp on 23/07/2018.
//  Copyright © 2018 Mihály Papp. All rights reserved.
//

import UIKit
import AVFoundation

protocol EditDataSource: class {
  var imageFrame: CGRect {get}
  var imageSize: CGSize {get}
  var imageOrigin: CGPoint {get}
  var imageActualSize: CGSize {get}
}

extension EditorViewController: EditDataSource {
  var imageFrame: CGRect {
    return AVMakeRect(aspectRatio: currentImage.size, insideRect: imageView.bounds)
  }

  var imageSize: CGSize {
    return imageFrame.size
  }
  
  var imageOrigin: CGPoint {
    return imageFrame.origin
  }
  
  var imageActualSize: CGSize {
    return currentImage.size
  }
}
