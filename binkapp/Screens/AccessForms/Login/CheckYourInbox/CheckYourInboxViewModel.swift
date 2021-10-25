//
//  CheckYourInboxViewModel.swift
//  binkapp
//
//  Created by Sean Williams on 25/10/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import Foundation

struct CheckYourInboxViewModelConfig {
    var title: String
    var text: NSMutableAttributedString
    var primaryButtonTitle: String?
    var primaryButtonAction: BinkButtonAction?
    var membershipPlan: CD_MembershipPlan?
    
    init(title: String = "", text: NSMutableAttributedString, primaryButtonTitle: String? = nil, primaryButtonAction: BinkButtonAction? = nil, membershipPlan: CD_MembershipPlan? = nil) {
        self.title = title
        self.text = text
        self.primaryButtonTitle = primaryButtonTitle
        self.primaryButtonAction = primaryButtonAction
        self.membershipPlan = membershipPlan
    }

    static func makeAttributedString(title: String, description: String) -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString()
        let attributedTitle = NSAttributedString(string: title + "\n", attributes: [NSAttributedString.Key.font: UIFont.headline])
        let attributedBody = NSAttributedString(string: description, attributes: [NSAttributedString.Key.font: UIFont.bodyTextLarge])
        attributedString.append(attributedTitle)
        attributedString.append(attributedBody)

        return attributedString
    }
}

class CheckYourInboxViewModel {
    
}
