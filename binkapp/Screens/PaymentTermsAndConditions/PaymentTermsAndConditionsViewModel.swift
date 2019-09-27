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
    
    func accept(completion: @escaping () -> Void) {
        router.dismissViewController(completion: completion)
    }

    func decline() {
        close()
    }

    func close() {
        router.dismissViewController()
    }
}
