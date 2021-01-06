//
//  BrandHeaderViewTests.swift
//  binkappTests
//
//  Created by Sean Williams on 18/11/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import XCTest
@testable import binkapp

class BrandHeaderViewTests: XCTestCase, CoreDataTestable, LoyaltyButtonDelegate {
    func brandHeaderViewWasTapped(_ brandHeaderView: BrandHeaderView) {}
    
    var sut: BrandHeaderView!
    var baseMembershipPlan: MembershipPlanModel!
    var membershipPlan: CD_MembershipPlan!
    
    override func setUp() {
        super.setUp()

        sut = BrandHeaderView()
        let accountModel = MembershipPlanAccountModel(apiId: nil, planName: "Tesco Clubcard", planNameCard: nil, planURL: nil, companyName: nil, category: nil, planSummary: nil, planDescription: nil, barcodeRedeemInstructions: nil, planRegisterInfo: nil, companyURL: nil, enrolIncentive: nil, forgottenPasswordUrl: nil, tiers: nil, planDocuments: nil, addFields: nil, authoriseFields: nil, registrationFields: nil, enrolFields: nil)
        baseMembershipPlan = MembershipPlanModel(apiId: nil, status: nil, featureSet: nil, images: nil, account: accountModel, balances: nil, dynamicContent: nil, hasVouchers: nil, card: nil)
        
        mapResponseToManagedObject(baseMembershipPlan, managedObjectType: CD_MembershipPlan.self) { plan in
            self.membershipPlan = plan
        }
    }
    
    func test_loyaltyPlanButtonTitle_is_correct() {
        self.sut.configure(plan: membershipPlan, delegate: self)
        XCTAssertEqual(sut.loyaltyPlanButton.titleLabel?.text, "Tesco Clubcard info")
    }
    
    func test_loyaltyPlanButton_hiddenState() {
        self.sut.configure(plan: membershipPlan, delegate: self)
        XCTAssertFalse(sut.loyaltyPlanButton.isHidden)
        
        baseMembershipPlan.account?.planName = nil
        
        mapResponseToManagedObject(baseMembershipPlan, managedObjectType: CD_MembershipPlan.self) { plan in
            self.membershipPlan = plan
        }
        
        self.sut.configure(plan: membershipPlan, delegate: self)
        XCTAssertTrue(sut.loyaltyPlanButton.isHidden)
    }
}
