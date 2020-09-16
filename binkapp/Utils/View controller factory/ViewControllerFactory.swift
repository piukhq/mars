//
//  ViewControllerFactory.swift
//  binkapp
//
//  Created by Nick Farrant on 16/09/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import Foundation

final class ViewControllerFactory {
    
    // MARK: - Loyalty Card Detail
    
    static func makeLoyaltyCardDetailViewController(membershipCard: CD_MembershipCard) -> LoyaltyCardFullDetailsViewController {
        let factory = WalletCardDetailInformationRowFactory()
        let viewModel = LoyaltyCardFullDetailsViewModel(membershipCard: membershipCard, informationRowFactory: factory)
        let viewController = LoyaltyCardFullDetailsViewController(viewModel: viewModel)
        factory.delegate = viewController
        return viewController
    }
}
