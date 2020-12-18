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
    
    static var membershipCard: CD_MembershipCard!
    static var sut = BarcodeViewModel(membershipCard: membershipCard)

    override class func setUp() {
        super.setUp()
        let planAccountModel = MembershipPlanAccountModel(apiId: nil, planName: nil, planNameCard: nil, planURL: nil, companyName: "Harvey Nichols", category: nil, planSummary: nil, planDescription: nil, barcodeRedeemInstructions: nil, planRegisterInfo: nil, companyURL: nil, enrolIncentive: nil, forgottenPasswordUrl: nil, tiers: nil, planDocuments: nil, addFields: nil, authoriseFields: nil, registrationFields: nil, enrolFields: nil)
        membershipPlanResponse = MembershipPlanModel(apiId: 5, status: nil, featureSet: nil, images: nil, account: planAccountModel, balances: nil, dynamicContent: nil, hasVouchers: nil, card: nil)
        
        let cardModel = CardModel(apiId: nil, barcode: "123456789", membershipId: "999 666", barcodeType: 0, colour: nil, secondaryColour: nil)
        membershipCardResponse = MembershipCardModel(apiId: nil, membershipPlan: 5, membershipTransactions: nil, status: nil, card: cardModel, images: nil, account: nil, paymentCards: nil, balances: nil, vouchers: nil)
        
        mapResponseToManagedObject(membershipPlanResponse, managedObjectType: CD_MembershipPlan.self) { _ in }
        
        mapResponseToManagedObject(membershipCardResponse, managedObjectType: CD_MembershipCard.self) { card in
            self.membershipCard = card
        }
    }
    
    func test_title_is_correct() {
        XCTAssertEqual(Self.sut.title, "Harvey Nichols")
    }
    
//    func test_isBarcodeAvailable() {
//        XCTAssertTrue(sut.isBarcodeAvailable)
//
//        sut.membershipCard.card?.barcode = nil
//        XCTAssertFalse(sut.isBarcodeAvailable)
//    }
//
//    func test_cardNumber_string() {
//        XCTAssertEqual(sut.cardNumber, "999 666")
//    }
//
//    func test_isCardNumberAvailable() {
//        XCTAssertTrue(sut.isCardNumberAvailable)
//
//        sut.membershipCard.card?.membershipId = nil
//        XCTAssertFalse(sut.isCardNumberAvailable)
//    }
//
//    func test_barcodeNumber_string() {
//        XCTAssertEqual(sut.barcodeNumber, "123456789")
//
//        sut.membershipCard.card?.barcode = nil
//        XCTAssertEqual(sut.barcodeNumber, "")
//    }
//
//    func test_barcodeUse_is_loyalty() {
//        XCTAssertNotEqual(sut.barcodeUse, .coupon)
//        XCTAssertEqual(sut.barcodeUse, .loyaltyCard)
//    }
//
//    func test_barcodeType_is_correct() {
//        XCTAssertEqual(sut.barcodeType, .code128)
//
//        sut.membershipCard.card?.barcodeType = 1
//        XCTAssertEqual(sut.barcodeType, .qr)
//
//        sut.membershipCard.card?.barcodeType = 2
//        XCTAssertEqual(sut.barcodeType, .aztec)
//
//        sut.membershipCard.card?.barcodeType = 3
//        XCTAssertEqual(sut.barcodeType, .pdf417)
//
//        sut.membershipCard.card?.barcodeType = 4
//        XCTAssertEqual(sut.barcodeType, .ean13)
//
//        sut.membershipCard.card?.barcodeType = 5
//        XCTAssertEqual(sut.barcodeType, .dataMatrix)
//
//        sut.membershipCard.card?.barcodeType = nil
//        XCTAssertEqual(sut.barcodeType, .code128)
//    }
//
//    func test_barcode_image_is_returned() {
//        let size = CGSize(width: 200, height: 200)
//        XCTAssertNotNil(sut.barcodeImage(withSize: size))
//        sut.membershipCard.card?.barcode = nil
//        XCTAssertNil(sut.barcodeImage(withSize: size))
//    }
}
