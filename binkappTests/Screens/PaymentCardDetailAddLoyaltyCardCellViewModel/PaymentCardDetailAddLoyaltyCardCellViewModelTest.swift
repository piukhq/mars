//
//  PaymentCardDetailAddLoyaltyCardCellViewModelTest.swift
//  binkappTests
//
//  Created by Ricardo Silva on 23/08/2022.
//  Copyright © 2022 Bink. All rights reserved.
//

import XCTest
@testable import binkapp

// swiftlint:disable all

class PaymentCardDetailAddLoyaltyCardCellViewModelTest: XCTestCase, CoreDataTestable {
    
    static var model: PaymentCardDetailAddLoyaltyCardCellViewModel!
    static var membershipPlan: CD_MembershipPlan!
    static var membershipPlanResponse: MembershipPlanModel!
    static var planAccountResponse: MembershipPlanAccountModel!
    
    override class func setUp() {
        super.setUp()

        let enrolField = EnrolFieldModel(apiId: nil, column: nil, validation: nil, fieldDescription: nil, type: nil, choices: [], commonName: nil)
        planAccountResponse = MembershipPlanAccountModel(apiId: nil, planName: nil, planNameCard: nil, planURL: nil, companyName: "Tesco", category: nil, planSummary: nil, planDescription: nil, barcodeRedeemInstructions: nil, planRegisterInfo: nil, companyURL: nil, enrolIncentive: nil, forgottenPasswordUrl: nil, tiers: nil, planDocuments: nil, addFields: nil, authoriseFields: nil, registrationFields: nil, enrolFields: [enrolField])
        
        membershipPlanResponse = MembershipPlanModel(apiId: 5, status: nil, featureSet: nil, images: nil, account: planAccountResponse, balances: nil, dynamicContent: nil, hasVouchers: true, card: nil, goLive: "")
        
        mapResponseToManagedObject(membershipPlanResponse, managedObjectType: CD_MembershipPlan.self) { plan in
            self.membershipPlan = plan
        }
        
        model = PaymentCardDetailAddLoyaltyCardCellViewModel(membershipPlan: membershipPlan)
    }
    
    func test_membershipPlanIsValid() throws {
        XCTAssertNotNil(Self.model.membershipPlan)
    }
    
    func test_headerTextIsValid() throws {
        XCTAssertEqual(Self.model.headerText, "Tesco")
    }
    
    func test_detailTextIsValid() throws {
        XCTAssertEqual(Self.model.detailText, L10n.pcdYouCanLink)
    }
    
    func test_correctlyNavigatesToAddOrJoinVC() throws {
        Self.model.toAddOrJoin()
        _ = XCTWaiter.wait(for: [self.expectation(description: "Wait for closure to complete")], timeout: 3.0)
        
        XCTAssertTrue(Current.navigate.currentViewController!.isKind(of: AddOrJoinViewController.self))
    }
}
