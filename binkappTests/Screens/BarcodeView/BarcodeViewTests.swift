//
//  BarcodeViewCompactTests.swift
//  binkappTests
//
//  Created by Ricardo Silva on 22/08/2022.
//  Copyright © 2022 Bink. All rights reserved.
//

import XCTest
import UIKit
@testable import binkapp

// swiftlint:disable all

class BarcodeViewTests: XCTestCase, CoreDataTestable {
    static var membershipPlanResponse: MembershipPlanModel!
    static var membershipPlan: CD_MembershipPlan!
    static var membershipCard: CD_MembershipCard!
    static var cardModel: CardModel!
    static var membershipCardStatusModel: MembershipCardStatusModel!
    static var baseMembershipCardResponse: MembershipCardModel!
    override class func setUp() {
        super.setUp()
        
        membershipPlanResponse = MembershipPlanModel(apiId: 5, status: nil, featureSet: nil, images: nil, account: nil, balances: nil, dynamicContent: nil, hasVouchers: true, card: nil)
        
        mapResponseToManagedObject(membershipPlanResponse, managedObjectType: CD_MembershipPlan.self) { plan in
            self.membershipPlan = plan
        }
        
        cardModel = CardModel(apiId: 300, barcode: "11111", membershipId: "1111", barcodeType: 1, colour: nil, secondaryColour: nil)
        membershipCardStatusModel = MembershipCardStatusModel(apiId: 300, state: .authorised, reasonCodes: nil)
        baseMembershipCardResponse = MembershipCardModel(apiId: 300, membershipPlan: 500, membershipTransactions: nil, status: membershipCardStatusModel, card: cardModel, images: nil, account: nil, paymentCards: nil, balances: nil, vouchers: nil)
        
        mapResponseToManagedObject(baseMembershipCardResponse, managedObjectType: CD_MembershipCard.self) { membershipCard in
            self.membershipCard = membershipCard
        }
    }
    
    func test_barcodeViewIsValid() throws {
        let factory = WalletCardDetailInformationRowFactory()
        let model = LoyaltyCardFullDetailsViewModel(membershipCard: Self.membershipCard, informationRowFactory: factory)
        model.membershipCard.membershipPlan = Self.membershipPlan
        
        let barcodeView: BarcodeViewCompact = .fromNib()
        barcodeView.configure(viewModel: model)
        
        XCTAssertEqual(barcodeView.cardNumberLabel.text, "1111")
        XCTAssertNotNil(barcodeView.barcodeImageView.image)
    }
    
    func test_barcodeViewBarcodeWideIsValid() throws {
        let factory = WalletCardDetailInformationRowFactory()
        Self.membershipCard.membershipPlan = Self.membershipPlan
        let model = LoyaltyCardFullDetailsViewModel(membershipCard: Self.membershipCard, informationRowFactory: factory)
        model.membershipCard.membershipPlan = Self.membershipPlan
        
        let barcodeView: BarcodeViewWide = .fromNib()
        barcodeView.configure(viewModel: model)
        
        XCTAssertEqual(barcodeView.cardNumberLabel.text, "1111")
        XCTAssertNotNil(barcodeView.barcodeImageView.image)
    }
}
