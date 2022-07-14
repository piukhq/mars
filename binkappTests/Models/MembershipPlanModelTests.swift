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
    static let membershipPlanAccountModel = MembershipPlanAccountModel(apiId: nil, planName: nil, planNameCard: nil, planURL: nil, companyName: nil, category: nil, planSummary: nil, planDescription: nil, barcodeRedeemInstructions: nil, planRegisterInfo: nil, companyURL: nil, enrolIncentive: nil, forgottenPasswordUrl: nil, tiers: nil, planDocuments: nil, addFields: nil, authoriseFields: nil, registrationFields: nil, enrolFields: nil)
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

    let stubbedInvalidResponse: [String: Any] = [
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
    
    func test_membershipPlan_validResponse_decodesCorrectly() {
        let responseData = try! JSONSerialization.data(withJSONObject: stubbedValidResponse, options: .prettyPrinted)
        let decodedResponse = try! JSONDecoder().decode(MembershipPlanModel.self, from: responseData)
        XCTAssertNotNil(decodedResponse)
    }
}
