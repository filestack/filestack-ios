//
//  CloudSource.swift
//  Filestack
//
//  Created by Ruben Nine on 11/7/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation


/**
 Represents a type of cloud source to be used in the picker.
 */
@objc(FSCloudSource) public enum CloudSource: UInt {
  
  /// Facebook
  case facebook
  
  /// Instagram
  case instagram
  
  /// Google Drive
  case googleDrive
  
  /// Dropbox
  case dropbox
  
  /// Box
  case box
  
  /// GitHub
  case gitHub
  
  /// Gmail
  case gmail
  
  /// Google Photos
  case googlePhotos
  
  /// OneDrive
  case oneDrive
  
  /// Amazon Drive
  case amazonDrive
  
  /// Custom Source
  case customSource
}

extension CloudSource: CellDescriptibleSource {
  /// Returns all the supported sources.
  public static func all() -> [CloudSource] {
    return [.facebook, .instagram, .googleDrive, .dropbox, .box, .gitHub,
            .gmail, .googlePhotos, .oneDrive, .amazonDrive, .customSource]
  }
  
  static func title() -> String {
    return "Cloud"
  }
  
  var provider: CloudProvider {
    return CloudProvider(rawValue: self.rawValue)!
  }
  
  var iconName: String {
    return "icon-\(provider.description)"
  }
}

extension CloudSource: CustomStringConvertible {

  /// Returns a `String` representation of self.
  public var description: String {
    switch self {
    case .facebook:
      return "Facebook"
    case .instagram:
      return "Instagram"
    case .googleDrive:
      return "Google Drive"
    case .dropbox:
      return "Dropbox"
    case .box:
      return "Box"
    case .gitHub:
      return "GitHub"
    case .gmail:
      return "GMail"
    case .googlePhotos:
      return "Google Photos"
    case .oneDrive:
      return "One Drive"
    case .amazonDrive:
      return "Cloud Drive"
    case .customSource:
      return "Custom Source"
    }
  }
}
