//
//  AddOrJoinViewModelTests.swift
//  binkappTests
//
//  Created by Sean Williams on 15/07/2022.
//  Copyright © 2022 Bink. All rights reserved.
//

import XCTest
@testable import binkapp

class AddOrJoinViewModelTests: XCTestCase, CoreDataTestable {
    static var membershipCardResponse: MembershipCardModel!
    static var membershipPlanResponse: MembershipPlanModel!
    static var cardResponse: CardModel!
    
    static var membershipCard: CD_MembershipCard!
    static var membershipPlan: CD_MembershipPlan!
    static var sut = AddOrJoinViewModel(membershipPlan: membershipPlan, membershipCard: membershipCard)

    override class func setUp() {
        super.setUp()
        let featureSet = FeatureSetModel(apiId: nil, authorisationRequired: nil, transactionsAvailable: nil, digitalOnly: nil, hasPoints: nil, cardType: .link, linkingSupport: nil, hasVouchers: nil)
        let planAccountModel = MembershipPlanAccountModel(apiId: nil, planName: nil, planNameCard: nil, planURL: nil, companyName: "Harvey Nichols", category: nil, planSummary: nil, planDescription: nil, barcodeRedeemInstructions: nil, planRegisterInfo: nil, companyURL: nil, enrolIncentive: nil, forgottenPasswordUrl: nil, tiers: nil, planDocuments: nil, addFields: nil, authoriseFields: nil, registrationFields: nil, enrolFields: nil)
        membershipPlanResponse = MembershipPlanModel(apiId: 5, status: nil, featureSet: featureSet, images: nil, account: planAccountModel, balances: nil, dynamicContent: nil, hasVouchers: nil, card: nil)
        
        cardResponse = CardModel(apiId: nil, barcode: "123456789", membershipId: "999 666", barcodeType: 0, colour: nil, secondaryColour: nil)
        membershipCardResponse = MembershipCardModel(apiId: nil, membershipPlan: 5, membershipTransactions: nil, status: nil, card: cardResponse, images: nil, account: nil, paymentCards: nil, balances: nil, vouchers: nil)
        
        mapResponseToManagedObject(membershipPlanResponse, managedObjectType: CD_MembershipPlan.self) { plan in
            self.membershipPlan = plan
        }
        
        mapResponseToManagedObject(membershipCardResponse, managedObjectType: CD_MembershipCard.self) { card in
            self.membershipCard = card
        }
    }
    
    func test_shouldShowAddCardButton_returnCorrectBool() {
        XCTAssertTrue(Self.sut.shouldShowAddCardButton)
    }
}
