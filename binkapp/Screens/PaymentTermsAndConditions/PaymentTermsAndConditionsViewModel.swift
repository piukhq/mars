//
//  PaymentTermsAndConditionsViewModel.swift
//  binkapp
//
//  Created by Dorin Pop on 17/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

struct TermsAndConditionsConfiguration {
    var title: String
    var text: String
    var font: UIFont
    var mainButtonTitle: String?
    var mainButtonCompletion: () -> Void?
    var secondaryButtonTitle: String?
    var secondaryButtonCompletion: () -> Void?
    
    init(title: String = "", text: String, font: UIFont, mainButtonTitle: String? = nil, mainButtonCompletion: (() -> Void)? = nil, secondaryButtonTitle: String? = nil, secondaryButtonCompletion: (() -> Void)? = nil) {
        self.title = title
        self.text = text
        self.font = font
        self.mainButtonTitle = mainButtonTitle
        self.mainButtonCompletion = mainButtonCompletion ?? {  }
        self.secondaryButtonTitle = secondaryButtonTitle
        self.secondaryButtonCompletion = secondaryButtonCompletion ?? {  }
    }
}

class PaymentTermsAndConditionsViewModel {
    private let configurationModel: TermsAndConditionsConfiguration
    private let router: MainScreenRouter
    
    var title: String {
        return configurationModel.title
    }
    
    var text: String {
        return configurationModel.text
    }
    
    var font: UIFont {
        return configurationModel.font
    }
    
    var mainButtonTitle: String? {
        return configurationModel.mainButtonTitle
    }
    
    var mainButtonCompletion: () -> Void? {
        return configurationModel.mainButtonCompletion
    }
    
    var secondaryButtonTitle: String? {
        return configurationModel.secondaryButtonTitle
    }
    
    var secondaryButtonCompletion: () -> Void? {
        return configurationModel.secondaryButtonCompletion
    }
    
    init(configurationModel: TermsAndConditionsConfiguration, router: MainScreenRouter) {
        self.configurationModel = configurationModel
        self.router = router
    }
    
    // MARK: - Public methods
    
    func toRootViewController()  {
        router.popToRootViewController()
    }
    
    func popViewController()  {
        router.popViewController()
    }
    
    func createCard() {
        router.displaySimplePopup(title: "error".localized, message: "to_be_implemented_message".localized)
    }
}
