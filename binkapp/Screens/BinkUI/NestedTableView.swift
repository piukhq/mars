//
//  NestedTableView.swift
//  binkapp
//
//  Created by Nick Farrant on 07/11/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class NestedTableView: UITableView {
    override func layoutSubviews() {
        super.layoutSubviews()
        separatorColor = Current.themeManager.color(for: .divider)
    }
    
    override var contentSize: CGSize {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }

    override var intrinsicContentSize: CGSize {
        return contentSize
    }
}
