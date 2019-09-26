//
//  PaymentTermsAndConditionsViewModel.swift
//  binkapp
//
//  Created by Dorin Pop on 17/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

class PaymentTermsAndConditionsViewModel {
    private let router: MainScreenRouter
    
    
    init(router: MainScreenRouter) {
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
