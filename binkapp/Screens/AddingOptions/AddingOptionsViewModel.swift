//
//  AddingOptionsViewModel.swift
//  binkapp
//
//  Created by Paul Tiriteu on 06/08/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class AddingOptionsViewModel {
    let router: MainScreenRouter
    
    init(router: MainScreenRouter) {
        self.router = router
    }
    
    func toBrowseBrandsScreen() {
        router.toBrowseBrandsViewController()
    }

    @objc func popViewController() {
        router.popViewController()
    }
    
    // TODO: To be removed after the corect screen is implemented. Added for testing purposes.
    func toPaymentTermsAndConditionsScreen() {
        let screenText = "terms_and_conditions_title".localized + "\n" + "lorem_ipsum".localized
        
        let attributedText = NSMutableAttributedString(string: screenText)
        
        attributedText.addAttribute(
            NSAttributedString.Key.font,
            value: UIFont.headline,
            range: NSRange(location: 0, length: ("terms_and_conditions_title".localized).count)
        )
        
        attributedText.addAttribute(
            NSAttributedString.Key.font,
            value: UIFont.bodyTextLarge,
            range: NSRange(location: ("terms_and_conditions_title".localized).count, length: ("lorem_ipsum".localized).count)
        )
        
        let backButton = UIBarButtonItem(image: UIImage(named: "close")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(popViewController))
        
        let configurationModel = ReusableModalConfiguration(title: "", text: attributedText, mainButtonTitle: "accept".localized, secondaryButtonTitle: "decline".localized, tabBarBackButton: backButton)
        
        router.toPaymentTermsAndConditionsViewController(configurationModel: configurationModel)
    }
}
