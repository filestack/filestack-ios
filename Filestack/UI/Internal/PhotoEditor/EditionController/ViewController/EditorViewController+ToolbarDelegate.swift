//
//  EditorViewController+ToolbarDelegate.swift
//  EditImage
//
//  Created by Mihály Papp on 23/07/2018.
//  Copyright © 2018 Mihály Papp. All rights reserved.
//

import Foundation

extension EditorViewController: EditorToolbarDelegate {
    func cancelSelected() {
        dismiss(animated: true) {
            self.completion?(nil)
        }
    }

    func rotateSelected() {
        perform(command: .rotate(clockwise: false))
        cropHandler.rotateCounterClockwise()
        circleHandler.rotateCounterClockwise()
    }

    func cropSelected() {
        switch editMode {
        case .crop: editMode = .none
        case .circle, .none: editMode = .crop
        }
    }

    func circleSelected() {
        switch editMode {
        case .circle: editMode = .none
        case .crop, .none: editMode = .circle
        }
    }

    func saveSelected() {
        switch editMode {
        case .crop: perform(command: .crop(insets: cropHandler.actualEdgeInsets))
        case .circle: perform(command: .circled(center: circleHandler.actualCenter, radius: circleHandler.actualRadius))
        case .none: return
        }

        editMode = .none
    }

    func doneSelected() {
        dismiss(animated: true) {
            let editedImage = self.editor?.editedImage.cgImageBackedCopy()
            self.editor = nil
            self.completion?(editedImage)
        }
    }

    func undoSelected() {
        perform(command: .undo)
    }

    func redoSelected() {
        perform(command: .redo)
    }

    // MARK: - Private Functions

    private func perform(command: ImageEditorCommand) {
        guard let editor = editor else { return }

        switch command {
        case let .rotate(clockwise):
            editor.rotate(clockwise: clockwise)
        case let .crop(insets):
            editor.crop(insets: insets)
        case let .circled(center, radius):
            editor.cropCircled(center: center, radius: radius)
        case .undo:
            editor.undo()
        case .redo:
            editor.redo()
        case .reset:
            editor.reset()
        }

        imageView.image = editor.editedImage
        editMode = .none
        cropHandler.reset()
        circleHandler.reset()
        topToolbar.setActions(showUndo: editor.canUndo(), showRedo: editor.canRedo())
    }
}
