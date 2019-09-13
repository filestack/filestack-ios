//
//  Stylizer.swift
//  Filestack
//
//  Created by Mihály Papp on 09/08/2018.
//  Copyright © 2018 Filestack. All rights reserved.
//

import Foundation

/// Object used to pass set colors, fonts and defaults style of Picker.
@objc(FSStylizer) public class Stylizer: NSObject {
    struct SourceTableViewModel {
        fileprivate(set) var tintColor: UIColor = .systemBlue

        fileprivate(set) var cellTextColor: UIColor = {
            if #available(iOS 13.0, *) {
                return .label
            } else {
                return .black
            }
        }()

        fileprivate(set) var cellTextFont = UIFont.systemFont(ofSize: 17)

        fileprivate(set) var cellBackgroundColor: UIColor = {
            if #available(iOS 13.0, *) {
                return .systemBackground
            } else {
                return .white
            }
        }()

        fileprivate(set) var headerTextColor: UIColor = {
            if #available(iOS 13.0, *) {
                return .label
            } else {
                return .black
            }
        }()

        fileprivate(set) var headerTextFont: UIFont = .boldSystemFont(ofSize: UIFont.labelFontSize)

        fileprivate(set) var headerBackgroundColor: UIColor = {
            if #available(iOS 13.0, *) {
                return .secondarySystemBackground
            } else {
                return UIColor(white: 0.97, alpha: 1)
            }
        }()

        fileprivate(set) var separatorColor: UIColor = {
            if #available(iOS 13.0, *) {
                return .separator
            } else {
                return .appleTableSeparator
            }
        }()

        fileprivate(set) var tableBackground: UIColor = {
            if #available(iOS 13.0, *) {
                return .systemBackground
            } else {
                return .white
            }
        }()

        fileprivate(set) var title = "Filestack"
    }

    struct NavigationBarViewModel {
        var tintColor = UIColor.appleBlue
        var titleColor = UIColor.black
        var style = UIBarStyle.default
    }

    private(set) var sourceTable = SourceTableViewModel()
    private(set) var navBar = NavigationBarViewModel()
    private weak var delegate: StylizerDelegate?

    /// Default initializer.
    ///
    /// - Parameter delegate: An `StylizerDelegate`.
    @objc init(delegate: StylizerDelegate) {
        self.delegate = delegate
    }

    /// Used for changing color of default icons on Picker first view.
    ///
    /// - Parameter tintColor: Color we want to use for icons.
    /// - Returns: self
    @objc @discardableResult
    public func setSourceTable(tintColor: UIColor) -> Stylizer {
        sourceTable.tintColor = tintColor
        return self
    }

    /// Used for changing color of text on Picker first view
    ///
    /// - Parameter cellTextColor: Color we want to use for sources text.
    /// - Returns: self
    @objc @discardableResult
    public func setSourceTable(cellTextColor: UIColor) -> Stylizer {
        sourceTable.cellTextColor = cellTextColor
        return self
    }

    /// Used for changing font of text on Picker first view
    ///
    /// - Parameter cellTextFont: Font we want to use for sources text.
    /// - Returns: self
    @objc @discardableResult
    public func setSourceTable(cellTextFont: UIFont) -> Stylizer {
        sourceTable.cellTextFont = cellTextFont
        return self
    }

    /// Used for changing color for cells background.
    ///
    /// - Parameter cellBackgroundColor: Color we want to use for background of cells.
    /// - Returns: self
    @objc @discardableResult
    public func setSourceTable(cellBackgroundColor: UIColor) -> Stylizer {
        sourceTable.cellBackgroundColor = cellBackgroundColor
        return self
    }

    /// Used for changing color for section headers text.
    ///
    /// - Parameter headerTextColor: Color we want to use for section headers text.
    /// - Returns: self
    @objc @discardableResult
    public func setSourceTable(headerTextColor: UIColor) -> Stylizer {
        sourceTable.headerTextColor = headerTextColor
        return self
    }

    /// Used for changing font for section headers text.
    ///
    /// - Parameter headerTextFont: Font we want to use for section headers text.
    /// - Returns: self
    @objc @discardableResult
    public func setSourceTable(headerTextFont: UIFont) -> Stylizer {
        sourceTable.headerTextFont = headerTextFont
        return self
    }

    /// Used for changing color of section headers background.
    ///
    /// - Parameter headerBackgroundColor: Color we want to use for headers.
    /// - Returns: self
    @objc @discardableResult
    public func setSourceTable(headerBackgroundColor: UIColor) -> Stylizer {
        sourceTable.headerBackgroundColor = headerBackgroundColor
        return self
    }

    /// Used for changing color of tableView separators.
    ///
    /// - Parameter separatorColor: Color we want to use for cells separators.
    /// - Returns: self
    @objc @discardableResult
    public func setSourceTable(separatorColor: UIColor) -> Stylizer {
        sourceTable.separatorColor = separatorColor
        return self
    }

    /// Used for changing color of tableView background.
    ///
    /// - Parameter tableBackground: Color we want to use for background of whole table.
    /// - Returns: self
    @objc @discardableResult
    public func setSourceTable(tableBackground: UIColor) -> Stylizer {
        sourceTable.tableBackground = tableBackground
        return self
    }

    /// Used for changing default nacigation bar title of Picker first view.
    ///
    /// - Parameter title: String we want to use as title of SourceTable.
    /// - Returns: self
    @objc @discardableResult
    public func setSourceTable(title: String) -> Stylizer {
        sourceTable.title = title
        return self
    }

    /// Used for changing default nacigation bar tint color.
    ///
    /// - Parameter tintColor: Color we want to use as navigation bar tint color.
    /// - Returns: self
    @objc @discardableResult
    public func setNavBar(tintColor: UIColor) -> Stylizer {
        navBar.tintColor = tintColor
        delegate?.updateStyle()
        return self
    }

    /// Used for changing default nacigation bar title color.
    ///
    /// - Parameter titleColor: Color we want to use title displayed on navigation bar.
    /// - Returns: self
    @objc @discardableResult
    public func setNavBar(titleColor: UIColor) -> Stylizer {
        navBar.titleColor = titleColor
        delegate?.updateStyle()
        return self
    }

    /// Used for changing default nacigation bar style.
    ///
    /// - Parameter style: UIBarStyle we want to use.
    /// - Returns: self
    @objc @discardableResult
    public func setNavBar(style: UIBarStyle) -> Stylizer {
        navBar.style = style
        delegate?.updateStyle()
        return self
    }
}
