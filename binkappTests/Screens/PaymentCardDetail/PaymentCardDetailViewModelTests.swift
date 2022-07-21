//
//  PaymentCardDetailViewModelTests.swift
//  binkappTests
//
//  Created by Sean Williams on 15/07/2022.
//  Copyright © 2022 Bink. All rights reserved.
//

import XCTest
@testable import binkapp

class PaymentCardDetailViewModelTests: XCTestCase, CoreDataTestable {
    static var baseMembershipCardResponse: MembershipCardModel!
    static var basePaymentCardResponse: PaymentCardModel!
    static let linkedResponse = LinkedCardResponse(id: 300, activeLink: true)

    static var membershipCard: CD_MembershipCard!
    static var paymentCard: CD_PaymentCard!
    static var membershipCardStatus: CD_MembershipCardStatus!

    static let baseSut = PaymentCardDetailViewModel(paymentCard: paymentCard, informationRowFactory: WalletCardDetailInformationRowFactory())
    
    static var walletDelegate: WalletTestable?

    override class func setUp() {
        super.setUp()
        // Membership Plan
        let featureSet = FeatureSetModel(apiId: nil, authorisationRequired: nil, transactionsAvailable: nil, digitalOnly: nil, hasPoints: nil, cardType: .link, linkingSupport: nil, hasVouchers: nil)
        let plan = MembershipPlanModel(apiId: 500, status: nil, featureSet: featureSet, images: nil, account: nil, balances: nil, dynamicContent: nil, hasVouchers: nil, card: nil)
        mapResponseToManagedObject(plan, managedObjectType: CD_MembershipPlan.self) { _ in }
        
        // Membership Card
        let statusResponse = MembershipCardStatusModel(apiId: 0, state: .authorised, reasonCodes: nil)
        mapResponseToManagedObject(statusResponse, managedObjectType: CD_MembershipCardStatus.self) { membershipCardStatus in
            self.membershipCardStatus = membershipCardStatus
        }
        
        baseMembershipCardResponse = MembershipCardModel(apiId: 300, membershipPlan: 500, membershipTransactions: nil, status: statusResponse, card: nil, images: nil, account: nil, paymentCards: nil, balances: nil, vouchers: nil)

        mapResponseToManagedObject(baseMembershipCardResponse, managedObjectType: CD_MembershipCard.self) { membershipCard in
            self.membershipCard = membershipCard
        }
        
        // Payment Card
        let card = PaymentCardCardResponse(apiId: 100, firstSix: nil, lastFour: "1234", month: 30, year: 3000, country: nil, currencyCode: nil, nameOnCard: "Sean Williams", provider: nil, type: nil)
                
        basePaymentCardResponse = PaymentCardModel(apiId: 100, membershipCards: [linkedResponse], status: "active", card: card, account: PaymentCardAccountResponse(apiId: 0, verificationInProgress: nil, status: 0, consents: []))
        
        mapResponseToManagedObject(basePaymentCardResponse, managedObjectType: CD_PaymentCard.self) { paymentCard in
            self.paymentCard = paymentCard
        }
        
        walletDelegate = Current.wallet
    }
    
    private func switchCardStatus(status: PaymentCardStatus, completion: @escaping EmptyCompletionBlock) {
        Self.basePaymentCardResponse.status = status.rawValue
        mapResponseToManagedObject(Self.basePaymentCardResponse, managedObjectType: CD_PaymentCard.self) { paymentCard in
            Self.paymentCard = paymentCard
            completion()
        }
    }
    
    func test_informationRows_returnsCorrectNumberOfRows_forCardStatus() {
        switchCardStatus(status: .active) {
            Self.baseSut.buildInformationRows()
            XCTAssertEqual(Self.baseSut.informationRows.count, 2)
        }

        switchCardStatus(status: .failed) {
            Self.baseSut.buildInformationRows()
            XCTAssertEqual(Self.baseSut.informationRows.count, 3)
        }
        
        switchCardStatus(status: .pending) {
            Self.baseSut.buildInformationRows()
            XCTAssertEqual(Self.baseSut.informationRows.count, 3)
        }
        
        switchCardStatus(status: .expired) {
            Self.baseSut.buildInformationRows()
            XCTAssertEqual(Self.baseSut.informationRows.count, 3)
        }
    }
    
