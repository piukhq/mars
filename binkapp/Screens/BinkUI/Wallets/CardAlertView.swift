//
//  CardAlertView.swift
//  binkapp
//
//  Created by Nick Farrant on 24/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

enum CardAlertViewType: String {
    case loyaltyLogIn = "Log in"
    case paymentExpired = "Expired"
}

class CardAlertView: CustomView {

    @IBOutlet private weak var alertLabel: UILabel!

    func configureForType(_ type: CardAlertViewType) {
        alertLabel.text = type.rawValue
        alertLabel.font = .alertText
        layer.cornerRadius = frame.height / 2
        clipsToBounds = true
    }

}
