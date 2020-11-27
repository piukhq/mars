//
//  DynamicActionsTests.swift
//  binkappTests
//
//  Created by Nick Farrant on 27/11/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import XCTest
@testable import binkapp

class DynamicActionsTests: XCTestCase {
    let baseDynamicActionModel = DynamicAction(name: "xmas_2020", type: .xmas, startDate: 1608537600, endDate: 1609056000, locations: [DynamicActionLocation(icon: "U+1F384", screen: .loyaltyWallet, area: .leftTopBar, action: .singleTap), DynamicActionLocation(icon: "U+1F384", screen: .paymentWallet, area: .leftTopBar, action: .singleTap)], event: DynamicActionEvent(type: .launchModal, body: DynamicActionEventBody(title: "Merry Christmas and a Happy New Year", description: "2020 has been a very interesting year to say the least. The Bink mobile squad wanted to take this opportunity to thank you for using the Bink app. Since we launched version 2.0 with an all new team, we've managed to release 12 versions that have added new features, tweaks and bugfixes.  \nWe've got many exciting new features and partnerships planned for 2021, but as always do reach out to us to share what you would want to see. We would love to hear from you!", cta: DynamicActionEventBodyCTA(title: "Contact us", action: .zendeskContactUs))))

    // MARK: - View model tests

    func test_titleString_returnsCorrectly() {
        let sut = DynamicActionViewModel(dynamicAction: baseDynamicActionModel)
        XCTAssertEqual(sut.titleString, "Merry Christmas and a Happy New Year")
    }

    func test_descriptionString_returnsCorrectly() {
        let sut = DynamicActionViewModel(dynamicAction: baseDynamicActionModel)
        XCTAssertEqual(sut.descriptionString, "2020 has been a very interesting year to say the least. The Bink mobile squad wanted to take this opportunity to thank you for using the Bink app. Since we launched version 2.0 with an all new team, we've managed to release 12 versions that have added new features, tweaks and bugfixes.  \nWe've got many exciting new features and partnerships planned for 2021, but as always do reach out to us to share what you would want to see. We would love to hear from you!")
    }

    func test_buttonTitle_returnsCorrectly() {
        let sut = DynamicActionViewModel(dynamicAction: baseDynamicActionModel)
        XCTAssertEqual(sut.buttonTitle, "Contact us")
    }

    func test_headerViewImageName_returnsCorrectly() {
        let sut = DynamicActionViewModel(dynamicAction: baseDynamicActionModel)
        XCTAssertEqual(sut.headerViewImageName, "bink-logo-christmas")
    }

    func test_dynamicActionType_returnsCorrectly() {
        let sut = DynamicActionViewModel(dynamicAction: baseDynamicActionModel)
        XCTAssertEqual(sut.dynamicActionType, DynamicActionType.xmas)
    }

    // MARK: - Model tests

    func test_isActive_returnsCorrectly() {
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())
        let activeModel = DynamicAction(name: nil, type: nil, startDate: yesterday?.timeIntervalSince1970, endDate: tomorrow?.timeIntervalSince1970, locations: nil, event: nil)
        XCTAssertTrue(activeModel.isActive)

        let inactiveModelTomorrow = DynamicAction(name: nil, type: nil, startDate: tomorrow?.timeIntervalSince1970, endDate: tomorrow?.timeIntervalSince1970, locations: nil, event: nil)
        XCTAssertFalse(inactiveModelTomorrow.isActive)

        let inactiveModelYesterday = DynamicAction(name: nil, type: nil, startDate: yesterday?.timeIntervalSince1970, endDate: yesterday?.timeIntervalSince1970, locations: nil, event: nil)
        XCTAssertFalse(inactiveModelYesterday.isActive)
    }

    func test_location_returnsCorrectly() {
        let loyaltyWalletViewController = LoyaltyWalletViewController(viewModel: LoyaltyWalletViewModel())
        XCTAssertNotNil(baseDynamicActionModel.location(for: loyaltyWalletViewController))

        let paymentWalletViewController = PaymentWalletViewController(viewModel: PaymentWalletViewModel())
        XCTAssertNotNil(baseDynamicActionModel.location(for: paymentWalletViewController))

        let otherViewController = BinkViewController()
        XCTAssertNil(baseDynamicActionModel.location(for: otherViewController))
    }

    // MARK: - Utility tests

    func test_availableAction_returnsCorrectly_whenInactive() {
        var utility = DynamicActionsUtilityMock()

        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())

        utility.allActions = [DynamicAction(name: nil, type: nil, startDate: yesterday?.timeIntervalSince1970, endDate: yesterday?.timeIntervalSince1970, locations: [DynamicActionLocation(icon: nil, screen: .loyaltyWallet, area: nil, action: nil), DynamicActionLocation(icon: nil, screen: .paymentWallet, area: nil, action: nil)], event: nil)]

        let loyaltyWalletViewController = LoyaltyWalletViewController(viewModel: LoyaltyWalletViewModel())
        XCTAssertNil(utility.availableAction(for: loyaltyWalletViewController))

        let paymentWalletViewController = PaymentWalletViewController(viewModel: PaymentWalletViewModel())
        XCTAssertNil(utility.availableAction(for: paymentWalletViewController))

        let otherViewController = BinkViewController()
        XCTAssertNil(utility.availableAction(for: otherViewController))
    }

    func test_availableAction_returnsCorrectly_whenActive() {
        var utility = DynamicActionsUtilityMock()

        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())

        utility.allActions = [DynamicAction(name: nil, type: nil, startDate: yesterday?.timeIntervalSince1970, endDate: tomorrow?.timeIntervalSince1970, locations: [DynamicActionLocation(icon: nil, screen: .loyaltyWallet, area: nil, action: nil), DynamicActionLocation(icon: nil, screen: .paymentWallet, area: nil, action: nil)], event: nil)]

        let loyaltyWalletViewController = LoyaltyWalletViewController(viewModel: LoyaltyWalletViewModel())
        XCTAssertNotNil(utility.availableAction(for: loyaltyWalletViewController))

        let paymentWalletViewController = PaymentWalletViewController(viewModel: PaymentWalletViewModel())
        XCTAssertNotNil(utility.availableAction(for: paymentWalletViewController))

        let otherViewController = BinkViewController()
        XCTAssertNil(utility.availableAction(for: otherViewController))
    }
}
