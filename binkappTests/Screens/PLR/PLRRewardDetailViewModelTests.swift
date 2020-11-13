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
    var accumulatorVoucher: VoucherModel!
    var stampsVoucher: VoucherModel!
    
    override func setUpWithError() throws {
        membershipPlan = MembershipPlanModel(apiId: nil, status: nil, featureSet: nil, images: nil, account: nil, balances: nil, dynamicContent: nil, hasVouchers: true, card: nil)
        let accumulatorVoucherEarnModel = VoucherEarnModel(apiId: nil, currency: nil, prefix: nil, suffix: nil, type: .accumulator, targetValue: nil, value: nil)
        accumulatorVoucher = VoucherModel(apiId: nil, state: nil, code: "123456", barcode: nil, barcodeType: nil, headline: nil, subtext: nil, dateRedeemed: nil, dateIssued: nil, expiryDate: nil, earn: accumulatorVoucherEarnModel, burn: nil)
        
        let stampsVoucherEarnModel = VoucherEarnModel(apiId: nil, currency: nil, prefix: nil, suffix: nil, type: .stamps, targetValue: nil, value: nil)
        stampsVoucher = VoucherModel(apiId: nil, state: nil, code: "123456", barcode: nil, barcodeType: nil, headline: nil, subtext: nil, dateRedeemed: nil, dateIssued: nil, expiryDate: nil, earn: stampsVoucherEarnModel, burn: nil)
    }
    
    func test_title_string_is_correct() {
        membershipPlan.account = MembershipPlanAccountModel(apiId: nil, planName: nil, planNameCard: nil, planURL: nil, companyName: "Tesco", category: nil, planSummary: nil, planDescription: nil, barcodeRedeemInstructions: nil, planRegisterInfo: nil, companyURL: nil, enrolIncentive: nil, forgottenPasswordUrl: nil, tiers: nil, planDocuments: nil, addFields: nil, authoriseFields: nil, registrationFields: nil, enrolFields: nil)
        let sut = PLRRewardDetailViewModelMock(voucher: accumulatorVoucher, plan: membershipPlan)
        XCTAssertEqual(sut.title, "Tesco")
    }
    
    func test_codeString_is_correct() {
        let sut = PLRRewardDetailViewModelMock(voucher: accumulatorVoucher, plan: membershipPlan)
        XCTAssertEqual(sut.codeString, "123456")
    }
    
    func test_headerString_for_issued_state() {
//        accumulatorVoucher.state = .issued
//        var sut = PLRRewardDetailViewModelMock(voucher: accumulatorVoucher, plan: membershipPlan)
//        let issuedHeaderString = String(format: "plr_voucher_detail_issued_header".localized, sut.voucherAmountText)
//        XCTAssertEqual(sut.headerString, issuedHeaderString)
//
//        voucher.earn?.type = .stamps
//        sut = PLRRewardDetailViewModelMock(voucher: voucher, plan: membershipPlan)
//        XCTAssertEqual(sut.headerString, issuedHeaderString)
    }
    
    func test_headerString_for_accumulator_redeemed_state() {
        accumulatorVoucher.state = .redeemed
        var sut = PLRRewardDetailViewModelMock(voucher: accumulatorVoucher, plan: membershipPlan)
        let redeemedHeaderString = String(format: "plr_voucher_detail_redeemed_header".localized, sut.voucherAmountText)
        XCTAssertEqual(sut.headerString, redeemedHeaderString)

        stampsVoucher.state = .redeemed
        sut = PLRRewardDetailViewModelMock(voucher: stampsVoucher, plan: membershipPlan)
        XCTAssertEqual(sut.headerString, redeemedHeaderString)
    }
}
