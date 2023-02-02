//
//  BrowseBrandsListRowViewModelTests.swift
//  binkappTests
//
//  Created by Ricardo Silva on 26/10/2022.
//  Copyright © 2022 Bink. All rights reserved.
//

import XCTest
@testable import binkapp
// swiftlint:disable all

final class BrowseBrandsListRowViewModelTests: XCTestCase, CoreDataTestable {

    static var membershipPlanResponse: MembershipPlanModel!
    static var paymentCardCardResponse: PaymentCardCardResponse!

    static var membershipPlan: CD_MembershipPlan!
    
    static var sut: BrowseBrandsListRowViewModel!
    
    override class func setUp() {
        super.setUp()
        
        let featureSet = FeatureSetModel(apiId: nil, authorisationRequired: nil, transactionsAvailable: nil, digitalOnly: nil, hasPoints: nil, cardType: .link, linkingSupport: [.add], hasVouchers: nil)
        
        membershipPlanResponse = MembershipPlanModel(apiId: 500, status: nil, featureSet: featureSet, images: nil, account: nil, balances: nil, dynamicContent: nil, hasVouchers: nil, card: nil)
        
        mapResponseToManagedObject(membershipPlanResponse, managedObjectType: CD_MembershipPlan.self) { plan in
            self.membershipPlan = plan
        }
        
        sut = BrowseBrandsListRowViewModel(title: "Tesco", plan: membershipPlan, brandExists: true, showSeparator: true, action: {})
    }
    
    func test_propertiesAreCorrect() throws {
        XCTAssertTrue(Self.sut.title == "Tesco")
        XCTAssertTrue(Self.sut.plan == Self.membershipPlan)
        XCTAssertTrue(Self.sut.brandExists)
        XCTAssertTrue(Self.sut.showSeparator)
    }
    
    func test_subtitleIsCorrect() throws {
        XCTAssertTrue(Self.sut.subtitle == "Can be linked to your payment cards")
    }
}
