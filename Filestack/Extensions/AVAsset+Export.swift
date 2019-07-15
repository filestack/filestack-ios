//
//  AVAsset+Export.swift
//  Filestack
//
//  Created by Ruben Nine on 7/11/19.
//  Copyright © 2019 Filestack. All rights reserved.
//

import AVKit

extension AVAsset {
    func videoExportSession(using preset: String) -> AVAssetExportSession? {
        let export = AVAssetExportSession(asset: self, presetName: preferredVideoPreset(using: preset))
        let tempDirURL = FileManager.default.temporaryDirectory

        export?.outputURL = tempDirURL.appendingPathComponent(UUID().uuidString).appendingPathExtension("mov")
        export?.outputFileType = .mov

        return export
    }

    private func preferredVideoPreset(using preset: String) -> String {
        let compatiblePresets = AVAssetExportSession.exportPresets(compatibleWith: self)

        if compatiblePresets.contains(preset) {
            return preset
        }

        return AVAssetExportPresetPassthrough
    }
}
