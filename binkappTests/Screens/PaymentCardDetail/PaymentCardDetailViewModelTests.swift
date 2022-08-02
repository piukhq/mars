//
//  PaymentCardDetailViewModelTests.swift
//  binkappTests
//
//  Created by Sean Williams on 15/07/2022.
//  Copyright © 2022 Bink. All rights reserved.
//

import XCTest
import Mocker
@testable import binkapp

// swiftlint:disable all

class PaymentCardDetailViewModelTests: XCTestCase, CoreDataTestable, CardDetailInformationRowFactoryDelegate {
    func cardDetailInformationRowFactory(_ factory: WalletCardDetailInformationRowFactory, shouldPerformActionForRowType informationRowType: CardDetailInformationRow.RowType) {
        Self.informationRowActionResult = informationRowType.subtitle
    }
    
    static var baseMembershipCardResponse: MembershipCardModel!
    static var basePaymentCardResponse: PaymentCardModel!
    static var baseMembershipPlan: MembershipPlanModel!
    static var paymentCardCardResponse: PaymentCardCardResponse!
    static let linkedResponse = LinkedCardResponse(id: 300, activeLink: true)

    static var membershipCard: CD_MembershipCard!
    static var paymentCard: CD_PaymentCard!
    static var membershipPlan: CD_MembershipPlan!
    static var membershipCardStatus: CD_MembershipCardStatus!
    static var walletCardDetailInformationRowFactory: WalletCardDetailInformationRowFactory!

    static let baseSut = PaymentCardDetailViewModel(paymentCard: paymentCard, informationRowFactory: walletCardDetailInformationRowFactory)
    static var walletDelegate: WalletTestable?
    static var informationRowActionResult = ""
    
    var currentViewController: UIViewController {
        return Current.navigate.currentViewController!
    }

