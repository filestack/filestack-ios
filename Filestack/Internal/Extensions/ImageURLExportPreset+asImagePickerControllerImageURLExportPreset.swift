//
//  ImageURLExportPreset+asImagePickerControllerImageURLExportPreset.swift
//  Filestack
//
//  Created by Ruben Nine on 11/09/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import UIKit

extension ImageURLExportPreset {
    var asImagePickerControllerImageURLExportPreset: UIImagePickerController.ImageURLExportPreset {
        switch self {
        case .compatible:
            return .compatible
        case .current:
            return .current
        }
    }
}
