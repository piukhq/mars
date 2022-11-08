//
//  AddOrJoinViewModelTests.swift
//  binkappTests
//
//  Created by Sean Williams on 15/07/2022.
//  Copyright © 2022 Bink. All rights reserved.
//

import XCTest
@testable import binkapp

// swiftlint:disable all

class AddOrJoinViewModelTests: XCTestCase, CoreDataTestable {
    static var membershipCardResponse: MembershipCardModel!
    static var membershipPlanResponse: MembershipPlanModel!
    static var cardResponse: CardModel!
    static var featureSetResponse: FeatureSetModel!
    static var planAccountResponse: MembershipPlanAccountModel!
    
    static var membershipCard: CD_MembershipCard!
    static var membershipPlan: CD_MembershipPlan!
    static var sut = AddOrJoinViewModel(membershipPlan: membershipPlan, membershipCard: membershipCard)
    
    var currentViewController: UIViewController {
        return Current.navigate.currentViewController!
    }

    override class func setUp() {
        super.setUp()
        featureSetResponse = FeatureSetModel(apiId: nil, authorisationRequired: nil, transactionsAvailable: nil, digitalOnly: nil, hasPoints: nil, cardType: .link, linkingSupport: nil, hasVouchers: nil)
        let enrolField = EnrolFieldModel(apiId: nil, column: nil, validation: nil, fieldDescription: nil, type: nil, choices: [], commonName: nil)
        planAccountResponse = MembershipPlanAccountModel(apiId: nil, planName: nil, planNameCard: nil, planURL: nil, companyName: "Harvey Nichols", category: nil, planSummary: nil, planDescription: nil, barcodeRedeemInstructions: nil, planRegisterInfo: nil, companyURL: nil, enrolIncentive: nil, forgottenPasswordUrl: nil, tiers: nil, planDocuments: nil, addFields: nil, authoriseFields: nil, registrationFields: nil, enrolFields: [enrolField])
        membershipPlanResponse = MembershipPlanModel(apiId: 5, status: nil, featureSet: featureSetResponse, images: nil, account: planAccountResponse, balances: nil, dynamicContent: nil, hasVouchers: false, card: nil)
        
        cardResponse = CardModel(apiId: nil, barcode: "123456789", membershipId: "999 666", barcodeType: 0, colour: nil, secondaryColour: nil)
        membershipCardResponse = MembershipCardModel(apiId: nil, membershipPlan: 5, membershipTransactions: nil, status: nil, card: cardResponse, images: nil, account: nil, paymentCards: nil, balances: nil, vouchers: nil, openedTime: nil)
        
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
        Self.membershipPlanResponse.featureSet?.linkingSupport = []
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
    
    func test_toAuthAndAddScreen_navigatesToCorrectViewController() {
        Self.membershipPlanResponse.hasVouchers = false
        self.mapResponseToManagedObject(Self.membershipPlanResponse, managedObjectType: CD_MembershipPlan.self) { _ in
            Self.sut.toAuthAndAddScreen()
            XCTAssertTrue(self.currentViewController.isKind(of: AuthAndAddViewController.self) == true)
            
            if let authAndAdd = self.currentViewController as? AuthAndAddViewController {
                XCTAssertEqual(authAndAdd.viewModel.formPurpose, .addFailed)
            }
            
            let sutNoMembershipCard = AddOrJoinViewModel(membershipPlan: Self.membershipPlan)
            sutNoMembershipCard.toAuthAndAddScreen()
            
            if let authAndAddViewController = self.currentViewController as? AuthAndAddViewController {
                XCTAssertEqual(authAndAddViewController.viewModel.formPurpose, .add)
            }
            
            Self.membershipPlanResponse.hasVouchers = true
            self.mapResponseToManagedObject(Self.membershipPlanResponse, managedObjectType: CD_MembershipPlan.self) { plan in
                Self.membershipPlan = plan
                Self.sut.toAuthAndAddScreen()
                XCTAssertTrue(self.currentViewController.isKind(of: ReusableTemplateViewController.self))
            }
        }
    }
    
    func test_didSelectAddNewCard_navigatesToCorrectViewController_0() {
        Self.membershipPlanResponse.hasVouchers = true
        self.mapResponseToManagedObject(Self.membershipPlanResponse, managedObjectType: CD_MembershipPlan.self) { plan in
            Self.membershipPlan = plan
            Self.sut.didSelectAddNewCard()
            XCTAssertTrue(self.currentViewController.isKind(of: ReusableTemplateViewController.self))
        }
    }
    
    func test_didSelectAddNewCard_navigatesToCorrectViewController_1() {
        let featureSet = FeatureSetModel(apiId: nil, authorisationRequired: nil, transactionsAvailable: nil, digitalOnly: nil, hasPoints: nil, cardType: .link, linkingSupport: [.add], hasVouchers: nil)
        Self.membershipPlanResponse.featureSet = featureSet
        Self.membershipPlanResponse.hasVouchers = false
        self.mapResponseToManagedObject(Self.membershipPlanResponse, managedObjectType: CD_MembershipPlan.self) { plan in
            Self.membershipPlan = plan
            Self.sut.didSelectAddNewCard()
            XCTAssertTrue(self.currentViewController.isKind(of: ReusableTemplateViewController.self))
        }
    }
    
    func test_didSelectAddNewCard_navigatesToCorrectViewController_2() {
        Self.membershipPlanResponse.featureSet?.linkingSupport = [.enrol]
        self.mapResponseToManagedObject(Self.membershipPlanResponse, managedObjectType: CD_MembershipPlan.self) { plan in
            Self.membershipPlan = plan
            let sutNoMembershipCard = AddOrJoinViewModel(membershipPlan: Self.membershipPlan)
            sutNoMembershipCard.didSelectAddNewCard()

            if let authAndAddViewController = self.currentViewController as? AuthAndAddViewController {
                XCTAssertEqual(authAndAddViewController.viewModel.formPurpose, .signUp)
            } else {
                XCTFail("Could not find AuthAndAddViewController")
            }
        }
    }
    
    func test_didSelectAddNewCard_navigatesToCorrectViewController_3() {
        let featureSet = FeatureSetModel(apiId: nil, authorisationRequired: nil, transactionsAvailable: nil, digitalOnly: nil, hasPoints: nil, cardType: .link, linkingSupport: [.enrol], hasVouchers: nil)
        Self.membershipPlanResponse.featureSet = featureSet
        Self.membershipPlanResponse.hasVouchers = false
        self.mapResponseToManagedObject(Self.membershipPlanResponse, managedObjectType: CD_MembershipPlan.self) { plan in
            Self.membershipPlan = plan
            Self.sut.didSelectAddNewCard()
            
            if let authAndAddViewController = self.currentViewController as? AuthAndAddViewController {
                XCTAssertEqual(authAndAddViewController.viewModel.formPurpose, .signUpFailed)
            } else {
                XCTFail("Could not find AuthAndAddViewController")
            }
        }
    }
    
    func test_didSelectAddNewCard_navigatesToCorrectViewController_4() {
        Self.membershipPlanResponse.featureSet = nil
        self.mapResponseToManagedObject(Self.membershipPlanResponse, managedObjectType: CD_MembershipPlan.self) { plan in
            Self.membershipPlan = plan
            Self.sut.didSelectAddNewCard()
            XCTAssertTrue(self.currentViewController.isKind(of: ReusableTemplateViewController.self))
            
            Self.membershipPlanResponse.featureSet = Self.featureSetResponse
            self.mapResponseToManagedObject(Self.membershipPlanResponse, managedObjectType: CD_MembershipPlan.self) { plan in
                Self.membershipPlan = plan
            }
        }
    }
    
    func test_toNativeJoinUnavailable_navigatesToCorrectViewController_0() {
        Self.sut.toNativeJoinUnavailable()
        XCTAssertTrue(self.currentViewController.isKind(of: ReusableTemplateViewController.self))
    }
    
    func test_toNativeJoinUnavailable_navigatesToCorrectViewController_1() {
        Self.membershipPlanResponse.account = Self.planAccountResponse
        Self.membershipPlanResponse.account?.planURL = "Hello I am a lovely URL"
        self.mapResponseToManagedObject(Self.membershipPlanResponse, managedObjectType: CD_MembershipPlan.self) { plan in
            Self.membershipPlan = plan
            Self.sut.toNativeJoinUnavailable()
            XCTAssertTrue(self.currentViewController.isKind(of: ReusableTemplateViewController.self))
        }
    }
    
    func test_brandHeaderWasTapped_navigatesToCorrectViewController() {
        Self.sut.brandHeaderWasTapped()
        XCTAssertTrue(self.currentViewController.isKind(of: ReusableTemplateViewController.self))
    }
}
