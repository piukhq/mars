//
//  BinkModuleViewModelTests.swift
//  binkappTests
//
//  Created by Nick Farrant on 21/04/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import XCTest
@testable import binkapp

class BinkModuleViewModelTests: XCTestCase, CoreDataTestable {
    func test_pointsModule_plrWithTransactions_stateReturnsCorrectly() {
        let featureSet = FeatureSetModel(apiId: nil, authorisationRequired: nil, transactionsAvailable: true, digitalOnly: nil, hasPoints: nil, cardType: nil, linkingSupport: nil, hasVouchers: true)
        
        let planModel = MembershipPlanModel(apiId: 1, status: nil, featureSet: featureSet, images: nil, account: nil, balances: nil, dynamicContent: nil, hasVouchers: true, card: nil)
        
        mapResponseToManagedObject(planModel, managedObjectType: CD_MembershipPlan.self) { [weak self] mappedPlan in
            guard let self = self else { return }
            
            let cardModel = MembershipCardModel(apiId: nil, membershipPlan: nil, membershipTransactions: nil, status: MembershipCardStatusModel(apiId: nil, state: .authorised, reasonCodes: nil), card: nil, images: nil, account: nil, paymentCards: nil, balances: nil, vouchers: nil)
            
            self.mapResponseToManagedObject(cardModel, managedObjectType: CD_MembershipCard.self) { mappedCard in
                mappedCard.membershipPlan = mappedPlan
                
                let viewModel = BinkModuleViewModel(type: .points(membershipCard: mappedCard))
                
                XCTAssertEqual(viewModel.imageName, "lcdModuleIconsPointsActive")
                XCTAssertEqual(viewModel.titleText, "plr_lcd_points_module_auth_title".localized)
                XCTAssertEqual(viewModel.subtitleText, "points_module_view_history_messages".localized)
            }
        }
    }
}