    override class func setUp() {
        super.setUp()
        // Membership Plan
        let featureSet = FeatureSetModel(apiId: nil, authorisationRequired: nil, transactionsAvailable: nil, digitalOnly: nil, hasPoints: nil, cardType: .link, linkingSupport: [.add], hasVouchers: nil)
        baseMembershipPlan = MembershipPlanModel(apiId: 500, status: nil, featureSet: featureSet, images: nil, account: nil, balances: nil, dynamicContent: nil, hasVouchers: nil, card: nil)
        mapResponseToManagedObject(baseMembershipPlan, managedObjectType: CD_MembershipPlan.self) { plan in
            self.membershipPlan = plan
        }
        
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
        persistValidPaymentCard()
        
        walletDelegate = Current.wallet
        walletCardDetailInformationRowFactory = WalletCardDetailInformationRowFactory()
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
    
    private func updateWalletWithPllPlanNotAlreadyAddedToWallet(completion: @escaping (CD_MembershipPlan) -> Void) {
        let featureSet = FeatureSetModel(apiId: nil, authorisationRequired: nil, transactionsAvailable: nil, digitalOnly: nil, hasPoints: true, cardType: .link, linkingSupport: [.add], hasVouchers: nil)
        let pllPlan = MembershipPlanModel(apiId: 20, status: nil, featureSet: featureSet, images: nil, account: nil, balances: nil, dynamicContent: nil, hasVouchers: nil, card: nil)
        mapResponseToManagedObject(pllPlan, managedObjectType: CD_MembershipPlan.self) { plan in
            Self.walletDelegate?.updateMembershipCards(membershipCards: [Self.membershipCard])
            Self.walletDelegate?.updateMembershipPlans(membershipPlans: [plan])
            completion(plan)
        }
    }
    
    private func removePlansFromWallet() {
        Self.walletDelegate?.updateMembershipPlans(membershipPlans: [])
    }
    
    private func removecardssFromWallet() {
        Self.walletDelegate?.updateMembershipCards(membershipCards: [])
    }

    func test_0_informationRows_returnsCorrectNumberOfRows_forCardStatus() {
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
    
    func test_1_paymentCardIsActive_returnsCorrectBool() {
        switchCardStatus(status: .active) {
            XCTAssertTrue(Self.baseSut.paymentCardIsActive)
        }
    }
    
    func test_2_paymentCardStatus_returnsCorrectBool() {
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
    
    func test_3_pendingRefreshInterval_isCorrect() {
        XCTAssertEqual(Self.baseSut.pendingRefreshInterval, 30.0)
    }
    
    func test_4_paymentCardCellViewModel_initialisesViewModelCorrectly() {
        XCTAssertEqual(Self.baseSut.paymentCardCellViewModel, PaymentCardCellViewModel(paymentCard: Self.paymentCard))
    }
    
    func test_5_navigationViewTitleText_returnsCorrectTitle() {
        Self.persistValidPaymentCard()
        XCTAssertEqual(Self.baseSut.navigationViewTitleText, Self.paymentCard.card?.nameOnCard)
        
        Self.basePaymentCardResponse.card = nil
        mapResponseToManagedObject(Self.basePaymentCardResponse, managedObjectType: CD_PaymentCard.self) { paymentCard in
            Self.paymentCard = paymentCard
            XCTAssertEqual(Self.baseSut.navigationViewTitleText, "")
        }
    }
    
    func test_6_navigationViewDetailText_returnsCorrectDigits() {
        Self.persistValidPaymentCard()
        XCTAssertEqual(Self.baseSut.navigationViewDetailText, "•••• \(Self.paymentCard.card?.lastFour ?? "")")
        
        Self.basePaymentCardResponse.card = nil
        mapResponseToManagedObject(Self.basePaymentCardResponse, managedObjectType: CD_PaymentCard.self) { paymentCard in
            Self.paymentCard = paymentCard
            XCTAssertEqual(Self.baseSut.navigationViewDetailText, "•••• ")
        }
    }
    
    func test_7_addedCardsTitle_returnsCorrectTitleForStatus() {
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
    
    func test_8_addedCardsDescription_returnsCorrectTitleForStatus() {
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
    
    func test_9_paymentCard_didSet_buildsInformationRows() {
        XCTAssertNotNil(Self.baseSut.paymentCard)
        XCTAssertFalse(Self.baseSut.informationRows.isEmpty)
    }
    
    func test_10_cardAddedDateString_returnsCorrectString() {
        XCTAssertNil(Self.baseSut.cardAddedDateString)
        
        let consents = PaymentCardAccountConsentsResponse(apiId: 0, type: 0, timestamp: 98730947097989)
        Self.basePaymentCardResponse.account?.consents = [consents]
        mapResponseToManagedObject(Self.basePaymentCardResponse, managedObjectType: CD_PaymentCard.self) { paymentCard in
            Self.paymentCard = paymentCard
            XCTAssertEqual(Self.baseSut.cardAddedDateString, L10n.pcdPendingCardAdded("02 March 3130629"))
        }
    }
    
    func test_11_otherCardsTitle_returnsCorrectString() {
        Self.walletDelegate?.updateMembershipCards(membershipCards: [])
        XCTAssertEqual(Self.baseSut.otherCardsTitle, L10n.pcdOtherCardTitleNoCardsAdded)
        
        switchCardStatus(status: .active) {
            Self.walletDelegate?.updateMembershipCards(membershipCards: [Self.membershipCard])
            XCTAssertEqual(Self.baseSut.otherCardsTitle, L10n.pcdOtherCardTitleCardsAdded)
        }
    }
    
    func test_12_otherCardsDescription_returnsCorrectString() {
        Self.walletDelegate?.updateMembershipCards(membershipCards: [])
        XCTAssertEqual(Self.baseSut.otherCardsDescription, L10n.pcdOtherCardDescriptionNoCardsAdded)
        
        switchCardStatus(status: .active) {
            Self.walletDelegate?.updateMembershipCards(membershipCards: [Self.membershipCard])
            XCTAssertEqual(Self.baseSut.otherCardsDescription, L10n.pcdOtherCardDescriptionCardsAdded)
        }
    }
    
    func test_13_shouldShowPaymentCardCell_returnsTrue() {
        XCTAssertTrue(Self.baseSut.shouldShowPaymentCardCell)
    }
    
    func test_14_shouldShowAddedCardsTitleLabel_returnsCorrectBool() {
        Self.walletDelegate?.updateMembershipCards(membershipCards: [])
        switchCardStatus(status: .failed) {
            XCTAssertTrue(Self.baseSut.shouldShowAddedCardsTitleLabel)
        }
        
        switchCardStatus(status: .active) {
            Self.walletDelegate?.updateMembershipCards(membershipCards: [])
            XCTAssertFalse(Self.baseSut.shouldShowAddedCardsTitleLabel)

            Self.walletDelegate?.updateMembershipCards(membershipCards: [Self.membershipCard])
            XCTAssertTrue(Self.baseSut.shouldShowAddedCardsTitleLabel)
        }
    }
    
    func test_15_shouldShowAddedCardsDescriptionLabel_returnsCorrectBool() {
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
    
    func test_16_shouldShowOtherCardsTitleLabel_returnsCorrectBool() {
        Self.walletDelegate?.updateMembershipCards(membershipCards: [])
        switchCardStatus(status: .failed) {
            XCTAssertFalse(Self.baseSut.shouldShowOtherCardsTitleLabel)
        }
        
        switchCardStatus(status: .active) {
            self.removePlansFromWallet()
            XCTAssertFalse(Self.baseSut.shouldShowOtherCardsTitleLabel)
        }
    }
    
    func test_17_shouldShowOtherCardsDescriptionLabel_returnsCorrectBool() {
        Self.walletDelegate?.updateMembershipCards(membershipCards: [])
        switchCardStatus(status: .failed) {
            XCTAssertFalse(Self.baseSut.shouldShowOtherCardsDescriptionLabel)
        }
        
        removePlansFromWallet()
        switchCardStatus(status: .active) {
            XCTAssertFalse(Self.baseSut.shouldShowOtherCardsDescriptionLabel)
        }
        
        updateWalletWithPllPlanNotAlreadyAddedToWallet() { _ in
            XCTAssertTrue(Self.baseSut.shouldShowOtherCardsDescriptionLabel)
        }
    }
    
    func test_18_shouldShowCardAddedLabel_returnsCorrectBool() {
        switchCardStatus(status: .pending) {
            XCTAssertTrue(Self.baseSut.shouldShowCardAddedLabel)
        }
        
        switchCardStatus(status: .failed) {
            XCTAssertFalse(Self.baseSut.shouldShowCardAddedLabel)
        }
    }
    
    func test_19_shouldShowAddedLoyaltyCardTableView_returnsCorrectBool() {
        switchCardStatus(status: .active) {
            Self.walletDelegate?.updateMembershipCards(membershipCards: [Self.membershipCard])
            XCTAssertTrue(Self.baseSut.shouldShowAddedLoyaltyCardTableView)
        }
        
        switchCardStatus(status: .failed) {
            XCTAssertFalse(Self.baseSut.shouldShowAddedLoyaltyCardTableView)
        }
    }
    
    func test_20_shouldShowOtherCardsTableView_returnsCorrectBool() {
        removePlansFromWallet()
        XCTAssertFalse(Self.baseSut.shouldShowOtherCardsTableView)
        
        updateWalletWithPllPlanNotAlreadyAddedToWallet { _ in
            self.switchCardStatus(status: .active) {
                XCTAssertTrue(Self.baseSut.shouldShowOtherCardsTableView)
            }
            
            self.switchCardStatus(status: .pending) {
                XCTAssertFalse(Self.baseSut.shouldShowOtherCardsTableView)
            }
        }
    }
    
    func test_21_shouldShowInformationTableView_returnsTrue() {
        XCTAssertTrue(Self.baseSut.shouldShowInformationTableView)
    }
    
    func test_22_shouldShowSeparator_returnsCorrectBool() {
        switchCardStatus(status: .active) {
            XCTAssertFalse(Self.baseSut.shouldShowSeparator)
        }
        
        switchCardStatus(status: .pending) {
            XCTAssertTrue(Self.baseSut.shouldShowSeparator)
        }
        
        switchCardStatus(status: .expired) {
            XCTAssertTrue(Self.baseSut.shouldShowSeparator)
        }
        
        switchCardStatus(status: .failed) {
            XCTAssertTrue(Self.baseSut.shouldShowSeparator)
        }
    }
    
    func test_23_pllMembershipPlans_returnsCorrectPlansArray() {
        removePlansFromWallet()
        XCTAssertEqual(Self.baseSut.pllMembershipPlans, [])
        
        Self.walletDelegate?.updateMembershipPlans(membershipPlans: [Self.membershipPlan])
        XCTAssertEqual(Self.baseSut.pllMembershipPlans, [Self.membershipPlan])
    }
    
    func test_24_pllPlansAddedToWallet_returnsCorrectPlansArray() {
        removecardssFromWallet()
        XCTAssertEqual(Self.baseSut.pllPlansAddedToWallet, [])
        
        Self.walletDelegate?.updateMembershipCards(membershipCards: [Self.membershipCard])
        XCTAssertEqual(Self.baseSut.pllPlansAddedToWallet, [Self.membershipPlan])
    }
    
    func test_25_pllPlansNotAddedToWallet_returnsCorrectPlansArray() {
        removePlansFromWallet()
        XCTAssertEqual(Self.baseSut.pllPlansNotAddedToWallet, [])
        
        updateWalletWithPllPlanNotAlreadyAddedToWallet { planNotAdded in
            XCTAssertEqual(Self.baseSut.pllPlansNotAddedToWallet, [planNotAdded])
        }
    }
    
    func test_26_pllPlansNotAddedToWalletCount_returnsCorrectValue() {
        Self.walletDelegate?.setMembershipPlansToNil()
        XCTAssertEqual(Self.baseSut.pllPlansNotAddedToWalletCount, 0)
        
        updateWalletWithPllPlanNotAlreadyAddedToWallet { _ in
            XCTAssertEqual(Self.baseSut.pllPlansNotAddedToWalletCount, 1)
        }
    }
    
    func test_27_pllPlanNotAddedToWallet_forIndexPath_returnsCorrectMembershipPlan() {
        removePlansFromWallet()
        XCTAssertNil(Self.baseSut.pllPlanNotAddedToWallet(forIndexPath: IndexPath(row: 0, section: 0)))
        
        updateWalletWithPllPlanNotAlreadyAddedToWallet { plan in
            XCTAssertEqual(Self.baseSut.pllPlanNotAddedToWallet(forIndexPath: IndexPath(row: 0, section: 0)), plan)
        }
    }

    func test_28_pllMembershipCards_returnsMembershipCardArray() {
        Self.walletDelegate?.updateMembershipCards(membershipCards: [])
        XCTAssertEqual(Self.baseSut.pllMembershipCards, [])

        Self.walletDelegate?.updateMembershipCards(membershipCards: [Self.membershipCard])
        XCTAssertEqual(Self.baseSut.pllMembershipCards, [Self.membershipCard])
    }
    
    func test_29_pllMembershipCardsCount_returnsCorrectValue() {
        Self.walletDelegate?.setMembershipCardsToNil()
        XCTAssertEqual(Self.baseSut.pllMembershipCardsCount, 0)

        Self.walletDelegate?.updateMembershipCards(membershipCards: [Self.membershipCard])
        XCTAssertEqual(Self.baseSut.pllMembershipCardsCount, 1)
    }
    
    func test_30_linkedMembershipCardIds_returnsCorrectIDsArray() {
        XCTAssertEqual(Self.baseSut.linkedMembershipCardIds, ["300"])
        
        Self.basePaymentCardResponse.membershipCards = []
        mapResponseToManagedObject(Self.basePaymentCardResponse, managedObjectType: CD_PaymentCard.self) { paymentCard in
            Self.paymentCard = paymentCard
            XCTAssertEqual(Self.baseSut.linkedMembershipCardIds, [])
        }
    }
    
    func test_31_membershipCardIsLinked_returnsCorrectBool() {
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
    
    func test_32_membershipCardForIndexPath_returnsCorrectCard() {
        Self.walletDelegate?.updateMembershipCards(membershipCards: [Self.membershipCard])
        XCTAssertEqual(Self.baseSut.membershipCard(forIndexPath: IndexPath(row: 0, section: 0)), Self.membershipCard)
        
        Self.walletDelegate?.updateMembershipCards(membershipCards: [])
        XCTAssertNil(Self.baseSut.membershipCard(forIndexPath: IndexPath(row: 0, section: 0)))
    }
    
    func test_33_statusForMembershipCard_returnsCorrectStatus() {
        Self.walletDelegate?.updateMembershipCards(membershipCards: [Self.membershipCard])
        XCTAssertEqual(Self.baseSut.statusForMembershipCard(atIndexPath: IndexPath(row: 0, section: 0))?.status, Self.membershipCardStatus.status)
        
        Self.walletDelegate?.updateMembershipCards(membershipCards: [])
        XCTAssertNil(Self.baseSut.statusForMembershipCard(atIndexPath: IndexPath(row: 0, section: 0)))
    }
    
    func test_34_informationRowForIndexPath_returnsCorrectRow_() {
        switchCardStatus(status: .active) {
            Self.baseSut.buildInformationRows()
            XCTAssertEqual(Self.baseSut.informationRow(forIndexPath: IndexPath(row: 0, section: 0)), CardDetailInformationRow(type: .securityAndPrivacy, action: {}))
            XCTAssertEqual(Self.baseSut.informationRow(forIndexPath: IndexPath(row: 1, section: 0)), CardDetailInformationRow(type: .deletePaymentCard, action: {}))
        }
        
        switchCardStatus(status: .failed) {
            Self.baseSut.buildInformationRows()
            XCTAssertEqual(Self.baseSut.informationRow(forIndexPath: IndexPath(row: 0, section: 0)), CardDetailInformationRow(type: .securityAndPrivacy, action: {}))
            XCTAssertEqual(Self.baseSut.informationRow(forIndexPath: IndexPath(row: 1, section: 0)), CardDetailInformationRow(type: .deletePaymentCard, action: {}))
            XCTAssertEqual(Self.baseSut.informationRow(forIndexPath: IndexPath(row: 2, section: 0)), CardDetailInformationRow(type: .faqs, action: {}))
        }
        
        switchCardStatus(status: .pending) {
            Self.baseSut.buildInformationRows()
            XCTAssertEqual(Self.baseSut.informationRow(forIndexPath: IndexPath(row: 0, section: 0)), CardDetailInformationRow(type: .securityAndPrivacy, action: {}))
            XCTAssertEqual(Self.baseSut.informationRow(forIndexPath: IndexPath(row: 1, section: 0)), CardDetailInformationRow(type: .deletePaymentCard, action: {}))
            XCTAssertEqual(Self.baseSut.informationRow(forIndexPath: IndexPath(row: 2, section: 0)), CardDetailInformationRow(type: .faqs, action: {}))
        }
        
        switchCardStatus(status: .expired) {
            Self.baseSut.buildInformationRows()
            XCTAssertEqual(Self.baseSut.informationRow(forIndexPath: IndexPath(row: 0, section: 0)), CardDetailInformationRow(type: .securityAndPrivacy, action: {}))
            XCTAssertEqual(Self.baseSut.informationRow(forIndexPath: IndexPath(row: 1, section: 0)), CardDetailInformationRow(type: .deletePaymentCard, action: {}))
            XCTAssertEqual(Self.baseSut.informationRow(forIndexPath: IndexPath(row: 2, section: 0)), CardDetailInformationRow(type: .faqs, action: {}))
        }
    }
    
    func test_35_performActionForInformationRowatIndexPath_performsCorrectAction() {
        Self.walletCardDetailInformationRowFactory.delegate = self
        switchCardStatus(status: .active) {
            Self.baseSut.buildInformationRows()

            Self.baseSut.performActionForInformationRow(atIndexPath: IndexPath(row: 0, section: 0))
            XCTAssertEqual(CardDetailInformationRow.RowType.securityAndPrivacy.subtitle, Self.informationRowActionResult)
            Self.baseSut.performActionForInformationRow(atIndexPath: IndexPath(row: 1, section: 0))
            XCTAssertEqual(CardDetailInformationRow.RowType.deletePaymentCard.subtitle, Self.informationRowActionResult)
        }
        
        switchCardStatus(status: .failed) {
            Self.baseSut.buildInformationRows()

            Self.baseSut.performActionForInformationRow(atIndexPath: IndexPath(row: 0, section: 0))
            XCTAssertEqual(CardDetailInformationRow.RowType.securityAndPrivacy.subtitle, Self.informationRowActionResult)
            Self.baseSut.performActionForInformationRow(atIndexPath: IndexPath(row: 1, section: 0))
            XCTAssertEqual(CardDetailInformationRow.RowType.deletePaymentCard.subtitle, Self.informationRowActionResult)
            
            Self.baseSut.performActionForInformationRow(atIndexPath: IndexPath(row: 2, section: 0))
            _ = XCTWaiter.wait(for: [self.expectation(description: "Wait for failed closure action to complete")], timeout: 1.0)
            XCTAssertEqual(CardDetailInformationRow.RowType.faqs.subtitle, Self.informationRowActionResult)
        }
        
        switchCardStatus(status: .pending) {
            Self.baseSut.buildInformationRows()

            Self.baseSut.performActionForInformationRow(atIndexPath: IndexPath(row: 0, section: 0))
            XCTAssertEqual(CardDetailInformationRow.RowType.securityAndPrivacy.subtitle, Self.informationRowActionResult)
            Self.baseSut.performActionForInformationRow(atIndexPath: IndexPath(row: 1, section: 0))
            XCTAssertEqual(CardDetailInformationRow.RowType.deletePaymentCard.subtitle, Self.informationRowActionResult)
            
            Self.baseSut.performActionForInformationRow(atIndexPath: IndexPath(row: 2, section: 0))
            _ = XCTWaiter.wait(for: [self.expectation(description: "Wait for pending closure action to complete")], timeout: 1.0)
            XCTAssertEqual(CardDetailInformationRow.RowType.faqs.subtitle, Self.informationRowActionResult)
        }
        
        switchCardStatus(status: .expired) {
            Self.baseSut.buildInformationRows()

            Self.baseSut.performActionForInformationRow(atIndexPath: IndexPath(row: 0, section: 0))
            XCTAssertEqual(CardDetailInformationRow.RowType.securityAndPrivacy.subtitle, Self.informationRowActionResult)
            Self.baseSut.performActionForInformationRow(atIndexPath: IndexPath(row: 1, section: 0))
            XCTAssertEqual(CardDetailInformationRow.RowType.deletePaymentCard.subtitle, Self.informationRowActionResult)
            
            Self.baseSut.performActionForInformationRow(atIndexPath: IndexPath(row: 2, section: 0))
            _ = XCTWaiter.wait(for: [self.expectation(description: "Wait for expired closure action to complete")], timeout: 1.0)
            XCTAssertEqual(CardDetailInformationRow.RowType.faqs.subtitle, Self.informationRowActionResult)
        }
    }
    
    func test_36_toFAQsScreen_navigatesToCorrectViewController() {
        Self.baseSut.toFAQsScreen()
        XCTAssertTrue(currentViewController.isKind(of: WebViewController.self))
    }
    
    func test_37_toSecurityAndPrivacy_navigatesToCorrectViewController() {
        Self.baseSut.toSecurityAndPrivacyScreen()
        XCTAssertTrue(currentViewController.isKind(of: ReusableTemplateViewController.self))
    }
    
    func test_38_showDeleteConfirmationAlert_navigatesToCorrectViewController() {
        Self.baseSut.showDeleteConfirmationAlert()
        XCTAssertTrue(currentViewController.isKind(of: BinkAlertController.self))
    }
    
    func test_39_refreshPaymentCard_returnsSuccessfulUpdatedPaymentCard() {
        let mockedPaymentCard = try! JSONEncoder().encode(Self.basePaymentCardResponse)
        let endpoint = APIEndpoint.paymentCard(cardId: Self.basePaymentCardResponse.id)
        let mock = Mock(url: URL(string: endpoint.urlString!)!, dataType: .json, statusCode: 200, data: [.get: mockedPaymentCard])
        mock.register()
        Self.baseSut.refreshPaymentCard {
            if let paymentCardResponse = Current.apiClient.testResponseData as? Safe<PaymentCardModel> {
                XCTAssertEqual(paymentCardResponse.value?.id, Self.baseSut.paymentCard.id)
            } else {
                XCTFail("Failed to cast payment card response")
            }
        }
        
        _ = XCTWaiter.wait(for: [self.expectation(description: "Wait for network call closure to complete")], timeout: 10.0)
    }
    
    func test_40_toggleLinkForMembershipCard_correctlyTogglesLinkage() {
        XCTAssertFalse(Self.baseSut.membershipCardIsLinked(Self.membershipCard))
        let mockedPaymentCard = try! JSONEncoder().encode(Self.basePaymentCardResponse)
        let endpoint = APIEndpoint.linkMembershipCardToPaymentCard(membershipCardId: Self.membershipCard.id, paymentCardId: Self.basePaymentCardResponse.id)
        let mock = Mock(url: URL(string: endpoint.urlString!)!, dataType: .json, statusCode: 200, data: [.patch: mockedPaymentCard])
        mock.register()
        Self.baseSut.toggleLinkForMembershipCard(Self.membershipCard) {
            Self.basePaymentCardResponse = PaymentCardModel(apiId: 100, membershipCards: [Self.linkedResponse], status: "active", card: Self.paymentCardCardResponse, account: PaymentCardAccountResponse(apiId: 0, verificationInProgress: nil, status: 0, consents: []))

            self.mapResponseToManagedObject(Self.basePaymentCardResponse, managedObjectType: CD_PaymentCard.self) { paymentCard in
                Self.paymentCard = paymentCard
                XCTAssertTrue(Self.baseSut.membershipCardIsLinked(Self.membershipCard))
            }
        }

        _ = XCTWaiter.wait(for: [self.expectation(description: "Wait for network call closure to complete")], timeout: 5.0)
    }
    
    func test_41_toggleLinkForMembershipCard_correctlyTogglesLinkage() {
        XCTAssertTrue(Self.baseSut.membershipCardIsLinked(Self.membershipCard))
        let mockedPaymentCard = try! JSONEncoder().encode(Self.basePaymentCardResponse)
        let endpoint = APIEndpoint.linkMembershipCardToPaymentCard(membershipCardId: Self.membershipCard.id, paymentCardId: Self.basePaymentCardResponse.id)
        let mock = Mock(url: URL(string: endpoint.urlString!)!, dataType: .json, statusCode: 200, data: [.delete: mockedPaymentCard])
        mock.register()
        Self.baseSut.toggleLinkForMembershipCard(Self.membershipCard) {
            Self.basePaymentCardResponse = PaymentCardModel(apiId: 100, membershipCards: [], status: "active", card: Self.paymentCardCardResponse, account: PaymentCardAccountResponse(apiId: 0, verificationInProgress: nil, status: 0, consents: []))

            self.mapResponseToManagedObject(Self.basePaymentCardResponse, managedObjectType: CD_PaymentCard.self) { paymentCard in
                Self.paymentCard = paymentCard
                XCTAssertFalse(Self.baseSut.membershipCardIsLinked(Self.membershipCard))
            }
        }

        _ = XCTWaiter.wait(for: [self.expectation(description: "Wait for network call closure to complete")], timeout: 5.0)
    }
}
