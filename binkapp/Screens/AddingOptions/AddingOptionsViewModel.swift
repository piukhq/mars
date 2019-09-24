//
//  AddingOptionsViewModel.swift
//  binkapp
//
//  Created by Paul Tiriteu on 06/08/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

class AddingOptionsViewModel {
    let router: MainScreenRouter
    
    init(router: MainScreenRouter) {
        self.router = router
    }
    
    func toBrowseBrandsScreen() {
        router.toBrowseBrandsViewController()
    }

    func popViewController() {
        router.popViewController()
    }
    
    // TODO: To be removed after the corect screen is implemented. Added for testing purposes.
    func toPaymentTermsAndConditionsScreen() {
        router.toPaymentTermsAndConditionsViewController(configurationModel: TermsAndConditionsConfiguration(text: "", font: .bodyTextLarge))
    }
}
