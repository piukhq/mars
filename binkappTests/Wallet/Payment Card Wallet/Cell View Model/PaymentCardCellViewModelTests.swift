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
    var basePaymentCard: PaymentCardModel!
    
    static var basePaymentCardResponse: PaymentCardModel!
    
    static var paymentCard: CD_PaymentCard!
    
    static let sut = PaymentCardCellViewModel(paymentCard: paymentCard)

    override class func setUp() {
        super.setUp()
        let paymentCardResponseModel = PaymentCardCardResponse(apiId: 1, firstSix: "555555", lastFour: "4444", month: 01, year: 2030, country: nil, currencyCode: nil, nameOnCard: "Nick Farrant", provider: nil, type: nil)
        let membershhipCards = [
            LinkedCardResponse(id: 1, activeLink: true),
            LinkedCardResponse(id: 1, activeLink: false)
        ]
        
        basePaymentCardResponse = PaymentCardModel(apiId: 1, membershipCards: membershhipCards, status: "active", card: paymentCardResponseModel, account: PaymentCardAccountResponse())
        
        mapResponseToManagedObject(basePaymentCardResponse, managedObjectType: CD_PaymentCard.self) { paymentCard in
            self.paymentCard = paymentCard
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
        let paymentCardResponseModel = PaymentCardCardResponse(apiId: nil, firstSix: "424242", lastFour: "4242", month: 01, year: 2030, country: nil, currencyCode: nil, nameOnCard: "Nick Farrant", provider: nil, type: nil)
        Self.basePaymentCardResponse.card = paymentCardResponseModel
        mapResponseToManagedObject(Self.basePaymentCardResponse, managedObjectType: CD_PaymentCard.self) { paymentCard in
            PaymentCardCellViewModelTests.paymentCard = paymentCard
        }
        
        let sut = PaymentCardCellViewModel(paymentCard: PaymentCardCellViewModelTests.paymentCard)
        XCTAssertEqual(sut.paymentCardType, PaymentCardType.visa)
    }

    func test_paymentCardIsLinkedToMembershipCards_isCorrect_whenNotLinked() {
        XCTAssertFalse(Self.sut.paymentCardIsLinkedToMembershipCards)
    }

    func test_paymentCardIsLinkedToMembershipCards_isCorrect_whenLinked() {
//        basePaymentCard.membershipCards = [
//            LinkedCardResponse(id: 1, activeLink: true),
//            LinkedCardResponse(id: 1, activeLink: false)
//        ]
//        let sut = PaymentCardCellViewModelMock(paymentCard: basePaymentCard)
        XCTAssertTrue(Self.sut.paymentCardIsLinkedToMembershipCards)
    }

    func test_linkedText_ifNoLinkedMembershipCards() {
        XCTAssertEqual(Self.sut.statusText, "Not linked")
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
