//
//  PaymentCardDetailLoyaltyCardStatusCellViewModelTests.swift
//  binkappTests
//
//  Created by Sean Williams on 14/07/2022.
//  Copyright © 2022 Bink. All rights reserved.
//

import XCTest
@testable import binkapp

class PaymentCardDetailLoyaltyCardStatusCellViewModelTests: XCTestCase, CoreDataTestable {
    static var baseMembershipCardResponse: MembershipCardModel!

    static var membershipCard: CD_MembershipCard!

    static let baseSut = PaymentCardDetailLoyaltyCardStatusCellViewModel(membershipCard: membershipCard)
    
    static var membershipCardStatusModel: MembershipCardStatusModel!

    override class func setUp() {
        super.setUp()
        // Membership Plan
        let account = MembershipPlanAccountModel(apiId: nil, planName: nil, planNameCard: nil, planURL: nil, companyName: "Tesco", category: nil, planSummary: nil, planDescription: nil, barcodeRedeemInstructions: nil, planRegisterInfo: nil, companyURL: nil, enrolIncentive: nil, forgottenPasswordUrl: nil, tiers: nil, planDocuments: nil, addFields: nil, authoriseFields: nil, registrationFields: nil, enrolFields: nil)
        let plan = MembershipPlanModel(apiId: 500, status: nil, featureSet: nil, images: nil, account: account, balances: nil, dynamicContent: nil, hasVouchers: nil, card: nil, goLive: "")
        mapResponseToManagedObject(plan, managedObjectType: CD_MembershipPlan.self) { _ in }
        
        // Membership Card
        membershipCardStatusModel = MembershipCardStatusModel(apiId: nil, state: .authorised, reasonCodes: nil)
        baseMembershipCardResponse = MembershipCardModel(apiId: 300, membershipPlan: 500, membershipTransactions: nil, status: membershipCardStatusModel, card: nil, images: nil, account: nil, paymentCards: nil, balances: nil, vouchers: nil, openedTime: nil)

        mapResponseToManagedObject(baseMembershipCardResponse, managedObjectType: CD_MembershipCard.self) { membershipCard in
            self.membershipCard = membershipCard
        }
    }
    
    
    private func switchCardStatus(status: MembershipCardStatus, completion: @escaping EmptyCompletionBlock) {
        Self.membershipCardStatusModel.state = status
        Self.baseMembershipCardResponse.status = Self.membershipCardStatusModel
        mapResponseToManagedObject(Self.baseMembershipCardResponse, managedObjectType: CD_MembershipCard.self) { _ in
            completion()
        }
    }
    
    func test_headerText_returnsCorrectCompanyName() {
        XCTAssertEqual(Self.baseSut.headerText, "Tesco")
    }
    
    func test_detailText_returnsCorrectText() {
        XCTAssertEqual(Self.baseSut.detailText, L10n.pcdYouCanLink)
        
        switchCardStatus(status: .unauthorised) {
            XCTAssertNil(Self.baseSut.detailText)
        }
        
        switchCardStatus(status: .failed) {
            XCTAssertNil(Self.baseSut.detailText)
        }

        switchCardStatus(status: .pending) {
            XCTAssertNil(Self.baseSut.detailText)
        }
    }
    
    func test_status_returnsCorrectStatus() {
        XCTAssertEqual(Self.baseSut.status, Self.membershipCard.status)

        switchCardStatus(status: .unauthorised) {
            XCTAssertEqual(Self.baseSut.status, Self.membershipCard.status)
        }
        
        switchCardStatus(status: .pending) {
            XCTAssertEqual(Self.baseSut.status, Self.membershipCard.status)
        }
        
        switchCardStatus(status: .failed) {
            XCTAssertEqual(Self.baseSut.status, Self.membershipCard.status)
        }
    }
    
    func test_statusText_returnsCorrectText() {
        switchCardStatus(status: .authorised) {
            XCTAssertEqual(Self.baseSut.statusText, "Authorised")
        }
        
        switchCardStatus(status: .unauthorised) {
            XCTAssertEqual(Self.baseSut.statusText, "Retry")
        }
        
        switchCardStatus(status: .failed) {
            XCTAssertEqual(Self.baseSut.statusText, "Retry")
        }

        switchCardStatus(status: .pending) {
            XCTAssertEqual(Self.baseSut.statusText, "Pending")
        }
    }
}
