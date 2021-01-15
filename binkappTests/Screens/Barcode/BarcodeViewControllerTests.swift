//
//  BarcodeViewControllerTests.swift
//  binkappTests
//
//  Created by Sean Williams on 17/11/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import XCTest
@testable import binkapp

class BarcodeViewControllerTests: XCTestCase, CoreDataTestable {
    static var baseMembershipCardResponse: MembershipCardModel!
    static var membershipCard: CD_MembershipCard!
    static var barcodeViewModel = BarcodeViewModel(membershipCard: membershipCard)
    static var baseSut = BarcodeViewController(viewModel: barcodeViewModel)
    
    override class func setUp() {
        super.setUp()
        let cardModel = CardModel(apiId: nil, barcode: "123456789", membershipId: "999 666", barcodeType: 0, colour: nil, secondaryColour: nil)
        baseMembershipCardResponse = MembershipCardModel(apiId: nil, membershipPlan: nil, membershipTransactions: nil, status: nil, card: cardModel, images: nil, account: nil, paymentCards: nil, balances: nil, vouchers: nil)
        
        mapResponseToManagedObject(baseMembershipCardResponse, managedObjectType: CD_MembershipCard.self) { membershipCard in
            self.membershipCard = membershipCard
        }
    }
    
    
    // MARK: - Helper Methods
    
    private func mapMembershipCard() {
        mapResponseToManagedObject(Self.baseMembershipCardResponse, managedObjectType: CD_MembershipCard.self) { membershipCard in
            Self.membershipCard = membershipCard
        }
    }
    
    private func buildSutWithBarcode() -> BarcodeViewController {
        let cardModel = CardModel(apiId: nil, barcode: "123456789", membershipId: nil, barcodeType: nil, colour: nil, secondaryColour: nil)
        Self.baseMembershipCardResponse.card = cardModel
        mapMembershipCard()
        let sut = BarcodeViewController(viewModel: Self.barcodeViewModel)
        sut.loadViewIfNeeded()
        return sut
    }
    
    
    // MARK: - Tests

    func test_hasDrawnBarcode_isTrue() {
        let sut = BarcodeViewController(viewModel: Self.barcodeViewModel)
        XCTAssertFalse(sut.hasDrawnBarcode)
        
        sut.loadViewIfNeeded()
        XCTAssertTrue(sut.hasDrawnBarcode)
    }
    
    func test_barcodeImageView_isNotHidden() {
        let sut = buildSutWithBarcode()
        XCTAssertFalse(sut.barcodeImageView.isHidden)
    }

    func test_barcodeImageView_isHidden() {
        Self.baseSut.viewModel.membershipCard.card?.barcode = nil
        Self.baseSut.loadViewIfNeeded()
        XCTAssertTrue(Self.baseSut.barcodeImageView.isHidden)
    }

    func test_numberLabel_isNotHidden() {
        Self.baseSut.loadViewIfNeeded()
        XCTAssertFalse(Self.baseSut.numberLabel.isHidden)
    }

    func test_numberLabel_isHidden() {
        Self.baseMembershipCardResponse.card?.membershipId = nil
        mapMembershipCard()
        let sut = BarcodeViewController(viewModel: Self.barcodeViewModel)
        sut.loadViewIfNeeded()
        XCTAssertTrue(sut.numberLabel.isHidden)
    }

    func test_titleLabel_isNotHidden() {
        Self.baseSut.loadViewIfNeeded()
        XCTAssertFalse(Self.baseSut.titleLabel.isHidden)
    }

    func test_titleLabel_isHidden() {
        Self.baseMembershipCardResponse.card?.membershipId = nil
        mapMembershipCard()
        let sut = BarcodeViewController(viewModel: Self.barcodeViewModel)
        sut.loadViewIfNeeded()
        XCTAssertTrue(sut.titleLabel.isHidden)
    }

    func test_correctUI_isShown_forBarcode() {
        let sut = buildSutWithBarcode()
        XCTAssertFalse(sut.barcodeImageView.isHidden)
        XCTAssertTrue(sut.barcodeErrorLabel.isHidden)
        XCTAssertNotNil(sut.barcodeImageView.image)
    }

    func test_correctUI_isShown_forNoBarcode() {
        Self.baseSut.viewModel.membershipCard.card?.barcode = nil
        Self.baseSut.loadViewIfNeeded()
        XCTAssertTrue(Self.baseSut.barcodeImageView.isHidden)
        XCTAssertEqual(Self.baseSut.barcodeErrorLabel.text, "This barcode cannot be displayed")
        XCTAssertTrue(Self.baseSut.barcodeErrorLabel.isHidden)
    }

    func test_barcodeLabel_text() {
        let sut = buildSutWithBarcode()
        XCTAssertEqual(sut.barcodeLabel.text, "Barcode:")
    }

    func test_barcodeNumberLabel_text() {
        let sut = buildSutWithBarcode()
        XCTAssertEqual(sut.barcodeNumberLabel.text, "123456789")
    }

    func test_titleLabel_text() {
        Self.baseSut.loadViewIfNeeded()
        XCTAssertEqual(Self.baseSut.titleLabel.text, "Card number:")
    }

    func test_numberLabel_text() {
        Self.baseSut.loadViewIfNeeded()
        XCTAssertEqual(Self.baseSut.numberLabel.text, "999 666")
    }

    func test_descriptionLabel_text_forLoyaltyCard_withBarcode() {
        Self.barcodeViewModel.barcodeUse = .loyaltyCard
        let sut = buildSutWithBarcode()
        XCTAssertEqual(sut.descriptionLabel.text, "Scan this barcode at the store, just like you would a physical loyalty card. Bear in mind that some store scanners cannot read from screens.")
    }

    func test_descriptionLabel_text_forLoyaltyCard_withNoBarcode() {
        XCTAssertEqual(Self.baseSut.descriptionLabel.text, "Show this card number in-store just like you would a physical loyalty card.")
    }

    func test_descriptionLabel_text_forCoupon() {
        Self.barcodeViewModel.barcodeUse = .coupon
        let sut = buildSutWithBarcode()
        XCTAssertEqual(sut.descriptionLabel.text, "Scan this barcode at the store, just like you would a physical coupon. Bear in mind that some store scanners cannot read from screens.")
    }
}
