//
//  ImageURLExportPreset.swift
//  Filestack
//
//  Created by Ruben Nine on 11/22/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import UIKit


@objc(FSImageURLExportPreset) public enum ImageURLExportPreset : Int {

    case compatible

    case current

    @available(iOS 11.0, *)
    internal var asImagePickerControllerImageURLExportPreset: UIImagePickerControllerImageURLExportPreset {

        switch self {
        case .compatible:

            return .compatible

        case .current:

            return .current
        }
    }
}
