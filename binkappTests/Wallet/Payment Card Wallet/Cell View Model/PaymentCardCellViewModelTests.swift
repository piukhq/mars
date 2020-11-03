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

class PaymentCardCellViewModelTests: XCTestCase {
    var basePaymentCard: PaymentCardModel!

    override func setUp() {
        super.setUp()
        basePaymentCard = PaymentCardModel(apiId: nil, membershipCards: nil, status: nil, card: PaymentCardCardResponse(), images: nil, account: PaymentCardAccountResponse())
    }

    func test_nameOnCard() {
        basePaymentCard.card?.nameOnCard = "Nick Farrant"
        let sut = PaymentCardCellViewModelMock(paymentCard: basePaymentCard)
        XCTAssertEqual(sut.nameOnCardText, "Nick Farrant")
    }

    func test_cardNumberText() {
        basePaymentCard.card?.lastFour = "4444"
        let sut = PaymentCardCellViewModelMock(paymentCard: basePaymentCard)
        XCTAssertEqual(sut.cardNumberText, "••••   ••••   ••••   4444")
    }

    func test_paymentCardType_isMasterCard() {
        basePaymentCard.card?.firstSix = "555555"
        basePaymentCard.card?.lastFour = "4444"
        let sut = PaymentCardCellViewModelMock(paymentCard: basePaymentCard)
        XCTAssertEqual(sut.paymentCardType, PaymentCardType.mastercard)
    }

    func test_paymentCardType_isVisa() {
        basePaymentCard.card?.firstSix = "424242"
        basePaymentCard.card?.lastFour = "4242"
        let sut = PaymentCardCellViewModelMock(paymentCard: basePaymentCard)
        XCTAssertEqual(sut.paymentCardType, PaymentCardType.visa)
    }

    func test_paymentCardIsLinkedToMembershipCards_isCorrect_whenNotLinked() {
        let sut = PaymentCardCellViewModelMock(paymentCard: basePaymentCard)
        XCTAssertFalse(sut.paymentCardIsLinkedToMembershipCards)
    }

    func test_paymentCardIsLinkedToMembershipCards_isCorrect_whenLinked() {
        basePaymentCard.membershipCards = [
            LinkedCardResponse(id: 1, activeLink: true),
            LinkedCardResponse(id: 1, activeLink: false)
        ]
        let sut = PaymentCardCellViewModelMock(paymentCard: basePaymentCard)
        XCTAssertTrue(sut.paymentCardIsLinkedToMembershipCards)
    }

    func test_linkedText_ifNoLinkedMembershipCards() {
        let sut = PaymentCardCellViewModelMock(paymentCard: basePaymentCard)
        XCTAssertEqual(sut.linkedText, "Not linked")
    }

    func test_linkedText_ifLinkedToOneMembershipCard() {
        basePaymentCard.membershipCards = [
            LinkedCardResponse(id: 1, activeLink: true),
            LinkedCardResponse(id: 2, activeLink: false)
        ]
        let sut = PaymentCardCellViewModelMock(paymentCard: basePaymentCard)
        XCTAssertEqual(sut.linkedText, "Linked to 1 loyalty card")
    }

    func test_linkedText_ifLinkedToTwoMembershipCards() {
        basePaymentCard.membershipCards = [
            LinkedCardResponse(id: 1, activeLink: true),
            LinkedCardResponse(id: 2, activeLink: true),
            LinkedCardResponse(id: 3, activeLink: false)
        ]
        let sut = PaymentCardCellViewModelMock(paymentCard: basePaymentCard)
        XCTAssertEqual(sut.linkedText, "Linked to 2 loyalty cards")
    }

    func test_paymentCard_isExpired_recognisedCorrectly_whenNotExpired() {
        basePaymentCard.card?.month = 01
        basePaymentCard.card?.year = 2030
        let sut = PaymentCardCellViewModelMock(paymentCard: basePaymentCard)
        XCTAssertFalse(sut.paymentCardIsExpired)
    }

    func test_paymentCard_isExpired_recognisedCorrectly_whenExpired() {
        basePaymentCard.card?.month = 01
        basePaymentCard.card?.year = 2019
        let sut = PaymentCardCellViewModelMock(paymentCard: basePaymentCard)
        XCTAssertTrue(sut.paymentCardIsExpired)
    }
}
