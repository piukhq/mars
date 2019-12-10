//
//  HyperlinkButton.swift
//  binkapp
//
//  Created by Nick Farrant on 18/11/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class HyperlinkButton: UIButton {
    override func setTitle(_ title: String?, for state: UIControl.State) {
        super.setTitle(title, for: state)
        configure(title: title)
    }

    private func configure(title: String?) {
        guard let title = title else { return }
        let attrString = NSAttributedString(
            string: title,
            attributes: [.underlineStyle : NSUnderlineStyle.single.rawValue, .font: UIFont.linkUnderlined, .foregroundColor: UIColor.blueAccent]
        )
        setAttributedTitle(attrString, for: .normal)
    }
}
