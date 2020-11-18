//
//  WalletPromptTests.swift
//  binkappTests
//
//  Created by Sean Williams on 17/11/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import XCTest
@testable import binkapp

class WalletPromptTests: XCTestCase {
    var addPaymentCardsWalletPrompt: WalletPromptMock!
    var loyaltyJoinPrompt: WalletPromptMock!
    var membershipPlan: MembershipPlanModel!
    
    override func setUp() {
        super.setUp()
        addPaymentCardsWalletPrompt = WalletPromptMock(type: .addPaymentCards)

        let planAccountModel = MembershipPlanAccountModel(apiId: nil, planName: "Harvey Nichols Rewards", planNameCard: nil, planURL: nil, companyName: "Harvey Nichols", category: nil, planSummary: nil, planDescription: nil, barcodeRedeemInstructions: nil, planRegisterInfo: nil, companyURL: nil, enrolIncentive: nil, forgottenPasswordUrl: nil, tiers: nil, planDocuments: nil, addFields: nil, authoriseFields: nil, registrationFields: nil, enrolFields: nil)
        membershipPlan = MembershipPlanModel(apiId: nil, status: nil, featureSet: nil, images: nil, account: planAccountModel, balances: nil, dynamicContent: nil, hasVouchers: nil, card: nil)
        loyaltyJoinPrompt = WalletPromptMock(type: .loyaltyJoin(membershipPlan: membershipPlan))
    }
    
    func test_titleString_isCorrect() {
        XCTAssertEqual(addPaymentCardsWalletPrompt.title, "Add your payment cards")
        XCTAssertEqual(loyaltyJoinPrompt.title, "Harvey Nichols Rewards")
    }
    
    func test_bodyString_isCorrect() {
        XCTAssertEqual(addPaymentCardsWalletPrompt.body, "Collect rewards automatically for select loyalty cards by linking them to your payment cards.")
        XCTAssertEqual(loyaltyJoinPrompt.body, "Link this card to your payment cards to automatically collect rewards.")
    }
    
    func test_userDefaultsDismissKeyString_isCorrect() {
        XCTAssertEqual(addPaymentCardsWalletPrompt.userDefaultsDismissKey, userDefaultsDismissKey(forType: .addPaymentCards))
        XCTAssertEqual(loyaltyJoinPrompt.userDefaultsDismissKey, userDefaultsDismissKey(forType: .loyaltyJoin(membershipPlan: membershipPlan)))
    }
    
    func test_membershipPlanString_isCorrect() {
        XCTAssertEqual(loyaltyJoinPrompt.membershipPlan, membershipPlan)
        XCTAssertNil(addPaymentCardsWalletPrompt.membershipPlan)
    }
    
    func test_iconImageNameString_isCorrect() {
        XCTAssertEqual(addPaymentCardsWalletPrompt.iconImageName, "payment")
        XCTAssertNil(loyaltyJoinPrompt.iconImageName)
    }
    
    func test_userDefaultsDismissKeyFuncString_isCorrect() {
        XCTAssertEqual(addPaymentCardsWalletPrompt.userDefaultsDismissKey(forType: .addPaymentCards), userDefaultsDismissKey(forType: .addPaymentCards))
        XCTAssertEqual(loyaltyJoinPrompt.userDefaultsDismissKey(forType: .loyaltyJoin(membershipPlan: membershipPlan)), userDefaultsDismissKey(forType: .loyaltyJoin(membershipPlan: membershipPlan)))
    }
    
    private func userDefaultsDismissKey(forType type: WalletPromptTypeMock) -> String {
        var userDefaultsDismiss = ""
        if let email = Current.userManager.currentEmailAddress {
            userDefaultsDismiss += "\(email)_"
        }
        
        switch type {
        case .addPaymentCards:
            return userDefaultsDismiss + "add_payment_card_prompt_was_dismissed"
        case .loyaltyJoin(let plan):
            let planName = plan.account?.planName ?? ""
            return userDefaultsDismiss + "join_card_\(planName)_was_dismissed"
        }
    }
}
