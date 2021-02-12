//
//  PickerBehavior.swift
//  Filestack
//
//  Created by Ruben Nine on 11/2/21.
//  Copyright © 2021 Filestack. All rights reserved.
//

import Foundation
import FilestackSDK

/// Represents the picker's pick behavior.
public enum PickerBehavior: Equatable {
    /// After finishing picking, local files are uploaded and cloud files are stored at the store destination.
    case uploadAndStore(uploadOptions: UploadOptions)

    /// After finishing picking, only cloud files are stored at the store destination.
    case storeOnly
}
