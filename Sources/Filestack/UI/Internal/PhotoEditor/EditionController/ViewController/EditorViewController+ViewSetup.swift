//
//  EditorViewController+ViewSetup.swift
//  EditImage
//
//  Created by Mihály Papp on 23/07/2018.
//  Copyright © 2018 Mihály Papp. All rights reserved.
//

import UIKit

extension EditorViewController {
    func setupGestureRecognizer() {
        panGestureRecognizer.delegate = self
        panGestureRecognizer.addTarget(self, action: #selector(handlePanGesture(recognizer:)))
        pinchGestureRecognizer.delegate = self
        pinchGestureRecognizer.addTarget(self, action: #selector(handlePinchGesture(recognizer:)))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(panGestureRecognizer)
        imageView.addGestureRecognizer(pinchGestureRecognizer)
    }

    func setupView() {
        view.backgroundColor = backgroundColor
        bottomToolbar.editorDelegate = self
        topToolbar.editorDelegate = self
        setupImageView()
        setupPreview()
        connectViews()
    }
}

private extension EditorViewController {
    var backgroundColor: UIColor {
        return UIColor(white: 31 / 255, alpha: 1)
    }

    func setupImageView() {
        imageView.image = editor?.editedImage
        imageView.isOpaque = false
        imageView.contentMode = .redraw
        preview.addSubview(imageClearBackground)
        imageClearBackground.backgroundColor = UIColor(patternImage: .fromFilestackBundle("clear-pattern"))
        imageClearBackground.frame = imageFrame.applying(CGAffineTransform(translationX: 4, y: 4))
    }

    func setupPreview() {
        preview.backgroundColor = backgroundColor
    }

    func connectViews() {
        connectBottomToolbar()
        connectTopToolbar()
        connectPreview()
    }

    func connectBottomToolbar() {
        view.fill(with: bottomToolbar, connectingEdges: [.bottom], withSafeAreaRespecting: true)
        view.fill(with: bottomToolbar, connectingEdges: [.left, .right], withSafeAreaRespecting: false)
        bottomToolbar.heightAnchor.constraint(equalToConstant: 44).isActive = true
    }

    func connectTopToolbar() {
        view.fill(with: topToolbar, connectingEdges: [.left, .right], withSafeAreaRespecting: false)
        topToolbar.bottomAnchor.constraint(equalTo: bottomToolbar.topAnchor).isActive = true
        topToolbar.heightAnchor.constraint(equalToConstant: 44).isActive = true
    }

    func connectPreview() {
        preview.fill(with: imageView, inset: 4)
        view.fill(with: preview, connectingEdges: [.top, .left, .right], withSafeAreaRespecting: true)
        preview.bottomAnchor.constraint(equalTo: topToolbar.topAnchor).isActive = true
    }
}