    func test_paymentCardIsActive_returnsCorrectBool() {
        switchCardStatus(status: .active) {
            XCTAssertTrue(Self.baseSut.paymentCardIsActive)
        }
    }
    
    func test_paymentCardStatus_returnsCorrectBool() {
        switchCardStatus(status: .expired) {
            XCTAssertEqual(Self.baseSut.paymentCardStatus, .expired)
        }
        
        switchCardStatus(status: .active) {
            XCTAssertEqual(Self.baseSut.paymentCardStatus, .active)
        }
        
        switchCardStatus(status: .pending) {
            XCTAssertEqual(Self.baseSut.paymentCardStatus, .pending)
        }
        
        switchCardStatus(status: .failed) {
            XCTAssertEqual(Self.baseSut.paymentCardStatus, .failed)
        }
    }
    
    func test_pendingRefreshInterval_isCorrect() {
        XCTAssertEqual(Self.baseSut.pendingRefreshInterval, 30.0)
    }
    
    func test_paymentCardCellViewModel_initialisesViewModelCorrectly() {
        XCTAssertEqual(Self.baseSut.paymentCardCellViewModel, PaymentCardCellViewModel(paymentCard: Self.paymentCard))
    }
    
    func test_navigationViewTitleText_returnsCorrectTitle() {
        XCTAssertEqual(Self.baseSut.navigationViewTitleText, Self.paymentCard.card?.nameOnCard)
    }
    
    func test_navigationViewDetailText_returnsCorrectDigits() {
        XCTAssertEqual(Self.baseSut.navigationViewDetailText, "•••• \(Self.paymentCard.card?.lastFour ?? "")")
    }
    
    func test_addedCardsTitle_returnsCorrectTitleForStatus() {
        switchCardStatus(status: .active) {
            XCTAssertEqual(Self.baseSut.addedCardsTitle, L10n.pcdActiveCardTitle)
        }
        
        switchCardStatus(status: .pending) {
            XCTAssertEqual(Self.baseSut.addedCardsTitle, L10n.pcdPendingCardTitle)
        }
        
        switchCardStatus(status: .failed) {
            XCTAssertEqual(Self.baseSut.addedCardsTitle, L10n.pcdFailedCardTitle)
        }
        
        switchCardStatus(status: .expired) {
            XCTAssertEqual(Self.baseSut.addedCardsTitle, L10n.pcdExpiredCardTitle)
        }
    }
    
    func test_addedCardsDescription_returnsCorrectTitleForStatus() {
        switchCardStatus(status: .active) {
            XCTAssertEqual(Self.baseSut.addedCardsDescription, L10n.pcdActiveCardDescription)
        }
        
        switchCardStatus(status: .pending) {
            XCTAssertEqual(Self.baseSut.addedCardsDescription, L10n.pcdPendingCardDescription)
        }
        
        switchCardStatus(status: .failed) {
            XCTAssertEqual(Self.baseSut.addedCardsDescription, L10n.pcdFailedCardDescription)
        }
        
        switchCardStatus(status: .expired) {
            XCTAssertEqual(Self.baseSut.addedCardsDescription, L10n.pcdExpiredCardDescription)
        }
    }
    
    func test_paymentCard_didSet_buildsInformationRows() {
        XCTAssertNotNil(Self.baseSut.paymentCard)
        XCTAssertFalse(Self.baseSut.informationRows.isEmpty)
    }
    
