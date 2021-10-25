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
}

class CheckYourInboxViewModel {
    let configurationModel: CheckYourInboxViewModelConfig
    
    init(config: CheckYourInboxViewModelConfig) {
        self.configurationModel = config
    }
    
    var text: NSMutableAttributedString {
        return configurationModel.text
    }
    
    var primaryButtonTitle: String? {
        return configurationModel.primaryButtonTitle
    }
    
    var primaryButtonAction: BinkButtonAction? {
        return configurationModel.primaryButtonAction
    }
}
