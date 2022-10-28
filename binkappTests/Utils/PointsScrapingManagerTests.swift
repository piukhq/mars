//
//  PointsScrapingManagerTests.swift
//  binkappTests
//
//  Created by Ricardo Silva on 27/10/2022.
//  Copyright © 2022 Bink. All rights reserved.
//

import XCTest
@testable import binkapp

// swiftlint:disable all

final class PointsScrapingManagerTests: XCTestCase, CoreDataTestable {
    static var membershipPlan: CD_MembershipPlan!
    static var membershipPlanResponse: MembershipPlanModel!
    static var membershipPlanAccountModel: MembershipPlanAccountModel!
    
    static var membershipCardResponse: MembershipCardModel!
    
    static var membershipCardBalanceModel: MembershipCardBalanceModel!
    
    static var membershipCardStatusModel: MembershipCardStatusModel!
    
    static var featureSetModel: FeatureSetModel!
    
    static var cardResponse: CardModel!
    
    static var membershipCard: CD_MembershipCard!
    
    static var voucherResponse: VoucherModel!
    static var voucher: CD_Voucher!
    
    static var sut: PointsScrapingManager!
    
    override class func setUp() {
        super.setUp()
        
        let burnModel = VoucherBurnModel(apiId: 500, currency: nil, prefix: "£", suffix: "gift", value: 500, type: "voucher")
        let stampsVoucherEarnModel = VoucherEarnModel(apiId: 500, currency: nil, prefix: "£", suffix: "gift", type: .accumulator, targetValue: 600, value: 500)
        voucherResponse = VoucherModel(apiId: 500, state: .inProgress, code: "123456", barcode: nil, barcodeType: nil, headline: nil, subtext: nil, dateRedeemed: 1536080100, dateIssued: 3332020, expiryDate: 1535080100, earn: stampsVoucherEarnModel, burn: burnModel)
        
        cardResponse = CardModel(apiId: 500, barcode: "123456789", membershipId: "999 666", barcodeType: 0, colour: "#0000ff", secondaryColour: nil)
        
        featureSetModel = FeatureSetModel(apiId: 500, authorisationRequired: nil, transactionsAvailable: nil, digitalOnly: nil, hasPoints: true, cardType: .link, linkingSupport: [.add], hasVouchers: false)
        
        membershipPlanAccountModel = MembershipPlanAccountModel(apiId: 500, planName: "Test Plan", planNameCard: "Card Name", planURL: nil, companyName: "Tesco", category: nil, planSummary: nil, planDescription: nil, barcodeRedeemInstructions: nil, planRegisterInfo: nil, companyURL: nil, enrolIncentive: nil, forgottenPasswordUrl: nil, tiers: nil, planDocuments: nil, addFields: nil, authoriseFields: nil, registrationFields: nil, enrolFields: nil)
        
        membershipPlanResponse = MembershipPlanModel(apiId: 500, status: nil, featureSet: featureSetModel, images: nil, account: membershipPlanAccountModel, balances: nil, dynamicContent: nil, hasVouchers: true, card: cardResponse)
        
        mapResponseToManagedObject(membershipPlanResponse, managedObjectType: CD_MembershipPlan.self) { plan in
            self.membershipPlan = plan
        }
        
        membershipCardBalanceModel = MembershipCardBalanceModel(apiId: 500, value: 500, currency: nil, prefix: "£", suffix: nil, updatedAt: nil)
        
        membershipCardStatusModel = MembershipCardStatusModel(apiId: 500, state: .authorised, reasonCodes: [.pointsScrapingLoginRequired])
        
        membershipCardResponse = MembershipCardModel(apiId: 500, membershipPlan: 500, membershipTransactions: nil, status: membershipCardStatusModel, card: cardResponse, images: nil, account: MembershipCardAccountModel(apiId: 500, tier: 1), paymentCards: nil, balances: [membershipCardBalanceModel], vouchers: [voucherResponse])
        
        mapResponseToManagedObject(membershipCardResponse, managedObjectType: CD_MembershipCard.self) { membershipCard in
            self.membershipCard = membershipCard
        }
        
        sut = PointsScrapingManager()
    }
    
    func test_PointsScrapingManagerError_Erros() throws {
        var e = PointsScrapingManager.PointsScrapingManagerError.failedToStoreCredentials
        XCTAssertTrue(e.message == "Failed to store credentials")
        
        e = PointsScrapingManager.PointsScrapingManagerError.failedToRetrieveCredentials
        XCTAssertTrue(e.message == "Failed to retrieve credentials")
        
        e = PointsScrapingManager.PointsScrapingManagerError.failedToEnableMembershipCardForPointsScraping
        XCTAssertTrue(e.message == "Failed to enable membership card for points scraping")
        
        e = PointsScrapingManager.PointsScrapingManagerError.failedToGetMembershipPlanFromRequest
        XCTAssertTrue(e.message == "Failed to get membership plan from request")
        
        e = PointsScrapingManager.PointsScrapingManagerError.failedToGetAgentForMembershipPlan
        XCTAssertTrue(e.message == "Failed to get agent for membership plan")
    }
}
