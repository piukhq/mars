//
//  BinkCopyableLabel.swift
//  binkapp
//
//  Created by Sean Williams on 14/10/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import UIKit

class BinkCopyableLabel: UILabel {
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    func sharedInit() {
        isUserInteractionEnabled = true
        addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(showMenu)))
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func copy(_ sender: Any?) {
        let board = UIPasteboard.general
        board.string = text
        let menu = UIMenuController.shared
        menu.setMenuVisible(false, animated: true)
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return action == #selector(UIResponderStandardEditActions.copy)
    }
    
    @objc private func showMenu(_ sender: Any) {
        becomeFirstResponder()
        let menu = UIMenuController.shared
        if !menu.isMenuVisible {
            let xPosition = self.intrinsicContentSize.width / 2
            let rect = CGRect(x: xPosition, y: bounds.midY - 4, width: 0.0, height: 0.0)
            menu.setTargetRect(rect, in: self)
            menu.setMenuVisible(true, animated: true)
        }
    }
}
