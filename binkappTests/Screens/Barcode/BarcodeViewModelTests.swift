//
//  BarcodeViewModelTests.swift
//  binkappTests
//
//  Created by Sean Williams on 16/11/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import XCTest
@testable import binkapp

class BarcodeViewModelTests: XCTestCase {
    private var membershipCard: MembershipCardModel!
    private var membershipPlan: MembershipPlanModel!

    override func setUp() {
        super.setUp()
        let planAccountModel = MembershipPlanAccountModel(apiId: nil, planName: nil, planNameCard: nil, planURL: nil, companyName: "Harvey Nichols", category: nil, planSummary: nil, planDescription: nil, barcodeRedeemInstructions: nil, planRegisterInfo: nil, companyURL: nil, enrolIncentive: nil, forgottenPasswordUrl: nil, tiers: nil, planDocuments: nil, addFields: nil, authoriseFields: nil, registrationFields: nil, enrolFields: nil)
        membershipPlan = MembershipPlanModel(apiId: nil, status: nil, featureSet: nil, images: nil, account: planAccountModel, balances: nil, dynamicContent: nil, hasVouchers: nil, card: nil)
        
        membershipCard = MembershipCardModel(apiId: nil, membershipPlan: nil, membershipTransactions: nil, status: nil, card: nil, images: nil, account: nil, paymentCards: nil, balances: nil, vouchers: nil)
    }
    
    func test_title_is_correct() {
        let sut = BarcodeViewModelMock(membershipCard: membershipCard, membershipPlan: membershipPlan)
        XCTAssertEqual(sut.title, "Harvey Nichols")
    }
}
