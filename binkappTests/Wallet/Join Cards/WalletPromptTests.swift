//
//  WalletPromptTests.swift
//  binkappTests
//
//  Created by Sean Williams on 17/11/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import XCTest
@testable import binkapp

class WalletPromptTests: XCTestCase, CoreDataTestable {
    static var addPaymentCardsWalletPrompt: WalletPrompt!
    static var pllWalletPrompt: WalletPrompt!
    static var seeWalletPrompt: WalletPrompt!
    static var storeWalletPrompt: WalletPrompt!
    static var baseMembershipPlans: [MembershipPlanModel]!
    static var membershipPlans: [CD_MembershipPlan]!
    
    override class func setUp() {
        super.setUp()
        addPaymentCardsWalletPrompt = WalletPrompt(type: .addPaymentCards)

        let planAccountModel = MembershipPlanAccountModel(apiId: nil, planName: "Harvey Nichols Rewards", planNameCard: nil, planURL: nil, companyName: "Harvey Nichols", category: nil, planSummary: nil, planDescription: nil, barcodeRedeemInstructions: nil, planRegisterInfo: nil, companyURL: nil, enrolIncentive: nil, forgottenPasswordUrl: nil, tiers: nil, planDocuments: nil, addFields: nil, authoriseFields: nil, registrationFields: nil, enrolFields: nil)
        baseMembershipPlans = [MembershipPlanModel(apiId: nil, status: nil, featureSet: nil, images: nil, account: planAccountModel, balances: nil, dynamicContent: nil, hasVouchers: nil, card: nil)]
        
        mapResponsesToManagedObjects(baseMembershipPlans, managedObjectType: CD_MembershipPlan.self) { plans in
            self.membershipPlans = plans
            self.pllWalletPrompt = WalletPrompt(type: .link(plans: plans))
            self.seeWalletPrompt = WalletPrompt(type: .see(plans: plans))
            self.storeWalletPrompt = WalletPrompt(type: .store(plans: plans))
        }
    }
    
    func test_titleString_isCorrect() {
        XCTAssertEqual(Self.addPaymentCardsWalletPrompt.title, "Add your payment cards")
        XCTAssertEqual(Self.pllWalletPrompt.title, "Link to your payment cards")
        XCTAssertEqual(Self.seeWalletPrompt.title, "See your points balances")
        XCTAssertEqual(Self.storeWalletPrompt.title, "Store your barcodes")
    }
    
    func test_bodyString_isCorrect() {
        XCTAssertEqual(Self.addPaymentCardsWalletPrompt.body, "Collect rewards automatically for select loyalty cards by linking them to your payment cards.")
        XCTAssertEqual(Self.pllWalletPrompt.body, "Add these loyalty cards and link them to your payment cards to collect rewards automatically when you pay.")
        XCTAssertEqual(Self.seeWalletPrompt.body, "Add these loyalty cards to see your points and rewards balances in real time.")
        XCTAssertEqual(Self.storeWalletPrompt.body, "Add these loyalty cards to store their barcodes so you'll always have them on your phone when you need them.")
    }
    
    func test_userDefaultsDismissKeyString_isCorrect() {
        XCTAssertEqual(Self.addPaymentCardsWalletPrompt.userDefaultsDismissKey, userDefaultsDismissKey(forType: .addPaymentCards))
    }
    
    func test_membershipPlans_areCorrect() {
        XCTAssertEqual(Self.pllWalletPrompt.membershipPlans, Self.membershipPlans)
        XCTAssertEqual(Self.seeWalletPrompt.membershipPlans, Self.membershipPlans)
        XCTAssertEqual(Self.storeWalletPrompt.membershipPlans, Self.membershipPlans)
        XCTAssertNil(Self.addPaymentCardsWalletPrompt.membershipPlans)
    }
    
    func test_iconImageNameString_isCorrect() {
        XCTAssertEqual(Self.addPaymentCardsWalletPrompt.iconImageName, "payment")
        XCTAssertNil(Self.pllWalletPrompt.iconImageName)
        XCTAssertNil(Self.seeWalletPrompt.iconImageName)
        XCTAssertNil(Self.storeWalletPrompt.iconImageName)
    }
    
    func test_userDefaultsDismissKeyFuncString_isCorrect() {
        XCTAssertEqual(WalletPrompt.userDefaultsDismissKey(forType: .addPaymentCards), userDefaultsDismissKey(forType: .addPaymentCards))
    }
    
    func test_numberOfRows_isCorrect() {
        XCTAssertEqual(Self.pllWalletPrompt.numberOfRows, 1)
        XCTAssertEqual(Self.seeWalletPrompt.numberOfRows, 1)
        XCTAssertEqual(Self.storeWalletPrompt.numberOfRows, 1)
        XCTAssertEqual(Self.addPaymentCardsWalletPrompt.numberOfRows, 0)
        
        let planAccountModel = MembershipPlanAccountModel(apiId: nil, planName: "Tesco Rewards", planNameCard: nil, planURL: nil, companyName: "Harvey Nichols", category: nil, planSummary: nil, planDescription: nil, barcodeRedeemInstructions: nil, planRegisterInfo: nil, companyURL: nil, enrolIncentive: nil, forgottenPasswordUrl: nil, tiers: nil, planDocuments: nil, addFields: nil, authoriseFields: nil, registrationFields: nil, enrolFields: nil)
        let plan = MembershipPlanModel(apiId: nil, status: nil, featureSet: nil, images: nil, account: planAccountModel, balances: nil, dynamicContent: nil, hasVouchers: nil, card: nil)
        Self.baseMembershipPlans.append(plan)
        Self.baseMembershipPlans.append(plan)
        
        mapResponsesToManagedObjects(Self.baseMembershipPlans, managedObjectType: CD_MembershipPlan.self) { plans in
            Self.pllWalletPrompt = WalletPrompt(type: .link(plans: plans))
            XCTAssertEqual(Self.pllWalletPrompt.numberOfRows, 2)
        }
    }
    
    func test_numberOfItemsPerRow_isCorrect() {
        XCTAssertEqual(Self.pllWalletPrompt.numberOfItemsPerRow, 2)
        XCTAssertEqual(Self.seeWalletPrompt.numberOfItemsPerRow, 5)
        XCTAssertEqual(Self.storeWalletPrompt.numberOfItemsPerRow, 5)
        XCTAssertEqual(Self.addPaymentCardsWalletPrompt.numberOfItemsPerRow, 0)
    }
    
    func test_maxNumberOfPlansToDisplay_isCorrect() {
        XCTAssertEqual(Self.pllWalletPrompt.maxNumberOfPlansToDisplay, 4)
        XCTAssertEqual(Self.seeWalletPrompt.maxNumberOfPlansToDisplay, 10)
        XCTAssertEqual(Self.storeWalletPrompt.maxNumberOfPlansToDisplay, 10)
        XCTAssertEqual(Self.addPaymentCardsWalletPrompt.maxNumberOfPlansToDisplay, 0)
    }
    
    private func userDefaultsDismissKey(forType type: WalletPromptType) -> String {
        var userDefaultsDismiss = ""
        if let email = Current.userManager.currentEmailAddress {
            userDefaultsDismiss += "\(email)_"
        }
        
        switch type {
        case .addPaymentCards:
            return userDefaultsDismiss + "add_payment_card_prompt_was_dismissed"
        default:
            return ""
        }
    }
}
