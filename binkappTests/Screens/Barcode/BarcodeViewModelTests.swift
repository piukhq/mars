//
//  BarcodeViewModelTests.swift
//  binkappTests
//
//  Created by Sean Williams on 16/11/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import XCTest
@testable import binkapp
import ZXingObjC

class BarcodeViewModelTests: XCTestCase, CoreDataTestable {
    static var membershipCardResponse: MembershipCardModel!
    static var membershipPlanResponse: MembershipPlanModel!
    static var cardResponse: CardModel!
    
    static var membershipCard: CD_MembershipCard!
    static var sut = BarcodeViewModel(membershipCard: membershipCard)

    override class func setUp() {
        super.setUp()
        let planAccountModel = MembershipPlanAccountModel(apiId: nil, planName: nil, planNameCard: "666", planURL: nil, companyName: "Harvey Nichols", category: nil, planSummary: nil, planDescription: nil, barcodeRedeemInstructions: nil, planRegisterInfo: nil, companyURL: nil, enrolIncentive: nil, forgottenPasswordUrl: nil, tiers: nil, planDocuments: nil, addFields: nil, authoriseFields: nil, registrationFields: nil, enrolFields: nil)
        membershipPlanResponse = MembershipPlanModel(apiId: 5, status: nil, featureSet: nil, images: nil, account: planAccountModel, balances: nil, dynamicContent: nil, hasVouchers: nil, card: nil, goLive: "")
        
        cardResponse = CardModel(apiId: nil, barcode: "123456789", membershipId: "999 666", barcodeType: 0, colour: nil, secondaryColour: nil, merchantName: nil)
        membershipCardResponse = MembershipCardModel(apiId: nil, membershipPlan: 5, membershipTransactions: nil, status: nil, card: cardResponse, images: nil, account: nil, paymentCards: nil, balances: nil, vouchers: nil, openedTime: nil)
        
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
    
    func test_description_is_correct_loyalty() {
        Self.membershipCardResponse.card?.barcode = nil
        mapMembershipCard()
        Self.sut.barcodeUse = .loyaltyCard
        XCTAssertEqual(Self.sut.descriptionText, "Share this number in-store or online just like you would a physical loyalty card.")
    }
    
    func test_description_is_correct_coupon() {
        Self.sut.barcodeUse = .coupon
        XCTAssertEqual(Self.sut.descriptionText, "Scan this barcode at the store, just like you would a physical coupon. Bear in mind that some store scanners cannot read from screens.")
    }
    
    func test_memberShipNumberTitle_is_correct() {
        XCTAssertEqual(Self.sut.membershipNumberTitle, "666 Number")
    }
    
    func test_barcodeMatchesMembershipNumber() {
        Self.membershipCardResponse.card?.barcode = "999 666"
        mapMembershipCard()
        XCTAssertEqual(Self.sut.barcodeMatchesMembershipNumber, true)
    }
    
    func test_barcodeDoesNotMatcheMembershipNumber() {
        Self.membershipCardResponse.card?.barcode = "123456789"
        mapMembershipCard()
        XCTAssertEqual(Self.sut.barcodeMatchesMembershipNumber, false)
    }
    
    func test_shouldShowbarcodeNumber() {
        Self.membershipCardResponse.card?.barcode = "123456789"
        mapMembershipCard()
        XCTAssertEqual(Self.sut.shouldShowbarcodeNumber, true)
    }
    
    func test_barcodeShouldBeMoreSquare() {
        Self.membershipCardResponse.card?.barcode = "123456789"
        mapMembershipCard()
        XCTAssertEqual(Self.sut.barcodeIsMoreSquareThanRectangle, true)
    }
    
    func test_heightForHighVisView() {
        let height = Self.sut.heightForHighVisView(text: "123456789")
        XCTAssertTrue(height == 153.0)
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
        Self.membershipCardResponse.card?.barcodeType = 0
        mapMembershipCard()
        XCTAssertEqual(Self.sut.barcodeType, .code128)
        XCTAssertEqual(Self.sut.barcodeType.zxingType, kBarcodeFormatCode128)

        Self.membershipCardResponse.card?.barcodeType = 1
        mapMembershipCard()
        XCTAssertEqual(Self.sut.barcodeType, .qr)
        XCTAssertEqual(Self.sut.barcodeType.zxingType, kBarcodeFormatQRCode)

        Self.membershipCardResponse.card?.barcodeType = 2
        mapMembershipCard()
        XCTAssertEqual(Self.sut.barcodeType, .aztec)
        XCTAssertEqual(Self.sut.barcodeType.zxingType, kBarcodeFormatAztec)

        Self.membershipCardResponse.card?.barcodeType = 3
        mapMembershipCard()
        XCTAssertEqual(Self.sut.barcodeType, .pdf417)
        XCTAssertEqual(Self.sut.barcodeType.zxingType, kBarcodeFormatPDF417)

        Self.membershipCardResponse.card?.barcodeType = 4
        mapMembershipCard()
        XCTAssertEqual(Self.sut.barcodeType, .ean13)
        XCTAssertEqual(Self.sut.barcodeType.zxingType, kBarcodeFormatEan13)

        Self.membershipCardResponse.card?.barcodeType = 5
        mapMembershipCard()
        XCTAssertEqual(Self.sut.barcodeType, .dataMatrix)
        XCTAssertEqual(Self.sut.barcodeType.zxingType, kBarcodeFormatDataMatrix)
        
        Self.membershipCardResponse.card?.barcodeType = 6
        mapMembershipCard()
        XCTAssertEqual(Self.sut.barcodeType, .itf)
        XCTAssertEqual(Self.sut.barcodeType.zxingType, kBarcodeFormatITF)
        
        Self.membershipCardResponse.card?.barcodeType = 7
        mapMembershipCard()
        XCTAssertEqual(Self.sut.barcodeType, .code39)
        XCTAssertEqual(Self.sut.barcodeType.zxingType, kBarcodeFormatCode39)

        Self.membershipCardResponse.card?.barcodeType = nil
        mapMembershipCard()
        XCTAssertEqual(Self.sut.barcodeType, .code128)
    }
    
    func test_preferedWidth() throws {
        Self.membershipCardResponse.card?.barcodeType = 7
        mapMembershipCard()
        
        var value = Self.sut.barcodeType.preferredWidth(for: 10, targetWidth: 100)
        print(value)
        XCTAssertTrue(value == CGFloat(155.0))
        
        Self.membershipCardResponse.card?.barcodeType = 0
        mapMembershipCard()
        
        value = Self.sut.barcodeType.preferredWidth(for: 12, targetWidth: 100)
        XCTAssertTrue(value == 1)
    }

    func test_barcode_image_is_returned() {
        let size = CGSize(width: 200, height: 200)
        XCTAssertNotNil(Self.sut.barcodeImage(withSize: size))
        Self.membershipCardResponse.card?.barcode = nil
        mapMembershipCard()
        XCTAssertNil(Self.sut.barcodeImage(withSize: size))
    }
    
    func test_setShouldAlwaysDisplayBarCode() {
        Current.userDefaults.set(false, forDefaultsKey: .showBarcodeAlways)
        Self.sut.setShouldAlwaysDisplayBarCode()
        XCTAssertEqual(Self.sut.alwaysShowBarcode, false)
        
        Current.userDefaults.set(true, forDefaultsKey: .showBarcodeAlways)
        Self.sut.setShouldAlwaysDisplayBarCode()
        XCTAssertEqual(Self.sut.alwaysShowBarcode, true)
    }
    
    func test_setShowBarcodeAlwaysPreference() {
        Current.userDefaults.set(false, forDefaultsKey: .showBarcodeAlways)
        Self.sut.setShowBarcodeAlwaysPreference(preferencesRepository: MockPreferencesRepository())
        XCTAssertEqual(Self.sut.alwaysShowBarcode, true)
    }
}

class MockPreferencesRepository: PreferencesProtocol {
    func getPreferences(onSuccess: @escaping ([PreferencesModel]) -> Void, onError: @escaping (BinkError?) -> Void) {
    }
    
    func putPreferences(preferences: [String: String], onSuccess: @escaping () -> Void, onError: @escaping (BinkError) -> Void) {
        onSuccess()
    }
}
