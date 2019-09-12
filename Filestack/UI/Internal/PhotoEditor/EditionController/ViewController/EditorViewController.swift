//
//  EditorViewController.swift
//  EditImage
//
//  Created by Mihály Papp on 03/07/2018.
//  Copyright © 2018 Mihály Papp. All rights reserved.
//

import UIKit

final class EditorViewController: UIViewController, UIGestureRecognizerDelegate {
    enum EditMode {
        case crop, circle, none
    }

    var editMode = EditMode.none {
        didSet {
            turnOff(mode: oldValue)
            turnOn(mode: editMode)
            updatePaths()
        }
    }

    var editor: ImageEditor?

    let bottomToolbar = BottomEditorToolbar()
    let topToolbar = TopEditorToolbar()
    let preview = UIView()
    let imageView = ImageEditorView()
    let imageClearBackground = UIView()

    private let cropLayer = CropLayer()
    private let circleLayer = CircleLayer()
    var panGestureRecognizer = UIPanGestureRecognizer()
    var pinchGestureRecognizer = UIPinchGestureRecognizer()

    lazy var cropHandler = CropGesturesHandler(delegate: self)
    lazy var circleHandler = CircleGesturesHandler(delegate: self)

    var completion: ((UIImage?) -> Void)?

    init(image: UIImage, completion: @escaping (UIImage?) -> Void) {
        self.editor = ImageEditor(image: image)
        self.completion = completion

        super.init(nibName: nil, bundle: nil)

        setupGestureRecognizer()
        setupView()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension EditorViewController {
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        updatePaths()
        imageClearBackground.frame = imageFrame.applying(CGAffineTransform(translationX: 4, y: 4))
    }
}

private extension EditorViewController {
    func turnOff(mode: EditMode) {
        hideLayer(for: mode)
    }

    func turnOn(mode: EditMode) {
        addLayer(for: mode)
        bottomToolbar.isEditing = (mode != .none)
    }
}

private extension EditorViewController {
    func layer(for mode: EditMode) -> CALayer? {
        switch mode {
        case .crop: return cropLayer
        case .circle: return circleLayer
        case .none: return nil
        }
    }

    func isVisible(layer: CALayer) -> Bool {
        return imageView.layer.sublayers?.contains(layer) ?? false
    }

    func addLayer(for mode: EditMode) {
        guard let editLayer = layer(for: mode), !isVisible(layer: editLayer) else { return }
        imageView.layer.addSublayer(editLayer)
    }

    func hideLayer(for mode: EditMode) {
        layer(for: mode)?.removeFromSuperlayer()
    }

    func updatePaths() {
        switch editMode {
        case .crop: updateCropPaths()
        case .circle: updateCirclePaths()
        case .none: return
        }
    }

    func updateCropPaths() {
        cropLayer.imageFrame = imageFrame
        cropLayer.cropRect = cropHandler.croppedRect
    }

    func updateCirclePaths() {
        circleLayer.imageFrame = imageFrame
        circleLayer.circleCenter = circleHandler.circleCenter
        circleLayer.circleRadius = circleHandler.circleRadius
    }
}

extension EditorViewController {
    @objc func handlePanGesture(recognizer: UIPanGestureRecognizer) {
        switch editMode {
        case .crop: cropHandler.handlePanGesture(recognizer: recognizer)
        case .circle: circleHandler.handlePanGesture(recognizer: recognizer)
        case .none: return
        }
    }

    @objc func handlePinchGesture(recognizer: UIPinchGestureRecognizer) {
        switch editMode {
        case .crop: return
        case .circle: circleHandler.handlePinchGesture(recognizer: recognizer)
        case .none: return
        }
    }
}

// MARK: EditCropDelegate

extension EditorViewController: EditCropDelegate {
    func updateCropInset(_: UIEdgeInsets) {
        updateCropPaths()
    }
}

// MARK: EditCircleDelegate

extension EditorViewController: EditCircleDelegate {
    func updateCircle(_: CGPoint, radius _: CGFloat) {
        updateCirclePaths()
    }
}
