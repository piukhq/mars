//
//  BarcodeViewNoBarcodeTests.swift
//  binkappTests
//
//  Created by Ricardo Silva on 02/11/2022.
//  Copyright © 2022 Bink. All rights reserved.
//

import XCTest
@testable import binkapp

// swiftlint:disable all

final class BarcodeViewNoBarcodeTests: XCTestCase, CoreDataTestable {

    static var model: LoyaltyCardFullDetailsViewModel!
    static var membershipCard: CD_MembershipCard!
    static var membershipPlan: CD_MembershipPlan!
    //static var baseMembershipCardResponse: MembershipCardModel!
    //static var membershipPlanResponse: MembershipPlanModel!
    
    override class func setUp() {
        super.setUp()
        
        let cardModel = CardModel(apiId: 300, barcode: "11111", membershipId: "1111", barcodeType: 1, colour: nil, secondaryColour: nil)
        
        let baseMembershipCardResponse = MembershipCardModel(apiId: 300, membershipPlan: 500, membershipTransactions: nil, status: nil, card: cardModel, images: nil, account: nil, paymentCards: nil, balances: nil, vouchers: nil)
        
        let featureSetResponse = FeatureSetModel(apiId: nil, authorisationRequired: nil, transactionsAvailable: nil, digitalOnly: nil, hasPoints: nil, cardType: .link, linkingSupport: nil, hasVouchers: true)
        let enrolField = EnrolFieldModel(apiId: nil, column: nil, validation: nil, fieldDescription: nil, type: nil, choices: [], commonName: nil)
        let planAccountResponse = MembershipPlanAccountModel(apiId: nil, planName: nil, planNameCard: nil, planURL: nil, companyName: "Tesco", category: nil, planSummary: nil, planDescription: nil, barcodeRedeemInstructions: nil, planRegisterInfo: nil, companyURL: nil, enrolIncentive: nil, forgottenPasswordUrl: nil, tiers: nil, planDocuments: nil, addFields: nil, authoriseFields: nil, registrationFields: nil, enrolFields: [enrolField])
        
        let membershipPlanResponse = MembershipPlanModel(apiId: 300, status: nil, featureSet: featureSetResponse, images: nil, account: planAccountResponse, balances: nil, dynamicContent: nil, hasVouchers: true, card: nil)
        
        mapResponseToManagedObject(membershipPlanResponse, managedObjectType: CD_MembershipPlan.self) { plan in
            self.membershipPlan = plan
        }
        
        mapResponseToManagedObject(baseMembershipCardResponse, managedObjectType: CD_MembershipCard.self) { membershipCard in
            self.membershipCard = membershipCard
            self.membershipCard.membershipPlan = self.membershipPlan
        }
        
        let factory = WalletCardDetailInformationRowFactory()
        model = LoyaltyCardFullDetailsViewModel(membershipCard: membershipCard, informationRowFactory: factory)
    }

    func test_propertiesHaveCorrectValues() throws {
        let view: BarcodeViewNoBarcode = .fromNib()
        view.layoutSubviews()
        view.configure(viewModel: Self.model)
        
        XCTAssertTrue(view.getCardNumberLabel().text == "1111")
        XCTAssertTrue(view.getIconImageView().layer.cornerRadius == 10)
        XCTAssertTrue(view.getIconImageView().layer.cornerCurve == .continuous)
    }
}
