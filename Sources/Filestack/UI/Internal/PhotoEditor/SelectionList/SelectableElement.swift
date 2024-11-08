//
//  SelectableElement.swift
//  Filestack
//
//  Created by Ruben Nine on 7/11/19.
//  Copyright © 2019 Filestack. All rights reserved.
//

import Photos
import UIKit

protocol SelectableElementDelegate: AnyObject {
    func selectableElementThumbnailChanged(selectableElement: SelectableElement)
}

class SelectableElement {
    let isEditable: Bool
    let asset: PHAsset
    
    weak var delegate: SelectableElementDelegate?
    
    private(set) var additionalInfo: String?
    private(set) var localURL: URL?
    
    var mediaTypeImage: UIImage? {
        switch asset.mediaType {
        case .image:
            return UIImage.fromFilestackBundle("icon-image").withRenderingMode(.alwaysTemplate)
        case .video:
            return UIImage.fromFilestackBundle("icon-video").withRenderingMode(.alwaysTemplate)
        default:
            return nil
        }
    }
    
    var thumbnail: UIImage? {
        didSet {
            DispatchQueue.main.async {
                self.delegate?.selectableElementThumbnailChanged(selectableElement: self)
            }
        }
    }
    
    var thumbnailSize: CGSize = CGSize(width: 512, height: 512)
    var imageExportQuality: Float = 100
    var imageExportPreset: ImageURLExportPreset = .current
    var videoExportPreset: String = AVAssetExportPresetHEVCHighestQuality
    
    private var requestIDs: [PHImageRequestID] = []
    
    // MARK: - Lifecycle Functions
    
    init(asset: PHAsset) {
        self.asset = asset
        
        switch asset.mediaType {
        case .image:
            isEditable = true
        default:
            isEditable = false
        }
        
        setup()
    }
    
    deinit {
        for requestID in requestIDs {
            PHImageManager.default().cancelImageRequest(requestID)
        }
        
        requestIDs.removeAll()
    }
    
    // MARK: - Public Functions
    
    // Return editable image (backed with CIImage)
    var editableImage: UIImage? {
        guard isEditable else { return nil }
        guard let localURL = localURL else { return nil }
        guard let ciImage = CIImage(contentsOf: localURL, options: [.applyOrientationProperty: true]) else { return nil }
        
        return UIImage(ciImage: ciImage)
    }
    
    // Update image
    func update(image: UIImage) {
        guard isEditable else { return }
        guard let localURL = localURL, let cgBackedImage = image.cgImageBackedCopy() else { return }
        
        if export(image: cgBackedImage, to: localURL) {
            let ratio = max(thumbnailSize.width, thumbnailSize.height) / max(image.size.width, image.size.height)
            let newSize = cgBackedImage.size.applying(CGAffineTransform(scaleX: ratio, y: ratio))
            self.thumbnail = cgBackedImage.resized(for: newSize)
        }
    }
    
    // MARK: - Private Functions
    
    private func setup() {
        // Get localURL & additionalInfo
        asset.requestContentEditingInput(with: nil) { editingInput, _ in
            if let editingInput = editingInput {
                if let fullSizeImageURL = editingInput.fullSizeImageURL {
                    self.localURL = fullSizeImageURL.copyIntoTemporaryLocation()
                } else if let audiovisualAsset = editingInput.audiovisualAsset,
                          let session = audiovisualAsset.videoExportSession(using: self.videoExportPreset) {
                    self.additionalInfo = audiovisualAsset.additionalInfo
                    
                    //                    session.exportAsynchronously {
                    //                        self.localURL = session.outputURL
                    //                    }
                    let outputURL = session.outputURL
                    
                    session.exportAsynchronously { [weak self] in
                        guard let self = self else { return }
                        // Use the captured output URL
                        self.localURL = outputURL
                    }
                }
            }
        }
        
        // Get original thumbnail
        requestIDs.append(asset.fetchImage(forSize: thumbnailSize) { image, requestID in
            self.requestIDs.removeAll { $0 == requestID }
            self.thumbnail = image
        })
    }
}

// MARK: - Export Functions

extension SelectableElement {
    private func export(image: UIImage, to destinationURL: URL) -> Bool {
        switch imageExportPreset {
        case .compatible:
            return image.exportJPGImage(to: destinationURL, quality: imageExportQuality)
        case .current:
            // Use HEIC, and fallback to JPEG if it fails, since HEIC is not available in all devices
            // (see https://support.apple.com/en-us/HT207022)
            if image.exportHEICImage(to: destinationURL, quality: imageExportQuality) {
                return true
            } else {
                return image.exportJPGImage(to: destinationURL, quality: imageExportQuality)
            }
        }
    }
}
