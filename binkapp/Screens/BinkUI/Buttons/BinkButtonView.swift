//
//  BinkButtonView.swift
//  binkapp
//
//  Created by Nick Farrant on 15/12/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import UIKit

typealias BinkButtonAction = () -> Void

struct BinkButton {
    enum ButtonType {
        case pill(BinkPillButton.PillButtonType)
        case gradient
        case plain
    }

    let type: ButtonType
    let title: String
    let action: BinkButtonAction
    let enabled: Bool = true
}

class BinkButtonsView: UIStackView {
    init(buttons: [BinkButton], addingTo view: UIView) {
        super.init(frame: .zero)

        translatesAutoresizingMaskIntoConstraints = false
        axis = .vertical
        distribution = .fill
        alignment = .center
        spacing = 25

        buttons.forEach {
            switch $0.type {
            case .pill(let pillButtonType):
                
            }
        }
    }
}
