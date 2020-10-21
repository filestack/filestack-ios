//
//  Uploadable.swift
//  Filestack
//
//  Created by Mihály Papp on 30/07/2018.
//  Copyright © 2018 Filestack. All rights reserved.
//

import AVFoundation
import UIKit

protocol Uploadable: AnyObject {
    var isEditable: Bool { get }
    var associatedImage: UIImage { get }
    var typeIcon: UIImage { get }
    var additionalInfo: String? { get }
}

extension UIImage: Uploadable {
    var isEditable: Bool { true }
    var associatedImage: UIImage { self }
    var typeIcon: UIImage { UIImage.fromFilestackBundle("icon-image").withRenderingMode(.alwaysTemplate) }
    var additionalInfo: String? { nil }
}

extension AVAsset: Uploadable {
    var isEditable: Bool { false }

    var associatedImage: UIImage {
        let beginning = CMTime(seconds: 0, preferredTimescale: 1)
        do {
            let cgImage = try AVAssetImageGenerator(asset: self).copyCGImage(at: beginning, actualTime: nil)
            return UIImage(cgImage: cgImage)
        } catch _ {
            return UIImage() // TODO: return placeholder
        }
    }

    var typeIcon: UIImage { UIImage.fromFilestackBundle("icon-file-video").withRenderingMode(.alwaysTemplate) }

    var additionalInfo: String? { DurationFormatter().string(from: duration.seconds) }
}
