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
            MembershipPlanModel(apiId: 1, status: nil, featureSet: FeatureSetModel(apiId: nil, authorisationRequired: nil, transactionsAvailable: nil, digitalOnly: nil, hasPoints: nil, cardType: .store, linkingSupport: nil, hasVouchers: nil), images: nil, account: MembershipPlanAccountModel(apiId: nil, planName: nil, planNameCard: nil, planURL: nil, companyName: "SecondCard", category: "food", planSummary: nil, planDescription: nil, barcodeRedeemInstructions: nil, planRegisterInfo: nil, companyURL: nil, enrolIncentive: nil, forgottenPasswordUrl: nil, tiers: nil, planDocuments: nil, addFields: nil, authoriseFields: nil, registrationFields: nil, enrolFields: nil), balances: nil, dynamicContent: nil, hasVouchers: nil, card: nil)
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

    func test_filters_returnsMappedFiltersCorrectly() {
        XCTAssertEqual(Self.sut.filters, ["household", "food"])
    }

    func test_getMembershipPlan_section_0() {
        var indexPath = IndexPath(row: 0, section: 0)
        XCTAssertEqual(Self.sut.getMembershipPlan(for: indexPath), Self.membershipPlans.first)
        indexPath = IndexPath(row: 0, section: 1)
        XCTAssertEqual(Self.sut.getMembershipPlan(for: indexPath), Self.membershipPlans[1])
    }

    func test_getSectionTitleText() {
        XCTAssertEqual(Self.sut.getSectionTitleText(section: 0), "Payment Linked Loyalty")
        XCTAssertEqual(Self.sut.getSectionTitleText(section: 1), "All")
    }

    func test_hasMembershipPlans_true() {
        let membershipPlanModels: [MembershipPlanModel] = [
            MembershipPlanModel(apiId: 0, status: nil, featureSet: FeatureSetModel(apiId: nil, authorisationRequired: nil, transactionsAvailable: nil, digitalOnly: nil, hasPoints: nil, cardType: .link, linkingSupport: nil, hasVouchers: nil), images: nil, account: MembershipPlanAccountModel(apiId: nil, planName: nil, planNameCard: nil, planURL: nil, companyName: "FirstCard", category: "household", planSummary: nil, planDescription: nil, barcodeRedeemInstructions: nil, planRegisterInfo: nil, companyURL: nil, enrolIncentive: nil, forgottenPasswordUrl: nil, tiers: nil, planDocuments: nil, addFields: nil, authoriseFields: nil, registrationFields: nil, enrolFields: nil), balances: nil, dynamicContent: nil, hasVouchers: nil, card: nil),
            MembershipPlanModel(apiId: 1, status: nil, featureSet: FeatureSetModel(apiId: nil, authorisationRequired: nil, transactionsAvailable: nil, digitalOnly: nil, hasPoints: nil, cardType: .store, linkingSupport: nil, hasVouchers: nil), images: nil, account: MembershipPlanAccountModel(apiId: nil, planName: nil, planNameCard: nil, planURL: nil, companyName: "SecondCard", category: "food", planSummary: nil, planDescription: nil, barcodeRedeemInstructions: nil, planRegisterInfo: nil, companyURL: nil, enrolIncentive: nil, forgottenPasswordUrl: nil, tiers: nil, planDocuments: nil, addFields: nil, authoriseFields: nil, registrationFields: nil, enrolFields: nil), balances: nil, dynamicContent: nil, hasVouchers: nil, card: nil)
        ]

        mapPlansToManagedObjects(membershipPlanModels)
        XCTAssertTrue(Self.sut.hasMembershipPlans())
    }

    func test_hasMembershipPlans_false() {
        let membershipPlanModels: [MembershipPlanModel] = [
            MembershipPlanModel(apiId: 0, status: nil, featureSet: FeatureSetModel(apiId: nil, authorisationRequired: nil, transactionsAvailable: nil, digitalOnly: nil, hasPoints: nil, cardType: nil, linkingSupport: nil, hasVouchers: nil), images: nil, account: MembershipPlanAccountModel(apiId: nil, planName: nil, planNameCard: nil, planURL: nil, companyName: "FirstCard", category: "household", planSummary: nil, planDescription: nil, barcodeRedeemInstructions: nil, planRegisterInfo: nil, companyURL: nil, enrolIncentive: nil, forgottenPasswordUrl: nil, tiers: nil, planDocuments: nil, addFields: nil, authoriseFields: nil, registrationFields: nil, enrolFields: nil), balances: nil, dynamicContent: nil, hasVouchers: nil, card: nil),
            MembershipPlanModel(apiId: 1, status: nil, featureSet: FeatureSetModel(apiId: nil, authorisationRequired: nil, transactionsAvailable: nil, digitalOnly: nil, hasPoints: nil, cardType: nil, linkingSupport: nil, hasVouchers: nil), images: nil, account: MembershipPlanAccountModel(apiId: nil, planName: nil, planNameCard: nil, planURL: nil, companyName: "SecondCard", category: "food", planSummary: nil, planDescription: nil, barcodeRedeemInstructions: nil, planRegisterInfo: nil, companyURL: nil, enrolIncentive: nil, forgottenPasswordUrl: nil, tiers: nil, planDocuments: nil, addFields: nil, authoriseFields: nil, registrationFields: nil, enrolFields: nil), balances: nil, dynamicContent: nil, hasVouchers: nil, card: nil)
        ]
        
        mapPlansToManagedObjects(membershipPlanModels)
        XCTAssertFalse(Self.sut.hasMembershipPlans())
    }

    func test_hasPlansForOneSection_true() {
        let membershipPlanModels: [MembershipPlanModel] = [
            MembershipPlanModel(apiId: 0, status: nil, featureSet: FeatureSetModel(apiId: nil, authorisationRequired: nil, transactionsAvailable: nil, digitalOnly: nil, hasPoints: nil, cardType: .link, linkingSupport: nil, hasVouchers: nil), images: nil, account: MembershipPlanAccountModel(apiId: nil, planName: nil, planNameCard: nil, planURL: nil, companyName: "FirstCard", category: "household", planSummary: nil, planDescription: nil, barcodeRedeemInstructions: nil, planRegisterInfo: nil, companyURL: nil, enrolIncentive: nil, forgottenPasswordUrl: nil, tiers: nil, planDocuments: nil, addFields: nil, authoriseFields: nil, registrationFields: nil, enrolFields: nil), balances: nil, dynamicContent: nil, hasVouchers: nil, card: nil),
            MembershipPlanModel(apiId: 1, status: nil, featureSet: FeatureSetModel(apiId: nil, authorisationRequired: nil, transactionsAvailable: nil, digitalOnly: nil, hasPoints: nil, cardType: .link, linkingSupport: nil, hasVouchers: nil), images: nil, account: MembershipPlanAccountModel(apiId: nil, planName: nil, planNameCard: nil, planURL: nil, companyName: "SecondCard", category: "food", planSummary: nil, planDescription: nil, barcodeRedeemInstructions: nil, planRegisterInfo: nil, companyURL: nil, enrolIncentive: nil, forgottenPasswordUrl: nil, tiers: nil, planDocuments: nil, addFields: nil, authoriseFields: nil, registrationFields: nil, enrolFields: nil), balances: nil, dynamicContent: nil, hasVouchers: nil, card: nil)
        ]
        
        mapPlansToManagedObjects(membershipPlanModels)
        XCTAssertTrue(Self.sut.hasPlansForOneSection())
    }

    func test_hasPlansForOneSection_false() {
        let membershipPlanModels: [MembershipPlanModel] = [
            MembershipPlanModel(apiId: 0, status: nil, featureSet: FeatureSetModel(apiId: nil, authorisationRequired: nil, transactionsAvailable: nil, digitalOnly: nil, hasPoints: nil, cardType: .link, linkingSupport: nil, hasVouchers: nil), images: nil, account: MembershipPlanAccountModel(apiId: nil, planName: nil, planNameCard: nil, planURL: nil, companyName: "FirstCard", category: "household", planSummary: nil, planDescription: nil, barcodeRedeemInstructions: nil, planRegisterInfo: nil, companyURL: nil, enrolIncentive: nil, forgottenPasswordUrl: nil, tiers: nil, planDocuments: nil, addFields: nil, authoriseFields: nil, registrationFields: nil, enrolFields: nil), balances: nil, dynamicContent: nil, hasVouchers: nil, card: nil),
            MembershipPlanModel(apiId: 1, status: nil, featureSet: FeatureSetModel(apiId: nil, authorisationRequired: nil, transactionsAvailable: nil, digitalOnly: nil, hasPoints: nil, cardType: nil, linkingSupport: nil, hasVouchers: nil), images: nil, account: MembershipPlanAccountModel(apiId: nil, planName: nil, planNameCard: nil, planURL: nil, companyName: "SecondCard", category: "food", planSummary: nil, planDescription: nil, barcodeRedeemInstructions: nil, planRegisterInfo: nil, companyURL: nil, enrolIncentive: nil, forgottenPasswordUrl: nil, tiers: nil, planDocuments: nil, addFields: nil, authoriseFields: nil, registrationFields: nil, enrolFields: nil), balances: nil, dynamicContent: nil, hasVouchers: nil, card: nil)
        ]
        
        mapPlansToManagedObjects(membershipPlanModels)
        XCTAssertFalse(Self.sut.hasPlansForOneSection())
    }

    func test_getPllMembershipPlans() {
        XCTAssertEqual(Self.sut.getPllMembershipPlans().count, 1)
    }

    func test_getNonPllMembershipPlans() {
        XCTAssertEqual(Self.sut.getNonPllMembershipPlans().count, 1)
    }

    func test_numberOfSections() {
        let membershipPlanModels: [MembershipPlanModel] = [
            MembershipPlanModel(apiId: 0, status: nil, featureSet: FeatureSetModel(apiId: nil, authorisationRequired: nil, transactionsAvailable: nil, digitalOnly: nil, hasPoints: nil, cardType: .link, linkingSupport: nil, hasVouchers: nil), images: nil, account: MembershipPlanAccountModel(apiId: nil, planName: nil, planNameCard: nil, planURL: nil, companyName: "FirstCard", category: "household", planSummary: nil, planDescription: nil, barcodeRedeemInstructions: nil, planRegisterInfo: nil, companyURL: nil, enrolIncentive: nil, forgottenPasswordUrl: nil, tiers: nil, planDocuments: nil, addFields: nil, authoriseFields: nil, registrationFields: nil, enrolFields: nil), balances: nil, dynamicContent: nil, hasVouchers: nil, card: nil),
            MembershipPlanModel(apiId: 1, status: nil, featureSet: FeatureSetModel(apiId: nil, authorisationRequired: nil, transactionsAvailable: nil, digitalOnly: nil, hasPoints: nil, cardType: .store, linkingSupport: nil, hasVouchers: nil), images: nil, account: MembershipPlanAccountModel(apiId: nil, planName: nil, planNameCard: nil, planURL: nil, companyName: "SecondCard", category: "food", planSummary: nil, planDescription: nil, barcodeRedeemInstructions: nil, planRegisterInfo: nil, companyURL: nil, enrolIncentive: nil, forgottenPasswordUrl: nil, tiers: nil, planDocuments: nil, addFields: nil, authoriseFields: nil, registrationFields: nil, enrolFields: nil), balances: nil, dynamicContent: nil, hasVouchers: nil, card: nil)
        ]

        mapPlansToManagedObjects(membershipPlanModels)
        XCTAssertEqual(Self.sut.numberOfSections(), 2)
    }

    func test_searchText() {
        Self.sut.searchText = "First"
        Self.sut.selectedFilters = ["household"]
        XCTAssertEqual(Self.sut.filteredPlans.count, 1)
    }

    func test_getNumberOfRowsForSection_0() {
        XCTAssertEqual(Self.sut.getNumberOfRowsFor(section: 0), 1)
    }

    func test_getNumberOfRowsForSection_1() {
        XCTAssertEqual(Self.sut.getNumberOfRowsFor(section: 1), 1)
    }
}
