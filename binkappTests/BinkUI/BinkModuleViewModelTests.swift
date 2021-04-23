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
    private var sut: BinkModuleViewModel!
    
    private var baseFeatureSetModel: FeatureSetModel!
    private var baseMembershipPlanModel: MembershipPlanModel!
    private var baseMembershipCardModel: MembershipCardModel!
    
    override func setUp() {
        super.setUp()
        
        sut = nil
        baseFeatureSetModel = nil
        baseMembershipPlanModel = nil
        baseMembershipCardModel = nil
        
        baseFeatureSetModel = FeatureSetModel(apiId: nil, authorisationRequired: nil, transactionsAvailable: nil, digitalOnly: nil, hasPoints: nil, cardType: nil, linkingSupport: nil, hasVouchers: nil)
        
        baseMembershipPlanModel = MembershipPlanModel(apiId: nil, status: nil, featureSet: baseFeatureSetModel, images: nil, account: nil, balances: nil, dynamicContent: nil, hasVouchers: nil, card: nil)
        
        baseMembershipCardModel = MembershipCardModel(apiId: nil, membershipPlan: 1, membershipTransactions: nil, status: MembershipCardStatusModel(apiId: nil, state: .authorised, reasonCodes: nil), card: nil, images: nil, account: nil, paymentCards: nil, balances: nil, vouchers: nil)
    }
    
    // MARK: Points module - PLR - Authed
    
    func test_pointsModule_plrWithTransactions_stateReturnsCorrectly() {
        baseFeatureSetModel.hasPoints = true
        baseFeatureSetModel.transactionsAvailable = true
        baseMembershipPlanModel.featureSet = baseFeatureSetModel
        baseMembershipPlanModel.hasVouchers = true
        
        getMappedCard(with: baseMembershipPlanModel) { mappedCard in
            self.sut = BinkModuleViewModel(type: .points(membershipCard: mappedCard))
            
            XCTAssertEqual(self.sut.imageName, "lcdModuleIconsPointsActive")
            XCTAssertEqual(self.sut.titleText, "plr_lcd_points_module_auth_title".localized)
            XCTAssertEqual(self.sut.subtitleText, "points_module_view_history_message".localized)
        }
    }
    
    func test_pointsModule_plrNoTransactions_stateReturnsCorrectly() {
        baseFeatureSetModel.hasPoints = true
        baseMembershipPlanModel.featureSet = baseFeatureSetModel
        baseMembershipPlanModel.hasVouchers = true
        
        getMappedCard(with: baseMembershipPlanModel) { mappedCard in
            self.sut = BinkModuleViewModel(type: .points(membershipCard: mappedCard))
            
            XCTAssertEqual(self.sut.imageName, "lcdModuleIconsPointsActive")
            XCTAssertEqual(self.sut.titleText, "plr_lcd_points_module_title".localized)
            XCTAssertEqual(self.sut.subtitleText, "plr_lcd_points_module_description".localized)
        }
    }
    
    private func getMappedCard(with planModel: MembershipPlanModel, completion: @escaping (CD_MembershipCard) -> Void) {
        mapResponseToManagedObject(planModel, managedObjectType: CD_MembershipPlan.self) { [weak self] mappedPlan in
            guard let self = self else { return }
            
            self.mapResponseToManagedObject(self.baseMembershipCardModel, managedObjectType: CD_MembershipCard.self) { mappedCard in
                mappedCard.membershipPlan = mappedPlan
                
                completion(mappedCard)
            }
        }
    }
}
