//
//  Stylizer.swift
//  Filestack
//
//  Created by Mihály Papp on 09/08/2018.
//  Copyright © 2018 Filestack. All rights reserved.
//

import Foundation

@objc(FSStylizer) public class Stylizer: NSObject {
  
  struct SourceTableViewModel {
    var tintColor = UIColor.black
    
    var cellTextColor = UIColor.black
    var cellTextFont = UIFont.systemFont(ofSize: 17)
    var cellBackgroundColor = UIColor.white
    
    var headerTextColor = UIColor.black
    var headerTextFont = UIFont.boldSystemFont(ofSize: 17)
    var headerBackgroundColor = UIColor(white: 0.97, alpha: 1)
    
    var separatorColor = UIColor.green
    var tableBackground = UIColor.blue
  }
  
  private(set) var sourceTable = SourceTableViewModel()
  
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
}
