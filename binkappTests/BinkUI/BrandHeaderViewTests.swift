//
//  BrandHeaderViewTests.swift
//  binkappTests
//
//  Created by Sean Williams on 18/11/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import XCTest
@testable import binkapp

class BrandHeaderViewTests: XCTestCase {
    var sut: BrandHeaderViewMock!
    
    override func setUp() {
        super.setUp()

        sut = BrandHeaderViewMock()
        let accountModel = MembershipPlanAccountModel(apiId: nil, planName: "Tesco Clubcard", planNameCard: nil, planURL: nil, companyName: nil, category: nil, planSummary: nil, planDescription: nil, barcodeRedeemInstructions: nil, planRegisterInfo: nil, companyURL: nil, enrolIncentive: nil, forgottenPasswordUrl: nil, tiers: nil, planDocuments: nil, addFields: nil, authoriseFields: nil, registrationFields: nil, enrolFields: nil)
        let membershipPlan = MembershipPlanModel(apiId: nil, status: nil, featureSet: nil, images: nil, account: accountModel, balances: nil, dynamicContent: nil, hasVouchers: nil, card: nil)
        sut.configure(plan: membershipPlan)
    }
    
    func test_loyaltyPlanButtonTitle_is_correct() {
        XCTAssertEqual(sut.loyaltyPlanButton.titleLabel?.text, "Tesco Clubcard info")
    }
}
