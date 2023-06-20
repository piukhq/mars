//
//  NewMerchantViewModelTests.swift
//  binkappTests
//
//  Created by Ricardo Silva on 20/06/2023.
//  Copyright © 2023 Bink. All rights reserved.
//

import XCTest
@testable import binkapp

import SwiftUI

// swiftlint:disable all

final class NewMerchantViewModelTests: XCTestCase, CoreDataTestable {

    var sut: NewMerchantViewModel!
    
    var membershipPlan: CD_MembershipPlan!
    var membershipPlanResponse: MembershipPlanModel!
    var paymentCardCardResponse: PaymentCardCardResponse!
    
    let whatsNew = """
{
    "app_version": "2.3.0",
    "merchants": [
      {
        "id": "230",
        "description": [
          "Sign up to Tesco clubcard",
          "View your points"
        ]
      }
    ],
    "features": [
      {
        "id": "0",
        "title": "This is a new feature!",
        "description": [
          "This new feature is pretty cool and you should totally check it out."
        ],
        "screen": 4
      },
      {
        "id": "1",
        "title": "This is also a new feature!",
        "description": [
          "This new feature is even better, check it out."
        ],
        "screen": 5
      }
    ]
}
"""
    
    override func setUp() {
        super.setUp()
        
        let featureSet = FeatureSetModel(apiId: nil, authorisationRequired: nil, transactionsAvailable: nil, digitalOnly: nil, hasPoints: nil, cardType: .link, linkingSupport: [.add], hasVouchers: nil)
        
        let accountModel = MembershipPlanAccountModel(apiId: nil, planName: "Loyalteas", planNameCard: nil, planURL: nil, companyName: "Loyalteas", category: nil, planSummary: nil, planDescription: nil, barcodeRedeemInstructions: nil, planRegisterInfo: nil, companyURL: nil, enrolIncentive: nil, forgottenPasswordUrl: nil, tiers: nil, planDocuments: nil, addFields: nil, authoriseFields: nil, registrationFields: nil, enrolFields: nil)
        
        self.membershipPlanResponse = MembershipPlanModel(apiId: 500, status: nil, featureSet: featureSet, images: nil, account: accountModel, balances: nil, dynamicContent: nil, hasVouchers: nil, card: CardModel(apiId: nil, barcode: "123456789", membershipId: "999 666", barcodeType: 0, colour: "#0000FF", secondaryColour: "#ffffff", merchantName: nil), goLive: "")
        
        self.mapResponseToManagedObject(self.membershipPlanResponse, managedObjectType: CD_MembershipPlan.self) { plan in
            self.membershipPlan = plan
        }
        
        let data = self.whatsNew.data(using: .utf8)!
        let val = try! JSONDecoder().decode(WhatsNewModel.self, from: data)
        if let merchant = val.merchants!.first {
            self.sut = NewMerchantViewModel(merchant: NewMerchantModel(id: merchant.id, description: merchant.description))
            self.sut.membershipPlan = self.membershipPlan
        }
    }
    
    func test_titleIsCorrect() {
        XCTAssertEqual(sut.title, "Loyalteas")
    }
    
    func test_descriptionIsCorrect() {
        XCTAssertEqual(sut.merchant.description![0], "Sign up to Tesco clubcard")
    }

    func test_secondaryColorIsValid() {
        XCTAssertNotNil(sut.secondaryColor)
    }

    func test_primaryColorIsValid() {
        XCTAssertNotNil(sut.primaryColor)
    }
    
//    func test_navigationsIsHandledCorrectly() {
//        self.sut.handleNavigation()
//        XCTAssertTrue(Current.navigate.currentViewController!.isKind(of: BrowseBrandsViewController.self))
//    }

}
