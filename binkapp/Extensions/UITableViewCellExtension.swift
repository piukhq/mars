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
}
