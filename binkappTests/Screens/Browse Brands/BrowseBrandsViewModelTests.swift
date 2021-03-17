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
        let membershipPlanModels: [MembershipPlanModel] = [
            MembershipPlanModel(apiId: 0, status: nil, featureSet: FeatureSetModel(apiId: nil, authorisationRequired: nil, transactionsAvailable: nil, digitalOnly: nil, hasPoints: nil, cardType: .link, linkingSupport: nil, hasVouchers: nil), images: nil, account: MembershipPlanAccountModel(apiId: nil, planName: nil, planNameCard: nil, planURL: nil, companyName: "FirstCard", category: "household", planSummary: nil, planDescription: nil, barcodeRedeemInstructions: nil, planRegisterInfo: nil, companyURL: nil, enrolIncentive: nil, forgottenPasswordUrl: nil, tiers: nil, planDocuments: nil, addFields: nil, authoriseFields: nil, registrationFields: nil, enrolFields: nil), balances: nil, dynamicContent: nil, hasVouchers: nil, card: nil),
            MembershipPlanModel(apiId: 230, status: nil, featureSet: FeatureSetModel(apiId: nil, authorisationRequired: nil, transactionsAvailable: nil, digitalOnly: nil, hasPoints: nil, cardType: .view, linkingSupport: nil, hasVouchers: nil), images: nil, account: MembershipPlanAccountModel(apiId: nil, planName: nil, planNameCard: nil, planURL: nil, companyName: "SecondCard", category: "travel", planSummary: nil, planDescription: nil, barcodeRedeemInstructions: nil, planRegisterInfo: nil, companyURL: nil, enrolIncentive: nil, forgottenPasswordUrl: nil, tiers: nil, planDocuments: nil, addFields: nil, authoriseFields: nil, registrationFields: nil, enrolFields: nil), balances: nil, dynamicContent: nil, hasVouchers: nil, card: nil),
            MembershipPlanModel(apiId: 2, status: nil, featureSet: FeatureSetModel(apiId: nil, authorisationRequired: nil, transactionsAvailable: nil, digitalOnly: nil, hasPoints: nil, cardType: .store, linkingSupport: nil, hasVouchers: nil), images: nil, account: MembershipPlanAccountModel(apiId: nil, planName: nil, planNameCard: nil, planURL: nil, companyName: "ThirdCard", category: "food", planSummary: nil, planDescription: nil, barcodeRedeemInstructions: nil, planRegisterInfo: nil, companyURL: nil, enrolIncentive: nil, forgottenPasswordUrl: nil, tiers: nil, planDocuments: nil, addFields: nil, authoriseFields: nil, registrationFields: nil, enrolFields: nil), balances: nil, dynamicContent: nil, hasVouchers: nil, card: nil)
        ]

        baseMembershipPlanResponse = membershipPlanModels

        mapResponsesToManagedObjects(baseMembershipPlanResponse, managedObjectType: CD_MembershipPlan.self) { membershipPlans in
            self.membershipPlans = membershipPlans
        }
    }
    
    // MARK: - Helper Methods
    
    func mapPlansToManagedObjects(_ membershipPlanModels: [MembershipPlanModel]) {
        mapResponsesToManagedObjects(membershipPlanModels, managedObjectType: CD_MembershipPlan.self) { membershipPlans in
            Self.membershipPlans = membershipPlans
        }
    }
    

    // MARK: - Tests

    /// TODO: -  Reinstate once we have added functionality to CoreDataTestable which enables the deletion of a particular type fom core data
    
//    func test_shouldShowNoResultsLabel_true() {
////        Self.baseMembershipPlanResponse = []
////        mapResponsesToManagedObjects(Self.baseMembershipPlanResponse, managedObjectType: CD_MembershipPlan.self) { membershipPlans in
////            Self.membershipPlans = membershipPlans
////            print(Self.sut.filteredPlans.count)
////            XCTAssertTrue(Self.sut.shouldShowNoResultsLabel)
////        }
//    }
    
    func test_shouldShowNoResultsLabel_false() {
        XCTAssertFalse(Self.sut.shouldShowNoResultsLabel)
    }

    /// TODO: - Reinstate once we have added functionality to CoreDataTestable which wipes core data clean before each test class runs.
    
//    func test_filters_returnsMappedFiltersCorrectly() {
//        XCTAssertEqual(Self.sut.filters, ["household", "food"])
//    }

    func test_getMembershipPlan_section_0() {
        let indexPath = IndexPath(row: 0, section: 0)
        XCTAssertEqual(Self.sut.getMembershipPlan(for: indexPath), Self.membershipPlans.first)
    }
    
    func test_getMembershipPlan_section_1() {
        let indexPath = IndexPath(row: 0, section: 1)
        XCTAssertEqual(Self.sut.getMembershipPlan(for: indexPath), Self.membershipPlans[1])
    }
    
    // Below tests commented out are failing on bitrise due to remote config
    
//    func test_getMembershipPlan_section_2() {
//        let indexPath = IndexPath(row: 0, section: 2)
//        XCTAssertEqual(Self.sut.getMembershipPlan(for: indexPath), Self.membershipPlans[2])
//    }

    func test_getSectionTitleText() {
        XCTAssertEqual(Self.sut.getSectionTitleText(section: 0), "Link to your Payments Cards")
//        XCTAssertEqual(Self.sut.getSectionTitleText(section: 1), "See your balance")
//        XCTAssertEqual(Self.sut.getSectionTitleText(section: 2), "Store your barcode")
    }

    func test_getSectionDescriptionText() {
        XCTAssertEqual(Self.sut.getSectionDescriptionText(section: 0)?.string, "pll_description".localized)
//        XCTAssertEqual(Self.sut.getSectionDescriptionText(section: 1)?.string, "see_description".localized)
//        XCTAssertEqual(Self.sut.getSectionDescriptionText(section: 2)?.string, "store_description".localized )
    }
    
    func test_getMembershipPlans() {
        XCTAssertEqual(Self.sut.getMembershipPlans().count, 3)
    }

    func test_getPllMembershipPlans() {
        XCTAssertEqual(Self.sut.getPllMembershipPlans().count, 1)
    }

//    func test_getSeeMembershipPlans() {
//        XCTAssertEqual(Self.sut.getSeeMembershipPlans().count, 1)
//    }
    
//    func test_getStoreMembershipPlans() {
//        XCTAssertEqual(Self.sut.getStoreMembershipPlans().count, 1)
//    }

//    func test_numberOfSections() {
//        XCTAssertEqual(Self.sut.numberOfSections(), 3)
//    }

    func test_searchText() {
        Self.sut.searchText = "First"
        Self.sut.selectedFilters = ["household"]
        XCTAssertEqual(Self.sut.filteredPlans.count, 1)
        
        Self.sut.searchText = "Second"
        Self.sut.selectedFilters = ["travel"]
        XCTAssertEqual(Self.sut.filteredPlans.count, 1)
        
        Self.sut.searchText = "Third"
        Self.sut.selectedFilters = ["food"]
        XCTAssertEqual(Self.sut.filteredPlans.count, 1)
    }

    func test_getNumberOfRowsForSection_0() {
        XCTAssertEqual(Self.sut.getNumberOfRowsFor(section: 0), 1)
    }

//    func test_getNumberOfRowsForSection_1() {
//        XCTAssertEqual(Self.sut.getNumberOfRowsFor(section: 1), 1)
//    }
    
//    func test_getNumberOfRowsForSection_2() {
//        XCTAssertEqual(Self.sut.getNumberOfRowsFor(section: 2), 1)
//    }
}
