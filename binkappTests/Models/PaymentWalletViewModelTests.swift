//
//  PaymentWalletViewModelTests.swift
//  binkappTests
//
//  Created by Ricardo Silva on 26/10/2022.
//  Copyright © 2022 Bink. All rights reserved.
//

import XCTest
import CardScan
@testable import binkapp
// swiftlint:disable all

final class PaymentWalletViewModelTests: XCTestCase, CoreDataTestable {
    
    static var paymentCard: CD_PaymentCard!
    static var basePaymentCardResponse: PaymentCardModel!
    static var paymentCardCardResponse: PaymentCardCardResponse!
    static let linkedResponse = LinkedCardResponse(id: 300, activeLink: true)
    static var sut = PaymentWalletViewModel()
    
    override class func setUp() {
        super.setUp()
        
        paymentCardCardResponse = PaymentCardCardResponse(apiId: 100, firstSix: nil, lastFour: "1234", month: 30, year: 3000, country: nil, currencyCode: nil, nameOnCard: "Rick Sanchez", provider: nil, type: nil)
        
        basePaymentCardResponse = PaymentCardModel(apiId: 100, membershipCards: [Self.linkedResponse], status: "active", card: paymentCardCardResponse, account: PaymentCardAccountResponse(apiId: 0, verificationInProgress: nil, status: 0, consents: []))
        
        mapResponseToManagedObject(Self.basePaymentCardResponse, managedObjectType: CD_PaymentCard.self) { paymentCard in
            Self.paymentCard = paymentCard
        }
    }
    
    func test_getsWalletPrompts_notEmpty() {
        Self.sut.setupWalletPrompts()

        XCTAssertNotNil(Self.sut.walletPrompts)
    }
    
    func test_showDeleteConfirmation() {
        Self.sut.showDeleteConfirmationAlert(card: Self.paymentCard, onCancel: {})
        
        XCTAssertTrue(Current.navigate.currentViewController!.isKind(of: BinkAlertController.self) == true)
    }
}
