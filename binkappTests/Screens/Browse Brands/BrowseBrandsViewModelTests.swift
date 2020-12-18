//
//  BrowseBrandsViewModelTests.swift
//  binkappTests
//
//  Created by Paul Tiriteu on 10/04/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import XCTest
@testable import binkapp

class BrowseBrandsViewModelTests: XCTestCase, CoreDataTestable {
    static var baseMembershipPlanResponse: [MembershipPlanModel]!
    
    static var membershipPlans: [CD_MembershipPlan]!
    
    static let sut = BrowseBrandsViewModel()
    
    override class func setUp() {
        let membershipPlanModels = [
            MembershipPlanModel(apiId: nil, status: nil, featureSet: FeatureSetModel(apiId: nil, authorisationRequired: nil, transactionsAvailable: nil, digitalOnly: nil, hasPoints: nil, cardType: .link, linkingSupport: nil, hasVouchers: nil), images: nil, account: MembershipPlanAccountModel(apiId: nil, planName: nil, planNameCard: nil, planURL: nil, companyName: "FirstCard", category: "household", planSummary: nil, planDescription: nil, barcodeRedeemInstructions: nil, planRegisterInfo: nil, companyURL: nil, enrolIncentive: nil, forgottenPasswordUrl: nil, tiers: nil, planDocuments: nil, addFields: nil, authoriseFields: nil, registrationFields: nil, enrolFields: nil), balances: nil, dynamicContent: nil, hasVouchers: nil, card: nil),
            MembershipPlanModel(apiId: nil, status: nil, featureSet: FeatureSetModel(apiId: nil, authorisationRequired: nil, transactionsAvailable: nil, digitalOnly: nil, hasPoints: nil, cardType: .store, linkingSupport: nil, hasVouchers: nil), images: nil, account: MembershipPlanAccountModel(apiId: nil, planName: nil, planNameCard: nil, planURL: nil, companyName: "SecondCard", category: "food", planSummary: nil, planDescription: nil, barcodeRedeemInstructions: nil, planRegisterInfo: nil, companyURL: nil, enrolIncentive: nil, forgottenPasswordUrl: nil, tiers: nil, planDocuments: nil, addFields: nil, authoriseFields: nil, registrationFields: nil, enrolFields: nil), balances: nil, dynamicContent: nil, hasVouchers: nil, card: nil)
        ]

        baseMembershipPlanResponse = membershipPlanModels
//
//        mapResponsesToManagedObjects(baseMembershipPlanResponse, managedObjectType: CD_MembershipPlan.self) { membershipPlans in
//            print(membershipPlans.count)
//        }
    }

    func test_shouldShowNoResultsLabel_true() {
        // Need to delete persisted plans
        
        let sut = BrowseBrandsViewModel()
        XCTAssertTrue(sut.shouldShowNoResultsLabel)
    }
    
    func test_shouldShowNoResultsLabel_false() {
        mapResponsesToManagedObjects(Self.baseMembershipPlanResponse, managedObjectType: CD_MembershipPlan.self) { membershipPlans in
            print(membershipPlans.count)
        }
        XCTAssertFalse(Self.sut.shouldShowNoResultsLabel)
    }

//    func test_filters_returnsMappedFiltersCorrectly() {
//        let sut = BrowseBrandsViewModelMock(membershipPlans: baseMembershipPlanResponse)
//        XCTAssertEqual(sut.filters, ["household", "food"])
//    }
//
//    func test_getMembershipPlan_section_0() {
//        let sut = BrowseBrandsViewModelMock(membershipPlans: baseMembershipPlanResponse)
//        var indexPath = IndexPath(row: 0, section: 0)
//        XCTAssertEqual(sut.getMembershipPlan(for: indexPath), baseMembershipPlanResponse.first)
//        indexPath = IndexPath(row: 0, section: 1)
//        XCTAssertEqual(sut.getMembershipPlan(for: indexPath), baseMembershipPlanResponse[1])
//    }
//
//    func test_getSectionTitleText() {
//        let sut = BrowseBrandsViewModelMock(membershipPlans: baseMembershipPlanResponse)
//        XCTAssertEqual(sut.getSectionTitleText(section: 0), "Payment Linked Loyalty")
//        XCTAssertEqual(sut.getSectionTitleText(section: 1), "All")
//    }
//
//    func test_hasMembershipPlans_true() {
//        let sut = BrowseBrandsViewModelMock(membershipPlans: baseMembershipPlanResponse)
//        XCTAssertTrue(sut.hasMembershipPlans())
//    }
//
//    func test_hasMembershipPlans_false() {
//        let sut = BrowseBrandsViewModelMock(membershipPlans: [])
//        XCTAssertFalse(sut.hasMembershipPlans())
//    }
//
//    func test_hasPlansForOneSection_true() {
//        baseMembershipPlanResponse.removeLast()
//        let sut = BrowseBrandsViewModelMock(membershipPlans: baseMembershipPlanResponse)
//        XCTAssertTrue(sut.hasPlansForOneSection())
//    }
//
//    func test_hasPlansForOneSection_false() {
//        let sut = BrowseBrandsViewModelMock(membershipPlans: baseMembershipPlanResponse)
//        XCTAssertFalse(sut.hasPlansForOneSection())
//    }
//
//    func test_getPllMembershipPlans() {
//        let sut = BrowseBrandsViewModelMock(membershipPlans: baseMembershipPlanResponse)
//        XCTAssertEqual(sut.getPllMembershipPlans().count, 1)
//    }
//
//    func test_getNonPllMembershipPlans() {
//        let sut = BrowseBrandsViewModelMock(membershipPlans: baseMembershipPlanResponse)
//        XCTAssertEqual(sut.getNonPllMembershipPlans().count, 1)
//    }
//
//    func test_numberOfSections() {
//        let sut = BrowseBrandsViewModelMock(membershipPlans: baseMembershipPlanResponse)
//        XCTAssertEqual(sut.numberOfSections(), 2)
//    }
//
//    func test_searchText() {
//        let sut = BrowseBrandsViewModelMock(membershipPlans: baseMembershipPlanResponse)
//        sut.searchText = "First"
//        sut.selectedFilters = ["household"]
//        XCTAssertEqual(sut.filteredPlans.count, 1)
//    }
//
//    func test_getNumberOfRowsForSection_0() {
//        let sut = BrowseBrandsViewModelMock(membershipPlans: baseMembershipPlanResponse)
//        XCTAssertEqual(sut.getNumberOfRowsFor(section: 0), 1)
//    }
//
//    func test_getNumberOfRowsForSection_1() {
//        let sut = BrowseBrandsViewModelMock(membershipPlans: baseMembershipPlanResponse)
//        XCTAssertEqual(sut.getNumberOfRowsFor(section: 1), 1)
//    }
}
