//
//  SelectionCell.swift
//  EditImage
//
//  Created by Mihály Papp on 20/07/2018.
//  Copyright © 2018 Mihály Papp. All rights reserved.
//

import UIKit

class SelectionCell: UICollectionViewCell {
  enum Mode {
    case standard
    case deletion(markedToDelete: Bool)
  }
  
  var mode = Mode.standard {
    didSet {
      switch (oldValue, mode) {
      case (.standard, .standard),
           (.deletion(true), .deletion(true)),
           (.deletion(false), .deletion(false)):
        break
      case (.standard, .deletion(false)):
        wobble()
      case (.standard, .deletion(true)):
        wobble()
        set(isMarkedToDelete: true)
      case (.deletion(false), .deletion(true)):
        set(isMarkedToDelete: true)
      case (.deletion(true), .deletion(false)):
        set(isMarkedToDelete: false)
      case (.deletion, .standard):
        set(isMarkedToDelete: false)
        stopWobble()
      }
    }
  }
  
  var imageView = UIImageView()
  var selectionDim = UIView()
  var selectionIcon = UIImageView()
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupView()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func update() {
    
  }
}

private extension SelectionCell {
  func wobble() {
    let scale: CGFloat = 0.92
    let degrees = CGFloat.pi * 0.5 / 180
    let leftWobble = CGAffineTransform(rotationAngle: degrees)
    let rightWobble = CGAffineTransform(rotationAngle: -degrees).scaledBy(x: scale, y: scale)
    let move = leftWobble.translatedBy(x: 1, y: 1)
    let conCat = leftWobble.concatenating(move).concatenating(CGAffineTransform(scaleX: scale, y: scale))
    
    UIView.animate(withDuration: 0.8) {
      self.transform = rightWobble
    }
    UIView.animate(withDuration: 0.12, delay: 0.08,
                   options: [.allowUserInteraction, .repeat, .autoreverse],
                   animations: { self.transform = conCat })
  }

  func stopWobble() {
    layer.removeAllAnimations()
    transform = CGAffineTransform.identity
  }
  
  func set(isMarkedToDelete: Bool) {
    let scaleFactor: CGFloat = 0.9
    selectionDim.isHidden = !isMarkedToDelete
    selectionIcon.isHidden = !isMarkedToDelete
    let scale: CGFloat = isMarkedToDelete ? scaleFactor : 1/scaleFactor
    transform = transform.concatenating(CGAffineTransform(scaleX: scale, y: scale))
  }
}

private extension SelectionCell {
  func setupView() {
    setupImage()
    setupSelectionDim()
    setupSelectionIcon()
  }
  
  func setupImage() {
    imageView.layer.cornerRadius = 6
    imageView.layer.borderColor = UIColor.init(white: 0.1, alpha: 1).cgColor
    imageView.layer.borderWidth = 1
    imageView.contentMode = .scaleAspectFit
    imageView.backgroundColor = .white
    imageView.clipsToBounds = true
    fill(with: imageView)
  }
  
  func setupSelectionIcon() {
    selectionIcon.image = .fromFilestackBundle("icon-selected")
    selectionIcon.isHidden = true
    selectionDim.fill(with: selectionIcon, connectingEdges: [.bottom, .right], inset: 6, withSafeAreaRespecting: false)
    selectionIcon.widthAnchor.constraint(equalToConstant: 24).isActive = true
    selectionIcon.heightAnchor.constraint(equalToConstant: 24).isActive = true
  }
  
  func setupSelectionDim() {
    selectionDim.isHidden = true
    selectionDim.backgroundColor = UIColor(white: 1, alpha: 0.3)
    imageView.fill(with: selectionDim)
  }
}
