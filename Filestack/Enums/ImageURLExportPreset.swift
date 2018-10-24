//
//  ImageURLExportPreset.swift
//  Filestack
//
//  Created by Ruben Nine on 11/22/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import UIKit

/**
 Represents an image URL export preset.
 */
@objc(FSImageURLExportPreset) public enum ImageURLExportPreset : Int {
  
  /// A preset for converting HEIF formatted images to JPEG.
  case compatible
  
  /// A preset for passing image data as-is to the client.
  case current
  
  @available(iOS 11.0, *)
  var asImagePickerControllerImageURLExportPreset: UIImagePickerController.ImageURLExportPreset {
    switch self {
    case .compatible:
      return .compatible
    case .current:
      return .current
    }
  }
}