    func test_cardAddedDateString_returnsCorrectString() {
        XCTAssertNil(Self.baseSut.cardAddedDateString)
        
        let consents = PaymentCardAccountConsentsResponse(apiId: 0, type: 0, timestamp: 98730947097989)
        Self.basePaymentCardResponse.account?.consents = [consents]
        mapResponseToManagedObject(Self.basePaymentCardResponse, managedObjectType: CD_PaymentCard.self) { paymentCard in
            Self.paymentCard = paymentCard
            XCTAssertEqual(Self.baseSut.cardAddedDateString, L10n.pcdPendingCardAdded("02 March 3130629"))
        }
    }
    
    func test_otherCardsTitle_returnsCorrectString() {
        Self.walletDelegate?.updateMembershipCards(membershipCards: [])
        XCTAssertEqual(Self.baseSut.otherCardsTitle, L10n.pcdOtherCardTitleNoCardsAdded)
        
        switchCardStatus(status: .active) {
            Self.walletDelegate?.updateMembershipCards(membershipCards: [Self.membershipCard])
            XCTAssertEqual(Self.baseSut.otherCardsTitle, L10n.pcdOtherCardTitleCardsAdded)
        }
    }
    
    func test_otherCardsDescription_returnsCorrectString() {
        Self.walletDelegate?.updateMembershipCards(membershipCards: [])
        XCTAssertEqual(Self.baseSut.otherCardsDescription, L10n.pcdOtherCardDescriptionNoCardsAdded)
        
        switchCardStatus(status: .active) {
            Self.walletDelegate?.updateMembershipCards(membershipCards: [Self.membershipCard])
            XCTAssertEqual(Self.baseSut.otherCardsDescription, L10n.pcdOtherCardDescriptionCardsAdded)
        }
    }
    
    func test_shouldShowPaymentCardCell_returnsTrue() {
        XCTAssertTrue(Self.baseSut.shouldShowPaymentCardCell)
    }
    
    func test_shouldShowAddedCardsTitleLabel_returnsCorrectBool() {
        Self.walletDelegate?.updateMembershipCards(membershipCards: [])
        switchCardStatus(status: .failed) {
            XCTAssertTrue(Self.baseSut.shouldShowAddedCardsTitleLabel)
        }
        
        switchCardStatus(status: .active) {
            XCTAssertFalse(Self.baseSut.shouldShowAddedCardsTitleLabel)

            Self.walletDelegate?.updateMembershipCards(membershipCards: [Self.membershipCard])
            XCTAssertTrue(Self.baseSut.shouldShowAddedCardsTitleLabel)
        }
    }
    
    func test_shouldShowAddedCardsDescriptionLabel_returnsCorrectBool() {
        Self.walletDelegate?.updateMembershipCards(membershipCards: [])
        switchCardStatus(status: .failed) {
            XCTAssertTrue(Self.baseSut.shouldShowAddedCardsDescriptionLabel)
        }
        
        switchCardStatus(status: .active) {
            XCTAssertFalse(Self.baseSut.shouldShowAddedCardsDescriptionLabel)

            Self.walletDelegate?.updateMembershipCards(membershipCards: [Self.membershipCard])
            XCTAssertTrue(Self.baseSut.shouldShowAddedCardsDescriptionLabel)
        }
    }
    
    func test_shouldShowOtherCardsTitleLabel_returnsCorrectBool() {
        Self.walletDelegate?.updateMembershipCards(membershipCards: [])
        switchCardStatus(status: .failed) {
            XCTAssertFalse(Self.baseSut.shouldShowOtherCardsTitleLabel)
        }
        
        switchCardStatus(status: .active) {
            XCTAssertFalse(Self.baseSut.shouldShowOtherCardsTitleLabel)
        }
    }
    
    func test_shouldShowOtherCardsDescriptionLabel_returnsCorrectBool() {
        Self.walletDelegate?.updateMembershipCards(membershipCards: [])
        switchCardStatus(status: .failed) {
            XCTAssertFalse(Self.baseSut.shouldShowOtherCardsDescriptionLabel)
        }
        
        switchCardStatus(status: .active) {
            XCTAssertFalse(Self.baseSut.shouldShowOtherCardsDescriptionLabel)
        }
    }
    
