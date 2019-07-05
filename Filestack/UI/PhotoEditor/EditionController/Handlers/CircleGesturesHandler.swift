//
//  CropGesturesHandler.swift
//  EditImage
//
//  Created by Mihály Papp on 12/07/2018.
//  Copyright © 2018 Mihály Papp. All rights reserved.
//

import UIKit

protocol EditCircleDelegate: EditDataSource {
    func updateCircle(_ center: CGPoint, radius: CGFloat)
}

class CircleGesturesHandler {
    typealias RelativeCircle = (centerX: CGFloat, centerY: CGFloat, radius: CGFloat)

    weak var delegate: EditCircleDelegate?

    private var beginCircle: RelativeCircle?
    private var relativeCircle = CircleGesturesHandler.initialCircle

    init(delegate: EditCircleDelegate) {
        self.delegate = delegate
    }

    var circleCenter: CGPoint {
        get {
            return point(fromRelativeX: relativeCircle.centerX, relativeY: relativeCircle.centerY)
        }
        set {
            relativeCircle.centerX = relativeX(from: newValue) ?? 0
            relativeCircle.centerY = relativeY(from: newValue) ?? 0
            sendUpdate()
        }
    }

    var circleRadius: CGFloat {
        get {
            return length(fromRelativeLenght: relativeCircle.radius)
        }
        set {
            relativeCircle.radius = relativeLenght(fromLenght: newValue)
            sendUpdate()
        }
    }

    var actualCenter: CGPoint {
        guard let delegate = delegate else { return .zero }

        let x = delegate.imageActualSize.width * relativeCircle.centerX
        let y = delegate.imageActualSize.height * relativeCircle.centerY

        return CGPoint(x: x, y: y)
    }

    var actualRadius: CGFloat {
        guard let delegate = delegate else { return .zero }

        return min(delegate.imageActualSize.width, delegate.imageActualSize.height) * relativeCircle.radius
    }

    func reset() {
        relativeCircle = CircleGesturesHandler.initialCircle
    }

    private static var initialCircle = RelativeCircle(centerX: 0.5, centerY: 0.5, radius: 0.4)
}

private extension CircleGesturesHandler {
    func point(fromRelativeX relativeX: CGFloat, relativeY: CGFloat) -> CGPoint {
        guard let delegate = delegate else { return .zero }

        let x = delegate.imageOrigin.x + delegate.imageSize.width * relativeX
        let y = delegate.imageOrigin.y + delegate.imageSize.height * relativeY

        return CGPoint(x: x, y: y)
    }

    func relativeX(from point: CGPoint) -> CGFloat? {
        guard let delegate = delegate else { return nil }

        return (point.x - delegate.imageOrigin.x) / delegate.imageSize.width
    }

    func relativeY(from point: CGPoint) -> CGFloat? {
        guard let delegate = delegate else { return nil }

        return (point.y - delegate.imageOrigin.y) / delegate.imageSize.height
    }

    func length(fromRelativeLenght relativeLenght: CGFloat) -> CGFloat {
        return shorterEdge * relativeLenght
    }

    func relativeLenght(fromLenght lenght: CGFloat) -> CGFloat {
        return lenght / shorterEdge
    }

    var maxRadius: CGFloat { return 0.5 }
    var minRadius: CGFloat { return 0.1 }
}

private extension CircleGesturesHandler {
    var shorterEdge: CGFloat {
        guard let delegate = delegate else { return 0 }

        return min(delegate.imageSize.width, delegate.imageSize.height)
    }

    func sendUpdate() {
        delegate?.updateCircle(actualCenter, radius: actualRadius)
    }
}

extension CircleGesturesHandler {
    func handlePanGesture(recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: recognizer.view)
        let origin = recognizer.location(in: recognizer.view).movedBy(x: -translation.x, y: -translation.y)
        handle(translation: translation, from: origin, forState: recognizer.state)
    }

    func handlePinchGesture(recognizer: UIPinchGestureRecognizer) {
        let origin = recognizer.location(in: recognizer.view)
        handle(scaling: recognizer.scale, center: origin, forState: recognizer.state)
    }

    func rotateCounterClockwise() {
        let rotatedCircle = RelativeCircle(centerX: relativeCircle.centerY,
                                           centerY: 1 - relativeCircle.centerX,
                                           radius: relativeCircle.radius)
        relativeCircle = rotatedCircle
    }
}

// MARK: Translation

private extension CircleGesturesHandler {
    func handle(translation: CGPoint, from _: CGPoint, forState state: UIGestureRecognizer.State) {
        switch state {
        case .began:
            beginCircle = relativeCircle
            move(by: translation)
        case .changed:
            move(by: translation)
        case .ended:
            move(by: translation)
            beginCircle = nil
        case .cancelled,
             .failed:
            reset(to: beginCircle)
        case .possible:
            return
        }
    }

    func reset(to circle: RelativeCircle?) {
        guard let circle = circle else { return }
        circleCenter = point(fromRelativeX: circle.centerX, relativeY: circle.centerY)
        circleRadius = length(fromRelativeLenght: circle.radius)
    }

    func move(by translation: CGPoint) {
        guard let beginCircle = beginCircle else { return }
        guard let delegate = delegate else { return }

        let startCenter = point(fromRelativeX: beginCircle.centerX, relativeY: beginCircle.centerY)
        let topSpace = delegate.imageFrame.minY - startCenter.y + circleRadius
        let bottomSpace = delegate.imageFrame.maxY - startCenter.y - circleRadius
        let leftSpace = delegate.imageFrame.minX - startCenter.x + circleRadius
        let rightSpace = delegate.imageFrame.maxX - startCenter.x - circleRadius
        let moveY = clamp(translation.y, min: topSpace, max: bottomSpace)
        let moveX = clamp(translation.x, min: leftSpace, max: rightSpace)
        circleCenter = startCenter.movedBy(x: moveX, y: moveY)
    }
}

// MARK: Resize

private extension CircleGesturesHandler {
    func handle(scaling: CGFloat, center _: CGPoint, forState state: UIGestureRecognizer.State) {
        switch state {
        case .began:
            beginCircle = relativeCircle
            scale(by: scaling)
        case .changed:
            scale(by: scaling)
        case .ended:
            scale(by: scaling)
            beginCircle = nil
        case .cancelled,
             .failed:
            reset(to: beginCircle)
        case .possible:
            return
        }
    }

    func scale(by scale: CGFloat) {
        let adjustedScale = scale / 2 + 0.5
        let radius = clamp(relativeCircle.radius * adjustedScale, min: minRadius, max: maxRadius)
        circleRadius = length(fromRelativeLenght: radius)
        move(by: .zero)
    }
}
