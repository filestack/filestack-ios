//
//  ImageEditor.swift
//  Filestack
//
//  Created by Ruben Nine on 7/4/19.
//  Copyright © 2019 Filestack. All rights reserved.
//

import UIKit.UIImage

class ImageEditor {
    private var editedImages: [UIImage] = []
    private var undoneImages: [UIImage] = []

    public let originalImage: UIImage

    public var editedImage: UIImage {
        return editedImages.last ?? originalImage
    }

    init?(image: UIImage) {
        guard let ciImageBackedCopy = image.ciImageBackedCopy() else { return nil }

        originalImage = ciImageBackedCopy
    }
}

// MARK: - Image Transform Commands

extension ImageEditor {
    func rotate(clockwise: Bool) {
        if let rotatedImage = editedImage.rotated(clockwise: clockwise) {
            editedImages.append(rotatedImage)
        }
    }

    func crop(insets: UIEdgeInsets) {
        if let croppedImage = editedImage.cropped(by: insets) {
            editedImages.append(croppedImage)
        }
    }

    func cropCircled(center: CGPoint, radius: CGFloat) {
        if let cropCircledImage = editedImage.circled(center: center, radius: radius) {
            editedImages.append(cropCircledImage)
        }
    }
}

// MARK: - Image Undo, Redo & Reset Commands

extension ImageEditor {
    func undo() {
        if !editedImages.isEmpty {
            undoneImages.append(editedImages.removeLast())
        }
    }

    func redo() {
        if !undoneImages.isEmpty {
            editedImages.append(undoneImages.removeLast())
        }
    }

    func canUndo() -> Bool {
        return !editedImages.isEmpty
    }

    func canRedo() -> Bool {
        return !undoneImages.isEmpty
    }

    func reset() {
        editedImages.removeAll()
        undoneImages.removeAll()
    }
}
