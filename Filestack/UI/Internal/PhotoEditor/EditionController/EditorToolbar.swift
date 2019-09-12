//
//  EditorToolbar.swift
//  EditImage
//
//  Created by Mihály Papp on 03/07/2018.
//  Copyright © 2018 Mihály Papp. All rights reserved.
//

import UIKit

class EditorToolbar: UIToolbar {
    weak var editorDelegate: EditorToolbarDelegate?

    var space: UIBarButtonItem {
        return UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    }

    var rotate: UIBarButtonItem {
        let rotate = imageBarButton("icon-rotate", action: #selector(rotateSelected))
        rotate.tintColor = .white
        return rotate
    }

    var crop: UIBarButtonItem {
        let crop = imageBarButton("icon-crop", action: #selector(cropSelected))
        crop.tintColor = .white
        return crop
    }

    var circle: UIBarButtonItem {
        let circle = imageBarButton("icon-circle", action: #selector(circleSelected))
        circle.tintColor = .white
        return circle
    }

    var save: UIBarButtonItem {
        let save = imageBarButton("icon-tick", action: #selector(saveSelected))
        redo.tintColor = editColor
        return save
    }

    var cancel: UIBarButtonItem {
        let cancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelSelected))
        cancel.tintColor = UIColor(red: 0, green: 122 / 255, blue: 1, alpha: 1)
        return cancel
    }

    var done: UIBarButtonItem {
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneSelected))
        done.tintColor = editColor
        return done
    }

    lazy var undo: UIBarButtonItem = {
        let undo = imageBarButton("icon-undo", action: #selector(undoSelected))
        undo.tintColor = editColor
        return undo
    }()

    lazy var redo: UIBarButtonItem = {
        let redo = imageBarButton("icon-redo", action: #selector(redoSelected))
        redo.tintColor = editColor
        return redo
    }()

    private func imageBarButton(_ imageName: String, action: Selector) -> UIBarButtonItem {
        let image = UIImage.fromFilestackBundle(imageName)
        return UIBarButtonItem(image: image, style: .plain, target: self, action: action)
    }

    private var editColor: UIColor {
        return UIColor(red: 240 / 255, green: 180 / 255, blue: 0, alpha: 1)
    }
}

extension EditorToolbar {
    @objc func rotateSelected() {
        editorDelegate?.rotateSelected()
    }

    @objc func cropSelected() {
        editorDelegate?.cropSelected()
    }

    @objc func circleSelected() {
        editorDelegate?.circleSelected()
    }

    @objc func saveSelected() {
        editorDelegate?.saveSelected()
    }

    @objc func cancelSelected() {
        editorDelegate?.cancelSelected()
    }

    @objc func doneSelected() {
        editorDelegate?.doneSelected()
    }

    @objc func undoSelected() {
        editorDelegate?.undoSelected()
    }

    @objc func redoSelected() {
        editorDelegate?.redoSelected()
    }
}

protocol EditorToolbarDelegate: AnyObject {
    func cancelSelected()
    func rotateSelected()
    func cropSelected()
    func circleSelected()
    func saveSelected()
    func doneSelected()
    func undoSelected()
    func redoSelected()
}

class BottomEditorToolbar: EditorToolbar {
    var isEditing: Bool = false {
        didSet {
            setupItems()
        }
    }

    init() {
        super.init(frame: .zero)
        setupView()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupItems() {
        setItems([cancel, space, rotate, crop, circle, space, finish], animated: false)
    }

    var finish: UIBarButtonItem {
        return isEditing ? save : done
    }
}

private extension BottomEditorToolbar {
    func setupView() {
        setupItems()
        barTintColor = .black
        backgroundColor = UIColor(white: 31 / 255, alpha: 1)
    }
}

class TopEditorToolbar: EditorToolbar {
    init() {
        super.init(frame: .zero)
        setupView()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setActions(showUndo: Bool, showRedo: Bool) {
        var items = [space]

        if showUndo { items.append(undo) }
        if showRedo { items.append(redo) }

        setItems(items, animated: false)
    }
}

private extension TopEditorToolbar {
    func setupView() {
        setActions(showUndo: false, showRedo: false)
        setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        barTintColor = .clear
        backgroundColor = .clear
    }
}
