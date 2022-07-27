//
//  PLLScreenViewModelTests.swift
//  binkappTests
//
//  Created by Nick Farrant on 19/11/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import XCTest
import Mocker
@testable import binkapp

// swiftlint:disable all

class PLLScreenViewModelTests: XCTestCase, CoreDataTestable {
    // We have our base response model, that mimics what we would get from the API
    static var baseMembershipCardResponse: MembershipCardModel!
    static var basePaymentCardResponse: PaymentCardModel!
    static let linkedResponse = LinkedCardResponse(id: 300, activeLink: true)
    static var paymentCardCardResponse: PaymentCardCardResponse!

    // We have our dependancy model, which is mapped to core data from our response models and injected into view models
    static var membershipCard: CD_MembershipCard!
    static var paymentCard: CD_PaymentCard!

    // Our base system under test
    static let baseSut = PLLScreenViewModel(membershipCard: membershipCard, journey: .newCard)
    
    var currentViewController: UIViewController {
        return Current.navigate.currentViewController!
    }

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
        persistValidPaymentCard()
    }
    
    
    private func addPaymentCardToWallet() {
        Current.wallet.paymentCards = [Self.paymentCard]
    }
    
    private func removePaymentCardFromWallet() {
        Current.wallet.paymentCards = []
    }
    
    static private func persistValidPaymentCard() {
        paymentCardCardResponse = PaymentCardCardResponse(apiId: 100, firstSix: nil, lastFour: "1234", month: 30, year: 3000, country: nil, currencyCode: nil, nameOnCard: "Sean Williams", provider: nil, type: nil)
                
        Self.basePaymentCardResponse = PaymentCardModel(apiId: 100, membershipCards: [Self.linkedResponse], status: "active", card: paymentCardCardResponse, account: PaymentCardAccountResponse(apiId: 0, verificationInProgress: nil, status: 0, consents: []))
        
        mapResponseToManagedObject(Self.basePaymentCardResponse, managedObjectType: CD_PaymentCard.self) { paymentCard in
            Self.paymentCard = paymentCard
        }
    }
    
    private func switchCardStatus(status: PaymentCardStatus, completion: @escaping EmptyCompletionBlock) {
        Self.basePaymentCardResponse.status = status.rawValue
        mapResponseToManagedObject(Self.basePaymentCardResponse, managedObjectType: CD_PaymentCard.self) { paymentCard in
            Self.paymentCard = paymentCard
            completion()
        }
    }

    // MARK: - Empty wallet

    func test_activePaymentCards_returnsNilOrEmpty_whenNoneHaveBeenAdded() {
        XCTAssertTrue(Self.baseSut.activePaymentCards.isNilOrEmpty, "Active payment cards is not nil or empty. There are \(Self.baseSut.activePaymentCards?.count ?? 0) active payment cards.")
    }

    func test_pendingPaymentCards_returnsNil_whenNoneHaveBeenAdded() {
        XCTAssertTrue(Self.baseSut.pendingPaymentCards.isNilOrEmpty, "Pending payment cards is not nil or empty. There are \(Self.baseSut.pendingPaymentCards?.count ?? 0) pending payment cards.")
        
        addPaymentCardToWallet()
        switchCardStatus(status: .pending) {
            XCTAssertEqual(Self.baseSut.pendingPaymentCards?.count, 1)
        }
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
        switchCardStatus(status: .active) {
            XCTAssertEqual(Self.baseSut.primaryMessageText, "The payment cards below will be linked to your . Simply pay with them to collect points.")
            self.removePaymentCardFromWallet()
        }
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
        Self.baseSut.addCardToChangedCardsArray(card: Self.paymentCard)
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
    
    func test_linkedPaymentCards_returnsCorrectArray() {
        XCTAssertEqual(Self.baseSut.linkedPaymentCards, [Self.paymentCard])
    }
    
    func test_brandHeaderWasTapped_navigatesToCorrectViewController() {
        Self.baseSut.brandHeaderWasTapped()
        XCTAssertTrue(currentViewController.isKind(of: ReusableTemplateViewController.self))
    }
    
    func test_displaySimplePopup_navigatesToCorrectViewController() {
        Self.baseSut.displaySimplePopup(title: nil, message: nil) {}
        XCTAssertTrue(currentViewController.isKind(of: BinkAlertController.self))
    }
    
    func test_displayNoConnectivityPopup_navigatesToCorrectViewController() {
        Self.baseSut.displayNoConnectivityPopup {}
        XCTAssertTrue(currentViewController.isKind(of: BinkAlertController.self))
    }
    
    func test_close_dismissesModal() {
        Self.baseSut.close()
        XCTAssertNil(Current.navigate.currentViewController)
    }
    
    func test_toAddPaymentCardScreen_navigatesToCorrectViewController() {
        Self.baseSut.toAddPaymentCardScreen()
        XCTAssertTrue(currentViewController.isKind(of: AddPaymentCardViewController.self))
    }
    
    func test_toFAQsScreen_navigatesToCorrectViewController() {
        Self.baseSut.toFAQScreen()
        XCTAssertTrue(currentViewController.isKind(of: WebViewController.self))
    }
    
    func test_40_toggleLinkForMembershipCard_correctlyTogglesLinkage() {
        Current.apiClient.testResponeData = nil
        let mockedPaymentCard = try! JSONEncoder().encode(Self.basePaymentCardResponse)
        let endpoint = APIEndpoint.linkMembershipCardToPaymentCard(membershipCardId: Self.membershipCard.id, paymentCardId: Self.basePaymentCardResponse.id)
        let mock = Mock(url: URL(string: endpoint.urlString!)!, dataType: .json, statusCode: 200, data: [.delete: mockedPaymentCard])
        mock.register()
        
        Self.baseSut.addCardToChangedCardsArray(card: Self.paymentCard)
        Self.baseSut.toggleLinkForMembershipCards { success in }
        _ = XCTWaiter.wait(for: [self.expectation(description: "Wait for network call closure to complete")], timeout: 10.0)

        XCTAssertNotNil(Current.apiClient.testResponeData)
    }
    
    func test_41_toggleLinkForMembershipCard_correctlyTogglesLinkage() {
        Current.apiClient.testResponeData = nil
        let newPaymentCard = PaymentCardModel(apiId: 800, membershipCards: [], status: nil, card: nil, account: nil)
        let mockedPaymentCard = try! JSONEncoder().encode(Self.basePaymentCardResponse)
        let endpoint = APIEndpoint.linkMembershipCardToPaymentCard(membershipCardId: Self.membershipCard.id, paymentCardId: newPaymentCard.id)
        let mock = Mock(url: URL(string: endpoint.urlString!)!, dataType: .json, statusCode: 200, data: [.patch: mockedPaymentCard])
        mock.register()
        
        mapResponseToManagedObject(newPaymentCard, managedObjectType: CD_PaymentCard.self) { newPaymentCard in
            Self.baseSut.addCardToChangedCardsArray(card: newPaymentCard)
            Self.baseSut.toggleLinkForMembershipCards { _ in }
            _ = XCTWaiter.wait(for: [self.expectation(description: "Wait for network call closure to complete")], timeout: 10.0)

            XCTAssertNotNil(Current.apiClient.testResponeData)
            Self.baseSut.addCardToChangedCardsArray(card: newPaymentCard)
        }
    }
    func test_refreshMembershipCard_updatesCard() {
        Self.baseSut.refreshMembershipCard() {
            XCTAssertEqual(Self.baseSut.getMembershipCard(), Self.membershipCard)
        }
        
        _ = XCTWaiter.wait(for: [self.expectation(description: "Wait for network call closure to complete")], timeout: 10.0)
    }
}
