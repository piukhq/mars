//
//  PLRRewardDetailViewModelTests.swift
//  binkappTests
//
//  Created by Sean Williams on 13/11/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import XCTest
@testable import binkapp

class PLRRewardDetailViewModelTests: XCTestCase {
    var membershipPlan: MembershipPlanModel!
    var voucher: VoucherModel!
    
    override func setUpWithError() throws {
        membershipPlan = MembershipPlanModel(apiId: nil, status: nil, featureSet: nil, images: nil, account: nil, balances: nil, dynamicContent: nil, hasVouchers: true, card: nil)
        voucher = VoucherModel(apiId: nil, state: nil, code: "123456", barcode: nil, barcodeType: nil, headline: nil, subtext: nil, dateRedeemed: nil, dateIssued: nil, expiryDate: nil, earn: nil, burn: nil)
    }
    
    func test_title_string_is_correct() {
        membershipPlan.account = MembershipPlanAccountModel(apiId: nil, planName: nil, planNameCard: nil, planURL: nil, companyName: "Tesco", category: nil, planSummary: nil, planDescription: nil, barcodeRedeemInstructions: nil, planRegisterInfo: nil, companyURL: nil, enrolIncentive: nil, forgottenPasswordUrl: nil, tiers: nil, planDocuments: nil, addFields: nil, authoriseFields: nil, registrationFields: nil, enrolFields: nil)
        let sut = PLRRewardDetailViewModelMock(voucher: voucher, plan: membershipPlan)
        XCTAssertEqual(sut.title, "Tesco")
    }
    
    func test_codeString_is_correct() {
        let sut = PLRRewardDetailViewModelMock(voucher: voucher, plan: membershipPlan)
        XCTAssertEqual(sut.codeString, "123456")
    }
    
    func test_headerString_matches_correct_voucherState_and_earnType() {
        
    }
}
