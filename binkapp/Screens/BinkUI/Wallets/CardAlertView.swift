//
//  CardAlertView.swift
//  binkapp
//
//  Created by Nick Farrant on 24/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

typealias CardAlertViewAction = () -> Void

enum CardAlertViewType: String {
    case loyaltyLogIn = "Log in"
    case paymentExpired = "Expired"
}

class CardAlertView: CustomView {
    @IBOutlet private weak var alertLabel: UILabel!

    var action: CardAlertViewAction?

    func configureForType(_ type: CardAlertViewType, action: @escaping CardAlertViewAction) {
        self.action = action

        alertLabel.text = type.rawValue
        alertLabel.font = .alertText
        alertLabel.textColor = .black
        layer.cornerRadius = frame.height / 2
        clipsToBounds = true

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(wasTapped))
        addGestureRecognizer(tapGesture)
    }

    @objc private func wasTapped() {
        action?()
    }
}
