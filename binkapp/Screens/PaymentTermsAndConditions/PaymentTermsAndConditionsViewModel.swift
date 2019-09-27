//
//  PaymentTermsAndConditionsViewModel.swift
//  binkapp
//
//  Created by Dorin Pop on 17/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

class PaymentTermsAndConditionsViewModel {
    let apiManager: ApiManager
    private let router: MainScreenRouter
    
    init(apiManager: ApiManager, router: MainScreenRouter) {
        self.apiManager = apiManager
        self.router = router
    }
    
    // MARK: - Public methods
    
    func accept() {
        router.dismissViewController()
    }

    func decline() {
        close()
    }

    func close() {
        router.dismissViewController()
    }
}
