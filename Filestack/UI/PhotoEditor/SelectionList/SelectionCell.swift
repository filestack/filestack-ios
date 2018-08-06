//
//  SelectionCell.swift
//  EditImage
//
//  Created by Mihály Papp on 20/07/2018.
//  Copyright © 2018 Mihály Papp. All rights reserved.
//

import UIKit

class SelectionCell: UICollectionViewCell {
  private struct Consts {
    static let imageBorderColor = UIColor(red: 202/255, green: 206/255, blue: 216/255, alpha: 1).cgColor
    static let imageBorderWidth: CGFloat = 0.5
    static let imageBorderCornerRadius: CGFloat = 5
    static let selectionIconEdgeSize: CGFloat = 30
    static let selectionIconInset: CGFloat = 6
    static let selectionDimColor = UIColor(white: 1, alpha: 0.3)
    static let smallIconEdgeSize: CGFloat = 14
    static let smallIconSpacing: CGFloat = 4
    static let editIconInset: CGFloat = 10
    static let typeIconInset: CGFloat = 8
    static let labelInset: CGFloat = 6
    static let editionScale: CGFloat = 0.92
    static let selectionScale: CGFloat = 0.9
  }
  
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
  
  var element: Uploadable? {
    didSet {
      configure(for: element)
    }
  }
  
  private func configure(for element: Uploadable?) {
    guard let element = element else { return }
    imageView.image = element.associatedImage
    if element.isEditable {
      imageView.contentMode = .scaleAspectFit
    } else {
      imageView.contentMode = .scaleAspectFill
    }
    additionalLabel.isHidden = (element.additionalInfo == nil)
    additionalLabel.text = element.additionalInfo
    typeView.image = element.typeIcon
    editableView.isHidden = !element.isEditable
  }
  
  private var imageView = UIImageView()
  private var editableView = UIImageView()
  private var typeView = UIImageView()
  private var gradientLayer = CAGradientLayer()
  private var additionalLabel = UILabel()
  private var selectionDim = UIView()
  private var selectionIcon = UIImageView()
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupView()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    gradientLayer.frame = imageView.frame
  }
}

private extension SelectionCell {
  func wobble() {
    let scale: CGFloat = Consts.editionScale
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
    configure(for: element)
    layer.removeAllAnimations()
    transform = CGAffineTransform.identity
  }
  
  func set(isMarkedToDelete: Bool) {
    let scaleFactor: CGFloat = Consts.selectionScale
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
    setupAdditionalLabel()
    setupTypeView()
    setupEditableView()
    setupGradientLayer()
  }
  
  func setupImage() {
    imageView.layer.cornerRadius = Consts.imageBorderCornerRadius
    imageView.layer.borderColor = Consts.imageBorderColor
    imageView.layer.borderWidth = Consts.imageBorderWidth
    imageView.contentMode = .scaleAspectFit
    imageView.backgroundColor = .white
    imageView.clipsToBounds = true
    fill(with: imageView)
  }
  
  func setupSelectionIcon() {
    selectionIcon.image = .fromFilestackBundle("icon-selected")
    selectionIcon.isHidden = true
    selectionDim.fill(with: selectionIcon,
                      connectingEdges: [.right, .bottom],
                      inset: Consts.selectionIconInset,
                      withSafeAreaRespecting: false)
    selectionIcon.widthAnchor.constraint(equalToConstant: Consts.selectionIconEdgeSize).isActive = true
    selectionIcon.heightAnchor.constraint(equalToConstant: Consts.selectionIconEdgeSize).isActive = true
  }
  
  func setupSelectionDim() {
    selectionDim.isHidden = true
    selectionDim.backgroundColor = Consts.selectionDimColor
    imageView.fill(with: selectionDim)
  }
  
  func setupEditableView() {
    editableView.image = UIImage.fromFilestackBundle("icon-edit").withRenderingMode(.alwaysTemplate)
    editableView.tintColor = .white
    editableView.backgroundColor = .clear
    imageView.fill(with: editableView,
                   connectingEdges: [.left],
                   inset: Consts.editIconInset,
                   withSafeAreaRespecting: false)
    editableView.bottomAnchor.constraint(equalTo: typeView.topAnchor, constant: -Consts.smallIconSpacing).isActive = true
    editableView.widthAnchor.constraint(equalToConstant: Consts.smallIconEdgeSize).isActive = true
    editableView.heightAnchor.constraint(equalToConstant: Consts.smallIconEdgeSize).isActive = true
  }
  
  func setupAdditionalLabel() {
    additionalLabel.textColor = .white
    additionalLabel.font = .systemFont(ofSize: 11)
    additionalLabel.isHidden = true
    additionalLabel.backgroundColor = .clear
    imageView.fill(with: additionalLabel,
                   connectingEdges: [.bottom, .left],
                   inset: Consts.labelInset,
                   withSafeAreaRespecting: false)
  }
  
  func setupTypeView() {
    typeView.tintColor = .white
    typeView.backgroundColor = .clear
    imageView.fill(with: typeView,
                   connectingEdges: [.bottom],
                   inset: Consts.typeIconInset,
                   withSafeAreaRespecting: false)
    typeView.leftAnchor.constraint(equalTo: additionalLabel.rightAnchor, constant: Consts.smallIconSpacing).isActive = true
    typeView.widthAnchor.constraint(equalToConstant: Consts.smallIconEdgeSize).isActive = true
    typeView.heightAnchor.constraint(equalToConstant: Consts.smallIconEdgeSize).isActive = true
  }

  func setupGradientLayer() {
    imageView.layer.insertSublayer(gradientLayer, at: 0)
    gradientLayer.colors = [UIColor.clear.cgColor, UIColor.clear.cgColor, UIColor(white: 0.55, alpha: 0.6).cgColor]
    gradientLayer.locations = [NSNumber(value: 0), NSNumber(value: 0.6), NSNumber(value: 1)]
    gradientLayer.startPoint = CGPoint(x: 1, y: 0)
    gradientLayer.endPoint = CGPoint(x: 0, y: 1)
    gradientLayer.frame = imageView.frame
  }
}
