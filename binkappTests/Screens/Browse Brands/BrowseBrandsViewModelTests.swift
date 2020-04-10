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
    private var repository: BrowseBrandsRepository!
    private var router: MainScreenRouter!
    private var viewModel: BrowseBrandsViewModel!
    private var apiManager: ApiManager!
    
    override func setUp() {
        apiManager = ApiManager()
        repository = BrowseBrandsRepository(apiManager: apiManager)
        router = MainScreenRouter(delegate: self)
        viewModel = BrowseBrandsViewModel(repository: repository, router: router)
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
        }
    }
}

extension BrowseBrandsViewModelTests: MainScreenRouterDelegate {
    func router(_ router: MainScreenRouter, didLogin: Bool) {}
}
