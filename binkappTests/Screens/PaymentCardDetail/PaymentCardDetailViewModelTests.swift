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

    static var membershipCard: CD_MembershipCard!
    static var paymentCard: CD_PaymentCard!

    static let baseSut = PaymentCardDetailViewModel(paymentCard: paymentCard, informationRowFactory: WalletCardDetailInformationRowFactory())

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
        let card = PaymentCardCardResponse(apiId: nil, firstSix: nil, lastFour: "1234", month: 30, year: 3000, country: nil, currencyCode: nil, nameOnCard: "Sean Williams", provider: nil, type: nil)
        
        let linkedResponse = LinkedCardResponse(id: 1, activeLink: true)
//        let consents = PaymentCardAccountConsentsResponse(apiId: 0, type: 0, timestamp: <#T##Int?#>)
        
        basePaymentCardResponse = PaymentCardModel(apiId: 100, membershipCards: [linkedResponse], status: "active", card: card, account: PaymentCardAccountResponse(apiId: 0, verificationInProgress: nil, status: 0, consents: []))
        
        mapResponseToManagedObject(basePaymentCardResponse, managedObjectType: CD_PaymentCard.self) { paymentCard in
            self.paymentCard = paymentCard
        }
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
    
//    func test_cardAddedDateString_returnsCorrectString() {
//        XCTAssertEqual(Self.baseSut.cardAddedDateString, L10n.pcdActiveCardDescription)
//    }
}
