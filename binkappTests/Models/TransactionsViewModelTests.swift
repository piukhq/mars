//
//  TransactionsViewModelTests.swift
//  binkappTests
//
//  Created by Ricardo Silva on 25/10/2022.
//  Copyright © 2022 Bink. All rights reserved.
//

import XCTest
@testable import binkapp
// swiftlint:disable all

final class TransactionsViewModelTests: XCTestCase, CoreDataTestable {

    static var membershipCardResponse: MembershipCardModel!
    static var membershipPlanResponse: MembershipPlanModel!
    static var paymentCardCardResponse: PaymentCardCardResponse!
    static let linkedResponse = LinkedCardResponse(id: 300, activeLink: true)

    static var membershipCard: CD_MembershipCard!
    static var membershipPlan: CD_MembershipPlan!
    
    static var sut = TransactionsViewModel(membershipCard: membershipCard)
    
    override class func setUp() {
        super.setUp()
        
        let featureSet = FeatureSetModel(apiId: nil, authorisationRequired: nil, transactionsAvailable: nil, digitalOnly: nil, hasPoints: nil, cardType: .link, linkingSupport: [.add], hasVouchers: nil)
        
        membershipPlanResponse = MembershipPlanModel(apiId: 500, status: nil, featureSet: featureSet, images: nil, account: nil, balances: nil, dynamicContent: nil, hasVouchers: nil, card: nil, goLive: "")
        
        mapResponseToManagedObject(membershipPlanResponse, managedObjectType: CD_MembershipPlan.self) { plan in
            self.membershipPlan = plan
        }
        
        membershipCardResponse = MembershipCardModel(apiId: 300, membershipPlan: 500, membershipTransactions: nil, status: nil, card: nil, images: nil, account: nil, paymentCards: nil, balances: nil, vouchers: nil, openedTime: nil)
        
        mapResponseToManagedObject(membershipCardResponse, managedObjectType: CD_MembershipCard.self) { membershipCard in
            self.membershipCard = membershipCard
        }
    }
    
    private func mapMembershipCard() {
        mapResponseToManagedObject(Self.membershipCardResponse, managedObjectType: CD_MembershipCard.self) { membershipCard in
            Self.membershipCard = membershipCard
        }
    }
    
    func test_title_noTransactions() {
        Self.membershipCardResponse.membershipTransactions = nil
        mapMembershipCard()
        
        Self.sut = TransactionsViewModel(membershipCard: Self.membershipCard)
        
        XCTAssertTrue(Self.sut.title == L10n.transactionHistoryUnavailableTitle)
    }
    
    func test_description_noTransactions() {
        Self.membershipCardResponse.membershipTransactions = nil
        mapMembershipCard()
        
        Self.sut = TransactionsViewModel(membershipCard: Self.membershipCard)
        
        XCTAssertTrue(Self.sut.description == L10n.transactionHistoryUnavailableDescription)
    }
    
    func test_title_withTransactions() {
        Self.membershipCardResponse.membershipTransactions = [MembershipTransaction(apiId: 5, status: "Something", timestamp: 12345, transactionDescription: "test", amounts: nil)]
        mapMembershipCard()
        
        Self.sut = TransactionsViewModel(membershipCard: Self.membershipCard)
        
        XCTAssertTrue(Self.sut.title == L10n.transactionHistoryTitle)
    }
    
    func test_description_withTransactions() {
        Self.membershipCardResponse.membershipTransactions = [MembershipTransaction(apiId: 5, status: "Something", timestamp: 12345, transactionDescription: "test", amounts: nil)]
        mapMembershipCard()
        
        Self.sut = TransactionsViewModel(membershipCard: Self.membershipCard)
        
        XCTAssertTrue(Self.sut.description == L10n.recentTransactionHistorySubtitle)
    }
    
    func test_storeTransaction() {
        Self.membershipCardResponse.membershipTransactions = [MembershipTransaction(apiId: 5, status: "Something", timestamp: 12345, transactionDescription: "test", amounts: nil)]
        mapMembershipCard()
        
        Self.sut = TransactionsViewModel(membershipCard: Self.membershipCard)
        
        Self.sut.storeMostRecentTransaction()
        
        XCTAssertTrue(Self.sut.hasStoredMostRecentTransaction)
    }
}
