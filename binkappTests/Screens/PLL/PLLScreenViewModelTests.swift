//
//  PLLScreenViewModelTests.swift
//  binkappTests
//
//  Created by Nick Farrant on 19/11/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import XCTest
@testable import binkapp

class PLLScreenViewModelTests: XCTestCase, CoreDataTestable {
    // We have our base response model, that mimics what we would get from the API
    static var baseMembershipCardResponse: MembershipCardModel!

    // We have our dependancy model, which is mapped to core data from our response models and injected into view models
    static var membershipCard: CD_MembershipCard!
    static var paymentCard: CD_PaymentCard!

    // Our base system under test
    static let baseSut = PLLScreenViewModel(membershipCard: membershipCard, journey: .newCard)

    // We use the class func because it is only run once per test class
    // This reduces Core Data writes, and we only do more than one if we are mutating values
    // Do as much setup in here as possible so that we can keep the amount of core data usage
    override class func setUp() {
        super.setUp()
        // Membership Plan
        let plan = MembershipPlanModel(apiId: 500, status: nil, featureSet: nil, images: nil, account: nil, balances: nil, dynamicContent: nil, hasVouchers: nil, card: nil)
        mapResponseToManagedObject(plan, managedObjectType: CD_MembershipPlan.self) { _ in }
        
        // Membership Card
        baseMembershipCardResponse = MembershipCardModel(apiId: 300, membershipPlan: 500, membershipTransactions: nil, status: nil, card: nil, images: nil, account: nil, paymentCards: nil, balances: nil, vouchers: nil)

        mapResponseToManagedObject(baseMembershipCardResponse, managedObjectType: CD_MembershipCard.self) { membershipCard in
            self.membershipCard = membershipCard
        }
        
        // Payment Card
        let linkedResponse = LinkedCardResponse(id: 1, activeLink: true)
        let paymentCard = PaymentCardModel(apiId: 0, membershipCards: [linkedResponse], status: "active", card: nil, account: PaymentCardAccountResponse(apiId: 0, verificationInProgress: nil, status: 0, consents: []))
        
        mapResponseToManagedObject(paymentCard, managedObjectType: CD_PaymentCard.self) { paymentCard in
            self.paymentCard = paymentCard
        }
    }
    
    
    private func addPaymentCardToWallet() {
        Current.wallet.paymentCards = [Self.paymentCard]
    }
    
    private func removePaymentCardFromWallet() {
        Current.wallet.paymentCards = []
    }

    // MARK: - Empty wallet

    func test_activePaymentCards_returnsNilOrEmpty_whenNoneHaveBeenAdded() {
        XCTAssertTrue(Self.baseSut.activePaymentCards.isNilOrEmpty, "Active payment cards is not nil or empty. There are \(Self.baseSut.activePaymentCards?.count ?? 0) active payment cards.")
    }

    func test_pendingPaymentCards_returnsNil_whenNoneHaveBeenAdded() {
        XCTAssertTrue(Self.baseSut.pendingPaymentCards.isNilOrEmpty, "Pending payment cards is not nil or empty. There are \(Self.baseSut.pendingPaymentCards?.count ?? 0) pending payment cards.")
    }

    func test_hasActivePaymentCards_returnsFalse_whenNoneHaveBeenAdded() {
        XCTAssertFalse(Self.baseSut.hasActivePaymentCards)
    }

    func test_shouldShowActivePaymentCards_returnsFalse_whenThereAreNone() {
        XCTAssertFalse(Self.baseSut.shouldShowActivePaymentCards)
    }

    func test_shouldPendingPaymentCards_returnsFalse_whenThereAreNone() {
        XCTAssertFalse(Self.baseSut.shouldShowPendingPaymentCards)
    }

    func test_isEmptyPLL_returnsTrue_whenThereAreNoPLLCards() {
        XCTAssertTrue(Self.baseSut.isEmptyPll)
    }

    func test_shouldShowBackButton_worksCorrectly_whenNewCardJourney() {
        XCTAssertFalse(Self.baseSut.shouldShowBackButton)
    }

    func test_shouldShowBackButton_worksCorrectly_whenExistingCardJourney() {
        let sut = PLLScreenViewModel(membershipCard: Self.membershipCard, journey: .existingCard)
        XCTAssertTrue(sut.shouldShowBackButton)
    }

    func test_titleText_isCorrect() {
        XCTAssertEqual(Self.baseSut.titleText, "Link to payment cards")
    }
    
    func test_primaryMessageText_isCorrect() {
        XCTAssertEqual(Self.baseSut.primaryMessageText, "You have not added any payment cards yet.")
        
        addPaymentCardToWallet()
        XCTAssertEqual(Self.baseSut.primaryMessageText, "The payment cards below will be linked to your . Simply pay with them to collect points.")
        removePaymentCardFromWallet()
    }
    
    func test_secondaryMessageText_isCorrect() {
        XCTAssertEqual(Self.baseSut.secondaryMessageText, "Add them to link this card and others.")
    }
    
    func test_shouldAllowDismiss_returnsCorrectBool() {
        XCTAssertTrue(Self.baseSut.shouldAllowDismiss)
        
        addPaymentCardToWallet()
        XCTAssertFalse(Self.baseSut.shouldAllowDismiss)
        removePaymentCardFromWallet()
    }
    
    func test_addingCardToChangedCardsArray_worksCorrectly() {
        XCTAssertTrue(Self.baseSut.changedLinkCards.isEmpty)
        Self.baseSut.addCardToChangedCardsArray(card: Self.paymentCard)
        XCTAssertFalse(Self.baseSut.changedLinkCards.isEmpty)
        Self.baseSut.addCardToChangedCardsArray(card: Self.paymentCard)
        XCTAssertTrue(Self.baseSut.changedLinkCards.isEmpty)
    }
    
    func test_getMembershipPlan_returnsCorrectPlan() {
        XCTAssertEqual(Self.baseSut.getMembershipPlan()?.id, "500")
    }
    
    func test_getMembershipCard_returnsCorrectCard() {
        XCTAssertEqual(Self.baseSut.getMembershipCard().id, "300")
    }
}
