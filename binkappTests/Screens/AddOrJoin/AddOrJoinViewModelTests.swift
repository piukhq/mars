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
        let enrolField = EnrolFieldModel(apiId: nil, column: nil, validation: nil, fieldDescription: nil, type: nil, choices: [], commonName: nil)
        let planAccountModel = MembershipPlanAccountModel(apiId: nil, planName: nil, planNameCard: nil, planURL: nil, companyName: "Harvey Nichols", category: nil, planSummary: nil, planDescription: nil, barcodeRedeemInstructions: nil, planRegisterInfo: nil, companyURL: nil, enrolIncentive: nil, forgottenPasswordUrl: nil, tiers: nil, planDocuments: nil, addFields: nil, authoriseFields: nil, registrationFields: nil, enrolFields: [enrolField])
        membershipPlanResponse = MembershipPlanModel(apiId: 5, status: nil, featureSet: featureSet, images: nil, account: planAccountModel, balances: nil, dynamicContent: nil, hasVouchers: false, card: nil)
        
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
        
        Self.membershipPlanResponse.hasVouchers = true
        mapResponseToManagedObject(Self.membershipPlanResponse, managedObjectType: CD_MembershipPlan.self) { _ in
            XCTAssertFalse(Self.sut.shouldShowAddCardButton)
            
            Self.membershipPlanResponse.featureSet?.linkingSupport = [.add]
            self.mapResponseToManagedObject(Self.membershipPlanResponse, managedObjectType: CD_MembershipPlan.self) { _ in
                XCTAssertTrue(Self.sut.shouldShowAddCardButton)
            }
        }
    }
    
    func test_shouldShowNewCardButton_returnCorrectBool() {
        XCTAssertFalse(Self.sut.shouldShowNewCardButton)
        
        Self.membershipPlanResponse.featureSet?.linkingSupport = [.enrol]
        self.mapResponseToManagedObject(Self.membershipPlanResponse, managedObjectType: CD_MembershipPlan.self) { _ in
            XCTAssertTrue(Self.sut.shouldShowNewCardButton)
        }
        
        Self.membershipPlanResponse.account = nil
        self.mapResponseToManagedObject(Self.membershipPlanResponse, managedObjectType: CD_MembershipPlan.self) { _ in
            XCTAssertFalse(Self.sut.shouldShowNewCardButton)
        }
        
        Self.membershipPlanResponse.featureSet = nil
        self.mapResponseToManagedObject(Self.membershipPlanResponse, managedObjectType: CD_MembershipPlan.self) { _ in
            XCTAssertFalse(Self.sut.shouldShowNewCardButton)
        }
    }
    
    func test_getMembershipPlan_returnsCorrectPlan() {
        XCTAssertEqual(Self.sut.getMembershipPlan(), Self.membershipPlan)
    }
    
    func test_toAuthAndAddScreen_1() {
        Self.membershipPlanResponse.hasVouchers = false
        self.mapResponseToManagedObject(Self.membershipPlanResponse, managedObjectType: CD_MembershipPlan.self) { _ in
            Self.sut.toAuthAndAddScreen()
            if let navigationController = Current.navigate.navigationHandler.topViewController as? PortraitNavigationController {
                XCTAssertTrue(navigationController.visibleViewController?.isKind(of: AuthAndAddViewController.self) == true)
                
                if let authAndAdd = navigationController.visibleViewController as? AuthAndAddViewController {
                    XCTAssertEqual(authAndAdd.viewModel.formPurpose, .addFailed)
                    
                    Current.navigate.navigationHandler.navigationController?.viewControllers.removeLast()
                }
            }
        }
    }
    
    func test_toAuthAndAddScreen_2() {
//        Current.navigate.navigationHandler.navigationController?.viewControllers.remove(at: 1)
        Self.sut.membershipCard = nil
        self.mapResponseToManagedObject(Self.membershipPlanResponse, managedObjectType: CD_MembershipPlan.self) { _ in
            Self.sut.toAuthAndAddScreen()
            if let navigationController = Current.navigate.navigationHandler.topViewController as? PortraitNavigationController {
                XCTAssertTrue(navigationController.visibleViewController?.isKind(of: AuthAndAddViewController.self) == true)
                
                if let authAndAdd = navigationController.visibleViewController as? AuthAndAddViewController {
                    XCTAssertEqual(authAndAdd.viewModel.formPurpose, .add)
                }
            }
        }
    }
    
    func test_toAuthAndAddScreen_3() {
        Self.membershipPlanResponse.hasVouchers = true
        self.mapResponseToManagedObject(Self.membershipPlanResponse, managedObjectType: CD_MembershipPlan.self) { _ in
            Self.sut.toAuthAndAddScreen()
            if let navigationController = Current.navigate.navigationHandler.topViewController as? PortraitNavigationController {
                XCTAssertTrue(navigationController.visibleViewController?.isKind(of: ReusableTemplateViewController.self) == true)
            }
        }
    }
}
