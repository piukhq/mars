//
//  MembershipPlanModelTests.swift
//  binkappTests
//
//  Created by Sean Williams on 14/07/2022.
//  Copyright © 2022 Bink. All rights reserved.
//

// swiftlint:disable all

import XCTest
@testable import binkapp

class MembershipPlanModelTests: XCTestCase {
    static let membershipPlanAccountModel = MembershipPlanAccountModel(apiId: nil, planName: nil, planNameCard: nil, planURL: nil, companyName: "Tesco", category: nil, planSummary: nil, planDescription: nil, barcodeRedeemInstructions: nil, planRegisterInfo: nil, companyURL: nil, enrolIncentive: nil, forgottenPasswordUrl: nil, tiers: nil, planDocuments: nil, addFields: nil, authoriseFields: nil, registrationFields: nil, enrolFields: nil)
    let stubbedValidResponse: [String: Any?] = [
        "id": 0,
        "status": "active",
        "featuresSet": "",
        "images": [],
        "account": membershipPlanAccountModel.dictionary!,
        "balances": [],
        "dynamicContent": [],
        "hasVouchers": true,
        "card": nil
    ]

    let stubbedInvalidResponse: [String: Any?] = [
        "id": "0",
        "status": "active",
        "featuresSet": "",
        "images": [],
        "account": membershipPlanAccountModel.dictionary!,
        "balances": [],
        "dynamicContent": [],
        "hasVouchers": true,
        "card": nil
    ]
    
    func test_membershipPlan_validResponse_decodesCorrectly() {
        let responseData = try! JSONSerialization.data(withJSONObject: stubbedValidResponse, options: .prettyPrinted)
        let decodedResponse = try! JSONDecoder().decode(MembershipPlanModel.self, from: responseData)
        XCTAssertNotNil(decodedResponse)
    }
    
    func test_membershipPlan_invalidResponse_failsToDecode() {
        let responseData = try? JSONSerialization.data(withJSONObject: stubbedInvalidResponse, options: .prettyPrinted)
        let decodedResponse = try? JSONDecoder().decode(MembershipPlanModel.self, from: responseData!)
        XCTAssertNil(decodedResponse)
    }
    
    func test_membershipPlan_decodeValues() {
        let responseData = try! JSONSerialization.data(withJSONObject: stubbedValidResponse, options: .prettyPrinted)
        let decodedResponse = try! JSONDecoder().decode(MembershipPlanModel.self, from: responseData)
        XCTAssertEqual(decodedResponse.apiId, 0)
        XCTAssertEqual(decodedResponse.status, "active")
        XCTAssertEqual(decodedResponse.card, nil)
        XCTAssertEqual(decodedResponse.account?.companyName, "Tesco")
    }
    
    func test_equatable_worksCorrectly() {
        let plan1 = MembershipPlanModel(apiId: 500, status: nil, featureSet: nil, images: nil, account: nil, balances: nil, dynamicContent: nil, hasVouchers: nil, card: nil)
        let plan2 = MembershipPlanModel(apiId: 500, status: nil, featureSet: nil, images: nil, account: nil, balances: nil, dynamicContent: nil, hasVouchers: nil, card: nil)

        XCTAssertTrue(plan1 == plan2)
        XCTAssertFalse(plan1 != plan2)
    }
}
