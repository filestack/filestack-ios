//
//  Uploadable.swift
//  Filestack
//
//  Created by Mihály Papp on 30/07/2018.
//  Copyright © 2018 Filestack. All rights reserved.
//

import UIKit

protocol Uploadable: class {
  var isEditable: Bool {get}
  var associatedImage: UIImage {get}
  var smallDecsriptor: TypeDescriptor {get}
}

enum TypeDescriptor {
  case text(String)
  case image(UIImage)
}


extension UIImage: Uploadable {
  var isEditable: Bool {
    return true
  }
  
  var associatedImage: UIImage {
    return self
  }
  
  var smallDecsriptor: TypeDescriptor {
    return .image(UIImage.fromFilestackBundle("icon-upload"))
  }
}
