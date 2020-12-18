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
//    var basePaymentCard: PaymentCardModel!
    static var membershipCards: [LinkedCardResponse]!
    static var basePaymentCardResponse: PaymentCardModel!
    static var membershipCardResponse: MembershipCardModel!
    static var membershipCardResponse2: MembershipCardModel!
    
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
        membershipCardResponse2 = MembershipCardModel(apiId: 2, membershipPlan: nil, membershipTransactions: nil, status: nil, card: nil, images: nil, account: nil, paymentCards: nil, balances: nil, vouchers: nil)
        
        mapResponseToManagedObject(membershipCardResponse, managedObjectType: CD_MembershipCard.self) { _ in }
        mapResponseToManagedObject(membershipCardResponse2, managedObjectType: CD_MembershipCard.self) { _ in }
        
        basePaymentCardResponse = PaymentCardModel(apiId: 1, membershipCards: membershipCards, status: "active", card: paymentCardResponseModel, account: PaymentCardAccountResponse())
        mapResponseToManagedObject(basePaymentCardResponse, managedObjectType: CD_PaymentCard.self) { paymentCard in
            self.paymentCard = paymentCard
        }
    }
    
    private func mapPaymentCard() {
        mapResponseToManagedObject(Self.basePaymentCardResponse, managedObjectType: CD_PaymentCard.self) { paymentCard in
            Self.paymentCard = paymentCard
        }
    }

    func test_nameOnCard() {
        XCTAssertEqual(Self.sut.nameOnCardText, "Nick Farrant")
    }

    func test_cardNumberText() {
        XCTAssertEqual(Self.sut.cardNumberText?.string, "••••   ••••   ••••   4444")
    }

    func test_paymentCardType_isMasterCard() {
        XCTAssertEqual(Self.sut.paymentCardType, PaymentCardType.mastercard)
    }

    func test_paymentCardType_isVisa() {
        let paymentCardResponseModel = PaymentCardCardResponse(apiId: nil, firstSix: "424242", lastFour: nil, month: nil, year: nil, country: nil, currencyCode: nil, nameOnCard: nil, provider: nil, type: nil)
        Self.basePaymentCardResponse.card = paymentCardResponseModel
        mapResponseToManagedObject(Self.basePaymentCardResponse, managedObjectType: CD_PaymentCard.self) { paymentCard in
            PaymentCardCellViewModelTests.paymentCard = paymentCard
        }
        
        let sut = PaymentCardCellViewModel(paymentCard: PaymentCardCellViewModelTests.paymentCard)
        XCTAssertEqual(sut.paymentCardType, PaymentCardType.visa)
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
        XCTAssertFalse(Self.sut.paymentCardIsExpired)
    }

    func test_paymentCard_isExpired_recognisedCorrectly_whenExpired() {
        let paymentCardResponseModel = PaymentCardCardResponse(apiId: nil, firstSix: "424242", lastFour: "4242", month: 01, year: 2019, country: nil, currencyCode: nil, nameOnCard: "Nick Farrant", provider: nil, type: nil)
        Self.basePaymentCardResponse.card = paymentCardResponseModel
        mapResponseToManagedObject(Self.basePaymentCardResponse, managedObjectType: CD_PaymentCard.self) { paymentCard in
            PaymentCardCellViewModelTests.paymentCard = paymentCard
        }
        
        let sut = PaymentCardCellViewModel(paymentCard: PaymentCardCellViewModelTests.paymentCard)
        XCTAssertTrue(sut.paymentCardIsExpired)
    }
}
