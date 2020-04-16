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
    private var plans: [MembershipPlanModel]!
    
    override func setUp() {
        plans = [
            MembershipPlanModel(apiId: nil, status: nil, featureSet: FeatureSetModel(apiId: nil, authorisationRequired: nil, transactionsAvailable: nil, digitalOnly: nil, hasPoints: nil, cardType: .link, linkingSupport: nil, hasVouchers: nil), images: nil, account: MembershipPlanAccountModel(apiId: nil, planName: nil, planNameCard: nil, planURL: nil, companyName: "FirstCard", category: "household", planSummary: nil, planDescription: nil, barcodeRedeemInstructions: nil, planRegisterInfo: nil, companyURL: nil, enrolIncentive: nil, forgottenPasswordUrl: nil, tiers: nil, planDocuments: nil, addFields: nil, authoriseFields: nil, registrationFields: nil, enrolFields: nil), balances: nil, dynamicContent: nil, hasVouchers: nil),
            MembershipPlanModel(apiId: nil, status: nil, featureSet: FeatureSetModel(apiId: nil, authorisationRequired: nil, transactionsAvailable: nil, digitalOnly: nil, hasPoints: nil, cardType: .store, linkingSupport: nil, hasVouchers: nil), images: nil, account: MembershipPlanAccountModel(apiId: nil, planName: nil, planNameCard: nil, planURL: nil, companyName: "SecondCard", category: "food", planSummary: nil, planDescription: nil, barcodeRedeemInstructions: nil, planRegisterInfo: nil, companyURL: nil, enrolIncentive: nil, forgottenPasswordUrl: nil, tiers: nil, planDocuments: nil, addFields: nil, authoriseFields: nil, registrationFields: nil, enrolFields: nil), balances: nil, dynamicContent: nil, hasVouchers: nil)
        ]
    }
    
    func test_shouldShowNoResultsLabel_true() {
        let sut = BrowseBrandsViewModelMock(membershipPlans: [])
        XCTAssertTrue(sut.shouldShowNoResultsLabel)
    }
    
    func test_shouldShowNoResultsLabel_false() {
        let sut = BrowseBrandsViewModelMock(membershipPlans: plans)
        sut.filteredPlans = plans
        XCTAssertFalse(sut.shouldShowNoResultsLabel)
    }
    
    func test_filters_returnsMappedFiltersCorrectly() {
        let sut = BrowseBrandsViewModelMock(membershipPlans: plans)
        XCTAssertEqual(sut.filters, ["household", "food"])
    }
    
    func test_getMembershipPlan_section_0() {
        let sut = BrowseBrandsViewModelMock(membershipPlans: plans)
        var indexPath = IndexPath(row: 0, section: 0)
        XCTAssertEqual(sut.getMembershipPlan(for: indexPath), plans.first)
        indexPath = IndexPath(row: 0, section: 1)
        XCTAssertEqual(sut.getMembershipPlan(for: indexPath), plans[1])
    }
    
    func test_getSectionTitleText() {
        let sut = BrowseBrandsViewModelMock(membershipPlans: plans)
        XCTAssertEqual(sut.getSectionTitleText(section: 0), "Payment Linked Loyalty")
        XCTAssertEqual(sut.getSectionTitleText(section: 1), "All")
    }
    
    func test_hasMembershipPlans_true() {
        let sut = BrowseBrandsViewModelMock(membershipPlans: plans)
        XCTAssertTrue(sut.hasMembershipPlans())
    }
    
    func test_hasMembershipPlans_false() {
        let sut = BrowseBrandsViewModelMock(membershipPlans: [])
        XCTAssertFalse(sut.hasMembershipPlans())
    }
    
    func test_hasPlansForOneSection_true() {
        plans.removeLast()
        let sut = BrowseBrandsViewModelMock(membershipPlans: plans)
        XCTAssertTrue(sut.hasPlansForOneSection())
    }
    
    func test_hasPlansForOneSection_false() {
        let sut = BrowseBrandsViewModelMock(membershipPlans: plans)
        XCTAssertFalse(sut.hasPlansForOneSection())
    }
    
    func test_getPllMembershipPlans() {
        let sut = BrowseBrandsViewModelMock(membershipPlans: plans)
        XCTAssertEqual(sut.getPllMembershipPlans().count, 1)
    }

    func test_getNonPllMembershipPlans() {
        let sut = BrowseBrandsViewModelMock(membershipPlans: plans)
        XCTAssertEqual(sut.getNonPllMembershipPlans().count, 1)
    }
    
    func test_numberOfSections() {
        let sut = BrowseBrandsViewModelMock(membershipPlans: plans)
        XCTAssertEqual(sut.numberOfSections(), 2)
    }
   
    func test_searchText() {
        let sut = BrowseBrandsViewModelMock(membershipPlans: plans)
        sut.searchText = "First"
        sut.selectedFilters = ["household"]
        XCTAssertEqual(sut.filteredPlans.count, 1)
    }
    
    func test_getNumberOfRowsForSection_0() {
        let sut = BrowseBrandsViewModelMock(membershipPlans: plans)
        XCTAssertEqual(sut.getNumberOfRowsFor(section: 0), 1)
    }
    
    func test_getNumberOfRowsForSection_1() {
        let sut = BrowseBrandsViewModelMock(membershipPlans: plans)
        XCTAssertEqual(sut.getNumberOfRowsFor(section: 1), 1)
    }
}
