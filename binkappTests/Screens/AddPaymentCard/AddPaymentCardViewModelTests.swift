//
//  AddPaymentCardViewModelTests.swift
//  binkappTests
//
//  Created by Ricardo Silva on 23/08/2022.
//  Copyright © 2022 Bink. All rights reserved.
//

import XCTest
import SwiftUI
import CardScan
@testable import binkapp

// swiftlint:disable all

class AddPaymentCardViewModelTests: XCTestCase {
    static var model: AddPaymentCardViewModel!
    static var paymentCardCreateModel = PaymentCardCreateModel(fullPan: "5454 5454 5454 5454", nameOnCard: "Rick Morty", month: 4, year: 2030)
    
    override class func setUp() {
        super.setUp()
        paymentCardCreateModel.cardType = .mastercard
        paymentCardCreateModel.uuid = "aa"
        model = AddPaymentCardViewModel(paymentCard: paymentCardCreateModel, journey: .wallet)
    }
    
    var currentViewController: UIViewController {
        return Current.navigate.currentViewController!
    }
    
    func test_shouldDisplayTermsAndConditions() throws {
        XCTAssertTrue(Self.model.shouldDisplayTermsAndConditions)
    }

    func test_shouldGetCorrectCardType() throws {
        Self.model.setPaymentCardType(.mastercard)
        XCTAssertEqual(Self.model.paymentCardType, .mastercard)
        
        Self.model.setPaymentCardType(.visa)
        XCTAssertEqual(Self.model.paymentCardType, .visa)
        
        Self.model.setPaymentCardType(.amex)
        XCTAssertEqual(Self.model.paymentCardType, .amex)
    }
    
    func test_shouldGetCorrectFullPan() throws {
        Self.model.setPaymentCardFullPan("5454 5454 5454 5454")
        XCTAssertEqual(Self.model.paymentCard.fullPan, "5454 5454 5454 5454")
    }
    
    func test_shouldGetCorrectName() throws {
        Self.model.setPaymentCardName("Rick Morty")
        XCTAssertEqual(Self.model.paymentCard.nameOnCard, "Rick Morty")
    }
    
    func test_shouldGetCorrectExperyDate() throws {
        Self.model.setPaymentCardExpiry(month: 4, year: 2025)
        XCTAssertEqual(Self.model.paymentCard.month, 4)
        XCTAssertEqual(Self.model.paymentCard.year, 2025)
    }
    
    func test_toPaymentTermsAndConditions_shouldNavigate() throws {
        Self.model.toPaymentTermsAndConditions(acceptAction: {}, declineAction: {})
        XCTAssertTrue(currentViewController.isKind(of: ReusableTemplateViewController.self))
    }
    
    func test_toPrivacyAndSecurity_shouldNavigate() throws {
        Self.model.toPrivacyAndSecurity()
        XCTAssertTrue(currentViewController.isKind(of: UIHostingController<ReusableTemplateView>.self))
    }
    
    func test_alertError_shouldNavigate() throws {
        Self.model.displayError()
        XCTAssertTrue(currentViewController.isKind(of: BinkAlertController.self))
    }
}
