//
//  BarcodeViewModelTests.swift
//  binkappTests
//
//  Created by Sean Williams on 16/11/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import XCTest
@testable import binkapp

class BarcodeViewModelTests: XCTestCase, CoreDataTestable {
    static var membershipCardResponse: MembershipCardModel!
    static var membershipPlanResponse: MembershipPlanModel!
    static var cardResponse: CardModel!
    
    static var membershipCard: CD_MembershipCard!
    static var sut = BarcodeViewModel(membershipCard: membershipCard)

    override class func setUp() {
        super.setUp()
        let planAccountModel = MembershipPlanAccountModel(apiId: nil, planName: nil, planNameCard: nil, planURL: nil, companyName: "Harvey Nichols", category: nil, planSummary: nil, planDescription: nil, barcodeRedeemInstructions: nil, planRegisterInfo: nil, companyURL: nil, enrolIncentive: nil, forgottenPasswordUrl: nil, tiers: nil, planDocuments: nil, addFields: nil, authoriseFields: nil, registrationFields: nil, enrolFields: nil)
        membershipPlanResponse = MembershipPlanModel(apiId: 5, status: nil, featureSet: nil, images: nil, account: planAccountModel, balances: nil, dynamicContent: nil, hasVouchers: nil, card: nil)
        
        cardResponse = CardModel(apiId: nil, barcode: "123456789", membershipId: "999 666", barcodeType: 0, colour: nil, secondaryColour: nil)
        membershipCardResponse = MembershipCardModel(apiId: nil, membershipPlan: 5, membershipTransactions: nil, status: nil, card: cardResponse, images: nil, account: nil, paymentCards: nil, balances: nil, vouchers: nil)
        
        mapResponseToManagedObject(membershipPlanResponse, managedObjectType: CD_MembershipPlan.self) { _ in }
        
        mapResponseToManagedObject(membershipCardResponse, managedObjectType: CD_MembershipCard.self) { card in
            self.membershipCard = card
        }
    }
    
    
    // MARK: - Helper Methods

    private func mapMembershipCard() {
        mapResponseToManagedObject(Self.membershipCardResponse, managedObjectType: CD_MembershipCard.self) { card in
            Self.membershipCard = card
        }
    }
    
    
    // MARK: - Tests

    func test_title_is_correct() {
        XCTAssertEqual(Self.sut.title, "Harvey Nichols")
    }
    
    func test_isBarcodeAvailable() {
        Self.membershipCardResponse.card = Self.cardResponse
        mapMembershipCard()
        XCTAssertTrue(Self.sut.isBarcodeAvailable)

        Self.membershipCardResponse.card?.barcode = nil
        mapMembershipCard()
        XCTAssertFalse(Self.sut.isBarcodeAvailable)
    }

    func test_cardNumber_string() {
        XCTAssertEqual(Self.sut.cardNumber, "999 666")
    }

    func test_isCardNumberAvailable() {
        XCTAssertTrue(Self.sut.isCardNumberAvailable)

        Self.membershipCardResponse.card?.membershipId = nil
        mapMembershipCard()
        XCTAssertFalse(Self.sut.isCardNumberAvailable)
    }

    func test_barcodeNumber_string() {
        Self.membershipCardResponse.card = Self.cardResponse
        mapMembershipCard()
        XCTAssertEqual(Self.sut.barcodeNumber, "123456789")

        Self.membershipCardResponse.card?.barcode = nil
        mapMembershipCard()
        XCTAssertEqual(Self.sut.barcodeNumber, "")
    }

    func test_barcodeUse_is_loyalty() {
        XCTAssertNotEqual(Self.sut.barcodeUse, .coupon)
        XCTAssertEqual(Self.sut.barcodeUse, .loyaltyCard)
    }

    func test_barcodeType_is_correct() {
        XCTAssertEqual(Self.sut.barcodeType, .code128)

        Self.membershipCardResponse.card?.barcodeType = 1
        mapMembershipCard()
        XCTAssertEqual(Self.sut.barcodeType, .qr)

        Self.membershipCardResponse.card?.barcodeType = 2
        mapMembershipCard()
        XCTAssertEqual(Self.sut.barcodeType, .aztec)

        Self.membershipCardResponse.card?.barcodeType = 3
        mapMembershipCard()
        XCTAssertEqual(Self.sut.barcodeType, .pdf417)

        Self.membershipCardResponse.card?.barcodeType = 4
        mapMembershipCard()
        XCTAssertEqual(Self.sut.barcodeType, .ean13)

        Self.membershipCardResponse.card?.barcodeType = 5
        mapMembershipCard()
        XCTAssertEqual(Self.sut.barcodeType, .dataMatrix)

        Self.membershipCardResponse.card?.barcodeType = nil
        mapMembershipCard()
        XCTAssertEqual(Self.sut.barcodeType, .code128)
    }

    func test_barcode_image_is_returned() {
        let size = CGSize(width: 200, height: 200)
        XCTAssertNotNil(Self.sut.barcodeImage(withSize: size))
        Self.membershipCardResponse.card?.barcode = nil
        mapMembershipCard()
        XCTAssertNil(Self.sut.barcodeImage(withSize: size))
    }
}