    func test_shouldShowCardAddedLabel_returnsCorrectBool() {
        switchCardStatus(status: .pending) {
            XCTAssertTrue(Self.baseSut.shouldShowCardAddedLabel)
        }
        
        switchCardStatus(status: .failed) {
            XCTAssertFalse(Self.baseSut.shouldShowCardAddedLabel)
        }
    }
    
    func test_shouldShowAddedLoyaltyCardTableView_returnsCorrectBool() {
        switchCardStatus(status: .active) {
            Self.walletDelegate?.updateMembershipCards(membershipCards: [Self.membershipCard])
            XCTAssertTrue(Self.baseSut.shouldShowAddedLoyaltyCardTableView)
        }
        
        switchCardStatus(status: .failed) {
            XCTAssertFalse(Self.baseSut.shouldShowAddedLoyaltyCardTableView)
        }
    }
    
    func test_pllMembershipCards_returnsMembershipCardArray() {
        Self.walletDelegate?.updateMembershipCards(membershipCards: [])
        XCTAssertEqual(Self.baseSut.pllMembershipCards, [])

        Self.walletDelegate?.updateMembershipCards(membershipCards: [Self.membershipCard])
        XCTAssertEqual(Self.baseSut.pllMembershipCards, [Self.membershipCard])
    }
    
    func test_pllMembershipCardsCount_returnsCorrectValue() {
        Self.walletDelegate?.updateMembershipCards(membershipCards: [])
        XCTAssertEqual(Self.baseSut.pllMembershipCardsCount, 0)

        Self.walletDelegate?.updateMembershipCards(membershipCards: [Self.membershipCard])
        XCTAssertEqual(Self.baseSut.pllMembershipCardsCount, 1)
    }
    
    func test_linkedMembershipCardIds_returnsCorrectIDsArray() {
        XCTAssertEqual(Self.baseSut.linkedMembershipCardIds, ["300"])
        
        Self.basePaymentCardResponse.membershipCards = []
        mapResponseToManagedObject(Self.basePaymentCardResponse, managedObjectType: CD_PaymentCard.self) { paymentCard in
            Self.paymentCard = paymentCard
            XCTAssertEqual(Self.baseSut.linkedMembershipCardIds, [])
        }
    }
    
    func test_membershipCardIsLinked_returnsCorrectBool() {
        Self.basePaymentCardResponse.membershipCards = [Self.linkedResponse]
        mapResponseToManagedObject(Self.basePaymentCardResponse, managedObjectType: CD_PaymentCard.self) { _ in
            XCTAssertTrue(Self.baseSut.membershipCardIsLinked(Self.membershipCard))
        }
        
        Self.basePaymentCardResponse.membershipCards = []
        mapResponseToManagedObject(Self.basePaymentCardResponse, managedObjectType: CD_PaymentCard.self) { paymentCard in
            Self.paymentCard = paymentCard
            XCTAssertFalse(Self.baseSut.membershipCardIsLinked(Self.membershipCard))
        }
    }
    
    func test_membershipCardForIndexPath_returnsCorrectCard() {
        Self.walletDelegate?.updateMembershipCards(membershipCards: [Self.membershipCard])
        XCTAssertEqual(Self.baseSut.membershipCard(forIndexPath: IndexPath(row: 0, section: 0)), Self.membershipCard)
        
        Self.walletDelegate?.updateMembershipCards(membershipCards: [])
        XCTAssertNil(Self.baseSut.membershipCard(forIndexPath: IndexPath(row: 0, section: 0)))
    }
    
    func test_statusForMembershipCard_returnsCorrectStatus() {
        Self.walletDelegate?.updateMembershipCards(membershipCards: [Self.membershipCard])
        XCTAssertEqual(Self.baseSut.statusForMembershipCard(atIndexPath: IndexPath(row: 0, section: 0))?.status, Self.membershipCardStatus.status)
        
        Self.walletDelegate?.updateMembershipCards(membershipCards: [])
        XCTAssertNil(Self.baseSut.statusForMembershipCard(atIndexPath: IndexPath(row: 0, section: 0)))
    }
}
