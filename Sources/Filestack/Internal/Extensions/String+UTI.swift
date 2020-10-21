//
//  String+UTI.swift
//  Filestack
//
//  Created by Ruben Nine on 7/1/19.
//  Copyright © 2019 Filestack. All rights reserved.
//

import Foundation
import MobileCoreServices.UTType

extension String {
    var UTI: CFString? {
        var ext = (self as NSString).pathExtension

        if ext.isEmpty {
            ext = "txt"
        }

        guard let utiRef = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, ext as CFString, nil) else { return nil }

        let uti = utiRef.takeUnretainedValue()
        utiRef.release()

        return uti
    }
}
