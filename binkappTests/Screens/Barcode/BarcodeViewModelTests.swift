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
    private var sut: BarcodeViewModelMock!

    override func setUp() {
        super.setUp()
        let planAccountModel = MembershipPlanAccountModel(apiId: nil, planName: nil, planNameCard: nil, planURL: nil, companyName: "Harvey Nichols", category: nil, planSummary: nil, planDescription: nil, barcodeRedeemInstructions: nil, planRegisterInfo: nil, companyURL: nil, enrolIncentive: nil, forgottenPasswordUrl: nil, tiers: nil, planDocuments: nil, addFields: nil, authoriseFields: nil, registrationFields: nil, enrolFields: nil)
        membershipPlan = MembershipPlanModel(apiId: nil, status: nil, featureSet: nil, images: nil, account: planAccountModel, balances: nil, dynamicContent: nil, hasVouchers: nil, card: nil)
        
        let cardModel = CardModel(apiId: nil, barcode: "123456789", membershipId: "999 666", barcodeType: nil, colour: nil, secondaryColour: nil)
        membershipCard = MembershipCardModel(apiId: nil, membershipPlan: nil, membershipTransactions: nil, status: nil, card: cardModel, images: nil, account: nil, paymentCards: nil, balances: nil, vouchers: nil)
        sut = BarcodeViewModelMock(membershipCard: membershipCard, membershipPlan: membershipPlan)
    }
    
    func test_title_is_correct() {
        XCTAssertEqual(sut.title, "Harvey Nichols")
    }
    
    func test_isBarcodeAvailable() {
        XCTAssertTrue(sut.isBarcodeAvailable)
        
        sut.membershipCard.card?.barcode = nil
        XCTAssertFalse(sut.isBarcodeAvailable)
    }
    
    func test_cardNumber_string() {
        XCTAssertEqual(sut.cardNumber, "999 666")
    }
    
    func test_isCardNumberAvailable() {
        XCTAssertTrue(sut.isCardNumberAvailable)
        
        sut.membershipCard.card?.membershipId = nil
        XCTAssertFalse(sut.isCardNumberAvailable)
    }
}
