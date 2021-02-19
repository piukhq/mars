//
//  UITableViewCellExtension.swift
//  binkapp
//
//  Created by Nick Farrant on 07/11/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

extension UITableViewCell {
    func hideSeparator() {
        separatorInset = UIEdgeInsets(top: 0, left: bounds.width, bottom: 0, right: 0)
    }

    func setSeparatorFullWidth() {
        separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }

    func setSeparatorDefaultWidth() {
        separatorInset = UIEdgeInsets(top: 0, left: 25, bottom: 0, right: 25)
    }
    
    func binkTableViewCellSelectedBackgroundView() -> UIView {
        let selectedView = UIView(frame: bounds)
        var selectionColor: UIColor = .black

        switch Current.themeManager.currentTheme.type {
        case .light:
            selectionColor = .binkDynamicGrayLight
        case .dark:
            selectionColor = .binkBlueTableCellSelection
        case .system:
            selectionColor = traitCollection.userInterfaceStyle == .light ? .binkDynamicGrayLight : .binkBlueTableCellSelection
        }

        selectedView.backgroundColor = selectionColor
        return selectedView
    }
}
