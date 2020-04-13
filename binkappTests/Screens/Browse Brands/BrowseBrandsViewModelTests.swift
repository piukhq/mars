//
//  BrowseBrandsViewModelTests.swift
//  binkappTests
//
//  Created by Paul Tiriteu on 10/04/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import XCTest
@testable import binkapp

class BrowseBrandsViewModelTests: XCTestCase {
    private var viewModel: BrowseBrandsViewModelMock!
    
    override func setUp() {
        let plans = [
            MembershipPlanModel(apiId: nil, status: nil, featureSet: FeatureSetModel(apiId: nil, authorisationRequired: nil, transactionsAvailable: nil, digitalOnly: nil, hasPoints: nil, cardType: .link, linkingSupport: nil, hasVouchers: nil), images: nil, account: nil, balances: nil, dynamicContent: nil, hasVouchers: nil),
            MembershipPlanModel(apiId: nil, status: nil, featureSet: FeatureSetModel(apiId: nil, authorisationRequired: nil, transactionsAvailable: nil, digitalOnly: nil, hasPoints: nil, cardType: .store, linkingSupport: nil, hasVouchers: nil), images: nil, account: nil, balances: nil, dynamicContent: nil, hasVouchers: nil)
        ]
        viewModel = BrowseBrandsViewModelMock(membershipPlans: plans)
    }
    
    func test_shouldShowNoResultsLabel_true() {
        viewModel.filteredPlans = []
        XCTAssertTrue(viewModel.shouldShowNoResultsLabel)
    }
    
    func test_shouldShowNoResultsLabel_false() {
        viewModel.filteredPlans = [CD_MembershipPlan()]
        XCTAssertFalse(viewModel.shouldShowNoResultsLabel)
    }
    
    func test_getSectionTitleText() {
        if viewModel.getMembershipPlans().isEmpty {
            XCTAssertEqual(viewModel.getSectionTitleText(section: 0), "All")
            XCTAssertEqual(viewModel.getSectionTitleText(section: 1), "All")
        } else {
            XCTAssertEqual(viewModel.getSectionTitleText(section: 0), "Payment Linked Loyalty")
            XCTAssertEqual(viewModel.getSectionTitleText(section: 1), "All")
        }
    }
    
    func test_hasMembershipPlans() {
        if viewModel.getMembershipPlans().isEmpty {
            XCTAssertFalse(viewModel.hasMembershipPlans())
        } else {
            XCTAssertTrue(viewModel.hasMembershipPlans())
        }
    }
    
    func test_getPllMembershipPlans() {
        XCTAssertEqual(viewModel.getPllMembershipPlans().count, 1)
    }
    
    func test_getNonPllMembershipPlans() {
        XCTAssertEqual(viewModel.getNonPllMembershipPlans().count, 1)
    }
}
