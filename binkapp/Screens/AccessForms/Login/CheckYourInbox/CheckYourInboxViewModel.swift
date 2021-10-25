//
//  CheckYourInboxViewModel.swift
//  binkapp
//
//  Created by Sean Williams on 25/10/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import UIKit

struct CheckYourInboxViewModelConfig {
    var text: NSMutableAttributedString
    var primaryButtonTitle: String?
    var primaryButtonAction: BinkButtonAction?
    
    init(text: NSMutableAttributedString, primaryButtonTitle: String? = nil, primaryButtonAction: BinkButtonAction? = nil) {
        self.text = text
        self.primaryButtonTitle = primaryButtonTitle
        self.primaryButtonAction = primaryButtonAction
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
    let configuration: CheckYourInboxViewModelConfig
    
    init(config: CheckYourInboxViewModelConfig) {
        self.configuration = config
    }
    
    var text: NSMutableAttributedString {
        return configuration.text
    }
}
