//
//  CropLayer.swift
//  EditImage
//
//  Created by Mihály Papp on 12/07/2018.
//  Copyright © 2018 Mihály Papp. All rights reserved.
//

import UIKit

class CropLayer: CALayer {
    var imageFrame = CGRect.zero {
        didSet {
            updateSublayers()
        }
    }

    var cropRect = CGRect.zero {
        didSet {
            updateSublayers()
        }
    }

    override init() {
        super.init()
        addSublayer(outsideLayer)
        addSublayer(gridLayer)
        addSublayer(cornersLayer)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var outsideLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.path = outsidePath
        layer.fillRule = .evenOdd
        layer.backgroundColor = UIColor.black.cgColor
        layer.opacity = 0.5
        return layer
    }()

    private lazy var gridLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.path = gridPath
        layer.lineWidth = 0.5
        layer.strokeColor = UIColor.white.cgColor
        layer.backgroundColor = UIColor.clear.cgColor
        layer.fillColor = UIColor.clear.cgColor
        return layer
    }()

    private lazy var cornersLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.path = cornersPath
        layer.lineWidth = 2
        layer.strokeColor = UIColor.white.cgColor
        layer.backgroundColor = UIColor.clear.cgColor
        layer.fillColor = UIColor.clear.cgColor
        return layer
    }()
}

/// :nodoc:
private extension CropLayer {
    func updateSublayers() {
        outsideLayer.path = outsidePath
        gridLayer.path = gridPath
        cornersLayer.path = cornersPath
    }

    var outsidePath: CGPath {
        let path = UIBezierPath(rect: cropRect)
        path.append(UIBezierPath(rect: imageFrame))
        return path.cgPath
    }

    var gridPath: CGPath {
        let gridWidth = cropRect.size.width / 3
        let gridHeight = cropRect.size.height / 3
        let path = UIBezierPath(rect: cropRect)
        path.move(to: cropRect.origin.movedBy(x: gridWidth))
        path.addLine(to: path.currentPoint.movedBy(y: gridHeight * 3))
        path.move(to: cropRect.origin.movedBy(x: gridWidth * 2))
        path.addLine(to: path.currentPoint.movedBy(y: gridHeight * 3))
        path.move(to: cropRect.origin.movedBy(y: gridHeight))
        path.addLine(to: path.currentPoint.movedBy(x: gridWidth * 3))
        path.move(to: cropRect.origin.movedBy(y: gridHeight * 2))
        path.addLine(to: path.currentPoint.movedBy(x: gridWidth * 3))
        return path.cgPath
    }

    var cornersPath: CGPath {
        let thickness: CGFloat = 2
        let lenght: CGFloat = 20
        let horizontalWidth = min(lenght, cropRect.size.width) + thickness
        let verticalWidth = min(lenght, cropRect.size.height)
        let margin = UIEdgeInsets(top: -thickness / 2, left: -thickness / 2, bottom: -thickness / 2, right: -thickness / 2)
        let outerRect = cropRect.inset(by: margin)
        let path = UIBezierPath()
        path.move(to: outerRect.origin.movedBy(y: verticalWidth))
        path.addLine(to: path.currentPoint.movedBy(y: -verticalWidth))
        path.addLine(to: path.currentPoint.movedBy(x: horizontalWidth))
        path.move(to: outerRect.origin.movedBy(x: outerRect.size.width - horizontalWidth))
        path.addLine(to: path.currentPoint.movedBy(x: horizontalWidth))
        path.addLine(to: path.currentPoint.movedBy(y: verticalWidth))
        path.move(to: outerRect.origin.movedBy(x: outerRect.size.width, y: outerRect.size.height - verticalWidth))
        path.addLine(to: path.currentPoint.movedBy(y: verticalWidth))
        path.addLine(to: path.currentPoint.movedBy(x: -horizontalWidth))
        path.move(to: outerRect.origin.movedBy(y: outerRect.size.height - verticalWidth))
        path.addLine(to: path.currentPoint.movedBy(y: verticalWidth))
        path.addLine(to: path.currentPoint.movedBy(x: horizontalWidth))
        return path.cgPath
    }
}
