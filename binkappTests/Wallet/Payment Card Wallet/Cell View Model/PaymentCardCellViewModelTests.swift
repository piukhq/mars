//
//  PaymentCardCellViewModelTests.swift
//  binkappTests
//
//  Created by Nick Farrant on 16/10/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import XCTest
import CoreData
@testable import binkapp

class PaymentCardCellViewModelTests: XCTestCase, CoreDataTestable {
    static var membershipCards: [LinkedCardResponse]!
    static var basePaymentCardResponse: PaymentCardModel!
    static var membershipCardResponse: MembershipCardModel!
    static var secondMembershipCardResponse: MembershipCardModel!
    
    static var paymentCard: CD_PaymentCard!
    
    static let sut = PaymentCardCellViewModel(paymentCard: paymentCard)

    override class func setUp() {
        super.setUp()
        let paymentCardResponseModel = PaymentCardCardResponse(apiId: 1, firstSix: "555555", lastFour: "4444", month: 01, year: 2030, country: nil, currencyCode: nil, nameOnCard: "Nick Farrant", provider: nil, type: nil)
        membershipCards = [
            LinkedCardResponse(id: 1, activeLink: true),
            LinkedCardResponse(id: 2, activeLink: false)
        ]
        membershipCardResponse = MembershipCardModel(apiId: 1, membershipPlan: nil, membershipTransactions: nil, status: nil, card: nil, images: nil, account: nil, paymentCards: nil, balances: nil, vouchers: nil)
        secondMembershipCardResponse = MembershipCardModel(apiId: 2, membershipPlan: nil, membershipTransactions: nil, status: nil, card: nil, images: nil, account: nil, paymentCards: nil, balances: nil, vouchers: nil)
        
        mapResponseToManagedObject(membershipCardResponse, managedObjectType: CD_MembershipCard.self) { _ in }
        mapResponseToManagedObject(secondMembershipCardResponse, managedObjectType: CD_MembershipCard.self) { _ in }
        
        basePaymentCardResponse = PaymentCardModel(apiId: 1, membershipCards: membershipCards, status: "active", card: paymentCardResponseModel, account: PaymentCardAccountResponse())
        mapResponseToManagedObject(basePaymentCardResponse, managedObjectType: CD_PaymentCard.self) { paymentCard in
            self.paymentCard = paymentCard
        }
    }
    
    
    // MARK: - Helper Methods

    private func mapPaymentCard() {
        mapResponseToManagedObject(Self.basePaymentCardResponse, managedObjectType: CD_PaymentCard.self) { paymentCard in
            Self.paymentCard = paymentCard
        }
    }

    
    // MARK: - Tests

    func test_nameOnCard() {
        XCTAssertEqual(Self.sut.nameOnCardText, "Nick Farrant")
    }

    func test_cardNumberText() {
        XCTAssertEqual(Self.sut.cardNumberText?.string, "••••   ••••   ••••   4444")
    }

    func test_paymentCardType_isMasterCard() {
        let paymentCardResponseModel = PaymentCardCardResponse(apiId: nil, firstSix: "555555", lastFour: nil, month: nil, year: nil, country: nil, currencyCode: nil, nameOnCard: nil, provider: nil, type: nil)
        Self.basePaymentCardResponse.card = paymentCardResponseModel
        mapPaymentCard()
        XCTAssertEqual(Self.sut.paymentCardType, PaymentCardType.mastercard)
    }

    func test_paymentCardType_isVisa() {
        let paymentCardResponseModel = PaymentCardCardResponse(apiId: nil, firstSix: "424242", lastFour: nil, month: nil, year: nil, country: nil, currencyCode: nil, nameOnCard: nil, provider: nil, type: nil)
        Self.basePaymentCardResponse.card = paymentCardResponseModel
        mapPaymentCard()
        XCTAssertEqual(Self.sut.paymentCardType, PaymentCardType.visa)
    }

    func test_paymentCardIsLinkedToMembershipCards_isCorrect_whenNotLinked() {
        Self.basePaymentCardResponse.membershipCards = nil
        mapPaymentCard()
        XCTAssertFalse(Self.sut.paymentCardIsLinkedToMembershipCards)
    }

    func test_paymentCardIsLinkedToMembershipCards_isCorrect_whenLinked() {
        Self.basePaymentCardResponse.membershipCards = Self.membershipCards
        mapPaymentCard()
        XCTAssertTrue(Self.sut.paymentCardIsLinkedToMembershipCards)
    }

    func test_linkedText_ifNoLinkedMembershipCards() {
        Self.basePaymentCardResponse.membershipCards = nil
        mapPaymentCard()
        XCTAssertEqual(Self.sut.statusText, "Not linked")
    }

    func test_linkedText_ifLinkedToOneMembershipCard() {
        XCTAssertEqual(Self.sut.statusText, "Linked to 1 loyalty card")
    }

    func test_linkedText_ifLinkedToTwoMembershipCards() {
        let membershipCardResponse = MembershipCardModel(apiId: 3, membershipPlan: nil, membershipTransactions: nil, status: nil, card: nil, images: nil, account: nil, paymentCards: nil, balances: nil, vouchers: nil)
        mapResponseToManagedObject(membershipCardResponse, managedObjectType: CD_MembershipCard.self) { _ in }
        Self.membershipCards.append(LinkedCardResponse(id: 3, activeLink: true))
        Self.basePaymentCardResponse.membershipCards = Self.membershipCards
        mapPaymentCard()
        XCTAssertEqual(Self.sut.statusText, "Linked to 2 loyalty cards")
    }

    func test_paymentCard_isExpired_recognisedCorrectly_whenNotExpired() {
        let paymentCardResponseModel = PaymentCardCardResponse(apiId: nil, firstSix: nil, lastFour: nil, month: 01, year: 2030, country: nil, currencyCode: nil, nameOnCard: nil, provider: nil, type: nil)
        Self.basePaymentCardResponse.card = paymentCardResponseModel
        mapPaymentCard()
        XCTAssertFalse(Self.sut.paymentCardIsExpired)
    }

    func test_paymentCard_isExpired_recognisedCorrectly_whenExpired() {
        let paymentCardResponseModel = PaymentCardCardResponse(apiId: nil, firstSix: nil, lastFour: nil, month: 01, year: 2019, country: nil, currencyCode: nil, nameOnCard: nil, provider: nil, type: nil)
        Self.basePaymentCardResponse.card = paymentCardResponseModel
        mapPaymentCard()
        XCTAssertTrue(Self.sut.paymentCardIsExpired)
    }
}
