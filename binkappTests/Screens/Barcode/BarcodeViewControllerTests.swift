//
//  BarcodeViewControllerTests.swift
//  binkappTests
//
//  Created by Sean Williams on 17/11/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import XCTest
@testable import binkapp

class BarcodeViewControllerTests: XCTestCase {
    var sut: BarcodeViewControllerMock!
    
    override func setUp() {
        super.setUp()
        let membershipPlan = MembershipPlanModel(apiId: nil, status: nil, featureSet: nil, images: nil, account: nil, balances: nil, dynamicContent: nil, hasVouchers: nil, card: nil)
        let cardModel = CardModel(apiId: nil, barcode: "123456789", membershipId: "999 666", barcodeType: 0, colour: nil, secondaryColour: nil)
        let membershipCard = MembershipCardModel(apiId: nil, membershipPlan: nil, membershipTransactions: nil, status: nil, card: cardModel, images: nil, account: nil, paymentCards: nil, balances: nil, vouchers: nil)
        let viewModel = BarcodeViewModelMock(membershipCard: membershipCard, membershipPlan: membershipPlan)
        sut = BarcodeViewControllerMock(viewModel: viewModel)
    }
    
    func test_hasDrawnBarcode_is_true() {
        XCTAssertFalse(sut.hasDrawnBarcode)
        
        sut.loadViewIfNeeded()
        XCTAssertTrue(sut.hasDrawnBarcode)
    }
    
    func test_barcodeImageView_is_not_hidden() {
        sut.loadViewIfNeeded()
        XCTAssertFalse(sut.barcodeImageView.isHidden)
    }
    
    func test_barcodeImageView_is_hidden() {
        sut.viewModel.membershipCard.card?.barcode = nil
        sut.loadViewIfNeeded()
        XCTAssertTrue(sut.barcodeImageView.isHidden)
    }
    
    func test_numberLabel_is_not_hidden() {
        sut.loadViewIfNeeded()
        XCTAssertFalse(sut.numberLabel.isHidden)
    }
    
    func test_numberLabel_is_hidden() {
        sut.viewModel.membershipCard.card?.membershipId = nil
        sut.loadViewIfNeeded()
        XCTAssertTrue(sut.numberLabel.isHidden)
    }
    
    func test_titleLabel_is_not_hidden() {
        sut.loadViewIfNeeded()
        XCTAssertFalse(sut.titleLabel.isHidden)
    }
    
    func test_titleLabel_is_hidden() {
        sut.viewModel.membershipCard.card?.membershipId = nil
        sut.loadViewIfNeeded()
        XCTAssertTrue(sut.titleLabel.isHidden)
    }
}
