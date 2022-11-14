//
//  BrowseBrandsViewControllerTests.swift
//  binkappTests
//
//  Created by Ricardo Silva on 14/11/2022.
//  Copyright © 2022 Bink. All rights reserved.
//

import XCTest
@testable import binkapp

// swiftlint:disable all

final class BrowseBrandsViewControllerTests: XCTestCase, CoreDataTestable {
    static var baseMembershipPlanResponse: [MembershipPlanModel]!
    
    static var membershipPlans: [CD_MembershipPlan]!
    
    static let model = BrowseBrandsViewModel()
    
    static var sut: BrowseBrandsViewController!
    
    override class func setUp() {
        let membershipPlanModels: [MembershipPlanModel] = [
            MembershipPlanModel(apiId: 0, status: nil, featureSet: FeatureSetModel(apiId: nil, authorisationRequired: nil, transactionsAvailable: nil, digitalOnly: nil, hasPoints: nil, cardType: .link, linkingSupport: [.add], hasVouchers: nil), images: nil, account: MembershipPlanAccountModel(apiId: nil, planName: nil, planNameCard: nil, planURL: nil, companyName: "FirstCard", category: "household", planSummary: nil, planDescription: nil, barcodeRedeemInstructions: nil, planRegisterInfo: nil, companyURL: nil, enrolIncentive: nil, forgottenPasswordUrl: nil, tiers: nil, planDocuments: nil, addFields: nil, authoriseFields: nil, registrationFields: nil, enrolFields: nil), balances: nil, dynamicContent: nil, hasVouchers: nil, card: nil),
            MembershipPlanModel(apiId: 230, status: nil, featureSet: FeatureSetModel(apiId: nil, authorisationRequired: nil, transactionsAvailable: nil, digitalOnly: nil, hasPoints: nil, cardType: .view, linkingSupport: [.add], hasVouchers: nil), images: nil, account: MembershipPlanAccountModel(apiId: nil, planName: nil, planNameCard: nil, planURL: nil, companyName: "SecondCard", category: "travel", planSummary: nil, planDescription: nil, barcodeRedeemInstructions: nil, planRegisterInfo: nil, companyURL: nil, enrolIncentive: nil, forgottenPasswordUrl: nil, tiers: nil, planDocuments: nil, addFields: nil, authoriseFields: nil, registrationFields: nil, enrolFields: nil), balances: nil, dynamicContent: nil, hasVouchers: nil, card: nil),
            MembershipPlanModel(apiId: 2, status: nil, featureSet: FeatureSetModel(apiId: nil, authorisationRequired: nil, transactionsAvailable: nil, digitalOnly: nil, hasPoints: nil, cardType: .store, linkingSupport: [.add], hasVouchers: nil), images: nil, account: MembershipPlanAccountModel(apiId: nil, planName: nil, planNameCard: nil, planURL: nil, companyName: "ThirdCard", category: "food", planSummary: nil, planDescription: nil, barcodeRedeemInstructions: nil, planRegisterInfo: nil, companyURL: nil, enrolIncentive: nil, forgottenPasswordUrl: nil, tiers: nil, planDocuments: nil, addFields: nil, authoriseFields: nil, registrationFields: nil, enrolFields: nil), balances: nil, dynamicContent: nil, hasVouchers: nil, card: nil)
        ]

        baseMembershipPlanResponse = membershipPlanModels

        mapResponsesToManagedObjects(baseMembershipPlanResponse, managedObjectType: CD_MembershipPlan.self) { membershipPlans in
            self.membershipPlans = membershipPlans
        }
        
        sut = BrowseBrandsViewController(viewModel: model, section: 0)
        sut.viewDidLoad()
        sut.viewWillAppear(false)
        sut.viewDidAppear(false)
        sut.viewDidLayoutSubviews()
    }

    func test_configuredCorrectly() throws {
        XCTAssertEqual(Self.sut.title, "Browse brands")
        
        XCTAssertEqual(Self.sut.noMatchesLabel.font, UIFont.bodyTextLarge)
        XCTAssertEqual(Self.sut.noMatchesLabel.text, "No matches")
        
        XCTAssertEqual(Self.sut.searchTextField.font, .textFieldInput)
        XCTAssertEqual(Self.sut.searchTextField.placeholder, "Search")
        XCTAssertEqual(Self.sut.searchTextField.textColor, .greyFifty)
        
        XCTAssertNotNil(Self.sut.searchTextField.leftView)
    }
    
    func test_filters() throws {
        Self.sut.filtersButtonTapped()
        
        XCTAssertTrue(Self.sut.areFiltersVisible())
        
        Self.sut.filtersButtonTapped()
        
        XCTAssertTrue(!Self.sut.areFiltersVisible())
        
        Self.sut.filtersButtonTapped()
    }
    
    func test_searchTextField_textHandledCorrecty() throws {
        Self.sut.searchTextField.text = "test"
        var complete = Self.sut.textField(Self.sut.searchTextField, shouldChangeCharactersIn: NSRange(location: 0, length: Self.sut.searchTextField.text!.count - 1), replacementString: "s")
        XCTAssertTrue(complete)
        XCTAssertEqual(Self.sut.viewModel.searchText, "tests")
        
        complete = Self.sut.textField(Self.sut.searchTextField, shouldChangeCharactersIn: NSRange(location: 0, length: Self.sut.searchTextField.text!.count - 1), replacementString: "")
        
        XCTAssertEqual(Self.sut.viewModel.searchText, "tes")
        
        complete = Self.sut.textFieldShouldClear(Self.sut.searchTextField)
        XCTAssertEqual(Self.sut.viewModel.searchText, "")
        
        complete = Self.sut.textFieldShouldReturn(Self.sut.searchTextField)
        XCTAssertTrue(complete)
    }
    
    func test_collectionView_hasCorrectCount() throws {
        let count = Self.sut.collectionView(Self.sut.collectionView, numberOfItemsInSection: 0)
        
        XCTAssertEqual(count, 4)
    }
    
    func test_collectionView_getsValidCell() throws {
        let cell = Self.sut.collectionView(Self.sut.collectionView, cellForItemAt: IndexPath(row: 0, section: 0))
        
        XCTAssertNotNil(cell)
    }

}
