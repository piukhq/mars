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
    private var plans: [MembershipPlanModel]! {
        didSet {
            viewModel = BrowseBrandsViewModelMock(membershipPlans: plans)
        }
    }
    
    override func setUp() {
        plans = [
            MembershipPlanModel(apiId: nil, status: nil, featureSet: FeatureSetModel(apiId: nil, authorisationRequired: nil, transactionsAvailable: nil, digitalOnly: nil, hasPoints: nil, cardType: .link, linkingSupport: nil, hasVouchers: nil), images: nil, account: MembershipPlanAccountModel(apiId: nil, planName: nil, planNameCard: nil, planURL: nil, companyName: "FirstCard", category: "household", planSummary: nil, planDescription: nil, barcodeRedeemInstructions: nil, planRegisterInfo: nil, companyURL: nil, enrolIncentive: nil, forgottenPasswordUrl: nil, tiers: nil, planDocuments: nil, addFields: nil, authoriseFields: nil, registrationFields: nil, enrolFields: nil), balances: nil, dynamicContent: nil, hasVouchers: nil),
            MembershipPlanModel(apiId: nil, status: nil, featureSet: FeatureSetModel(apiId: nil, authorisationRequired: nil, transactionsAvailable: nil, digitalOnly: nil, hasPoints: nil, cardType: .store, linkingSupport: nil, hasVouchers: nil), images: nil, account: MembershipPlanAccountModel(apiId: nil, planName: nil, planNameCard: nil, planURL: nil, companyName: "SecondCard", category: "food", planSummary: nil, planDescription: nil, barcodeRedeemInstructions: nil, planRegisterInfo: nil, companyURL: nil, enrolIncentive: nil, forgottenPasswordUrl: nil, tiers: nil, planDocuments: nil, addFields: nil, authoriseFields: nil, registrationFields: nil, enrolFields: nil), balances: nil, dynamicContent: nil, hasVouchers: nil)
        ]
    }
    
    func test_shouldShowNoResultsLabel_true() {
        viewModel.filteredPlans = []
        XCTAssertTrue(viewModel.shouldShowNoResultsLabel)
    }
    
    func test_shouldShowNoResultsLabel_false() {
        viewModel.filteredPlans = plans
        XCTAssertFalse(viewModel.shouldShowNoResultsLabel)
    }
    
    func test_filters() {
        XCTAssertEqual(viewModel.filters, ["household", "food"])
    }
    
    func test_getMembershipPlan_section_0() {
        var indexPath = IndexPath(row: 0, section: 0)
        XCTAssertEqual(viewModel.getMembershipPlan(for: indexPath), plans.first)
        indexPath = IndexPath(row: 0, section: 1)
        XCTAssertEqual(viewModel.getMembershipPlan(for: indexPath), plans[1])
    }
    
    func test_getSectionTitleText() {
        XCTAssertEqual(viewModel.getSectionTitleText(section: 0), "Payment Linked Loyalty")
        XCTAssertEqual(viewModel.getSectionTitleText(section: 1), "All")
    }
    
    func test_hasMembershipPlans_true() {
        XCTAssertTrue(viewModel.hasMembershipPlans())
    }
    
    func test_hasMembershipPlans_false() {
        plans = []
        XCTAssertFalse(viewModel.hasMembershipPlans())
    }
    
    func test_hasPlansForOneSection_true() {
        plans.removeLast()
        XCTAssertTrue(viewModel.hasPlansForOneSection())
    }
    
    func test_hasPlansForOneSection_false() {
        XCTAssertFalse(viewModel.hasPlansForOneSection())
    }
    
    func test_getPllMembershipPlans() {
        XCTAssertEqual(viewModel.getPllMembershipPlans().count, 1)
    }

    func test_getNonPllMembershipPlans() {
        XCTAssertEqual(viewModel.getNonPllMembershipPlans().count, 1)
    }
    
    func test_numberOfSections() {
        XCTAssertEqual(viewModel.numberOfSections(), 2)
    }
   
    func test_searchText() {
        viewModel.searchText = "First"
        viewModel.selectedFilters = ["household"]
        XCTAssertEqual(viewModel.filteredPlans.count, 1)
    }
    
    func test_getNumberOfRowsForSection_0() {
        XCTAssertEqual(viewModel.getNumberOfRowsFor(section: 0), 1)
    }
    
    func test_getNumberOfRowsForSection_1() {
        XCTAssertEqual(viewModel.getNumberOfRowsFor(section: 1), 1)
    }
}
