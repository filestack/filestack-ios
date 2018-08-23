//
//  Stylizer.swift
//  Filestack
//
//  Created by Mihály Papp on 09/08/2018.
//  Copyright © 2018 Filestack. All rights reserved.
//

import Foundation

protocol StylizerDelegate: class {
  func updateStyle()
}

@objc(FSStylizer) public class Stylizer: NSObject {
  
  struct SourceTableViewModel {
    var tintColor = UIColor.black
    
    var cellTextColor = UIColor.black
    var cellTextFont = UIFont.systemFont(ofSize: 17)
    var cellBackgroundColor = UIColor.white
    
    var headerTextColor = UIColor.black
    var headerTextFont = UIFont.boldSystemFont(ofSize: 17)
    var headerBackgroundColor = UIColor(white: 0.97, alpha: 1)
    
    var separatorColor = UIColor.appleTableSeparator
    var tableBackground = UIColor.white
    
    var title = "Filestack"
  }
  
  struct NavigationBarViewModel {
    var tintColor = UIColor.appleBlue
    var titleColor = UIColor.black
    var style = UIBarStyle.default
  }
  
  private(set) var sourceTable = SourceTableViewModel()
  private(set) var navBar = NavigationBarViewModel()
  private weak var delegate: StylizerDelegate?
  
  init(delegate: StylizerDelegate) {
    self.delegate = delegate
  }

  @discardableResult
  public func setSourceTable(tintColor: UIColor) -> Stylizer {
    sourceTable.tintColor = tintColor
    return self
  }
  
  @discardableResult
  public func setSourceTable(cellTextColor: UIColor) -> Stylizer {
    sourceTable.cellTextColor = cellTextColor
    return self
  }

  @discardableResult
  public func setSourceTable(cellTextFont: UIFont) -> Stylizer {
    sourceTable.cellTextFont = cellTextFont
    return self
  }

  @discardableResult
  public func setSourceTable(cellBackgroundColor: UIColor) -> Stylizer {
    sourceTable.cellBackgroundColor = cellBackgroundColor
    return self
  }

  @discardableResult
  public func setSourceTable(headerTextColor: UIColor) -> Stylizer {
    sourceTable.headerTextColor = headerTextColor
    return self
  }

  @discardableResult
  public func setSourceTable(headerTextFont: UIFont) -> Stylizer {
    sourceTable.headerTextFont = headerTextFont
    return self
  }

  @discardableResult
  public func setSourceTable(headerBackgroundColor: UIColor) -> Stylizer {
    sourceTable.headerBackgroundColor = headerBackgroundColor
    return self
  }

  @discardableResult
  public func setSourceTable(separatorColor: UIColor) -> Stylizer {
    sourceTable.separatorColor = separatorColor
    return self
  }

  @discardableResult
  public func setSourceTable(tableBackground: UIColor) -> Stylizer {
    sourceTable.tableBackground = tableBackground
    return self
  }
  
  @discardableResult
  public func setSourceTable(title: String) -> Stylizer {
    sourceTable.title = title
    return self
  }

  @discardableResult
  public func setNavBar(tintColor: UIColor) -> Stylizer {
    navBar.tintColor = tintColor
    delegate?.updateStyle()
    return self
  }

  @discardableResult
  public func setNavBar(titleColor: UIColor) -> Stylizer {
    navBar.titleColor = titleColor
    delegate?.updateStyle()
    return self
  }

  @discardableResult
  public func setNavBar(style: UIBarStyle) -> Stylizer {
    navBar.style = style
    delegate?.updateStyle()
    return self
  }
}
