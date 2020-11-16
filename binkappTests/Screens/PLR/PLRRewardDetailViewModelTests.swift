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
        membershipPlan = MembershipPlanModel(apiId: nil, status: nil, featureSet: nil, images: nil, account: nil, balances: nil, dynamicContent: dynamicContentForVoucherSubtext(), hasVouchers: true, card: nil)
        
        let accumulatorVoucherEarnModel = VoucherEarnModel(apiId: nil, currency: nil, prefix: "£", suffix: "@@@@@@", type: .accumulator, targetValue: 20, value: nil)
        let burnModel = VoucherBurnModel(apiId: nil, currency: nil, prefix: "£", suffix: nil, value: 500, type: .voucher)
        
        accumulatorVoucher = VoucherModel(apiId: nil, state: nil, code: "123456", barcode: nil, barcodeType: nil, headline: nil, subtext: nil, dateRedeemed: nil, dateIssued: 999999999, expiryDate: nil, earn: accumulatorVoucherEarnModel, burn: burnModel)
        
        let stampsVoucherEarnModel = VoucherEarnModel(apiId: nil, currency: nil, prefix: nil, suffix: nil, type: .stamps, targetValue: nil, value: nil)
        stampsVoucher = VoucherModel(apiId: nil, state: nil, code: "123456", barcode: nil, barcodeType: nil, headline: nil, subtext: nil, dateRedeemed: nil, dateIssued: 3332020, expiryDate: nil, earn: stampsVoucherEarnModel, burn: nil)
    }
    
    func dynamicContentForVoucherSubtext() -> [DynamicContentField] {
        let expired = DynamicContentField(apiId: nil, column: PLRRewardDetailViewModelMock.DynamicContentColumn.voucherStampsExpiredDetail.rawValue, value: "expired")
        let redeemed = DynamicContentField(apiId: nil, column: PLRRewardDetailViewModelMock.DynamicContentColumn.voucherStampsRedeemedDetail.rawValue, value: "redeemed")
        let inProgress = DynamicContentField(apiId: nil, column: PLRRewardDetailViewModelMock.DynamicContentColumn.voucherStampsInProgressDetail.rawValue, value: "inProgress")
        let issued = DynamicContentField(apiId: nil, column: PLRRewardDetailViewModelMock.DynamicContentColumn.voucherStampsIssuedDetail.rawValue, value: "issued")
        let cancelled = DynamicContentField(apiId: nil, column: PLRRewardDetailViewModelMock.DynamicContentColumn.voucherStampsCancelledDetail.rawValue, value: "cancelled")
        return [expired, redeemed, inProgress, issued, cancelled]
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
        accumulatorVoucher.state = .issued
        var sut = PLRRewardDetailViewModelMock(voucher: accumulatorVoucher, plan: membershipPlan)
        let headerString = String(format: "plr_voucher_detail_issued_header".localized, sut.voucherAmountText)
        XCTAssertEqual(sut.headerString, headerString)

        stampsVoucher.state = .issued
        sut = PLRRewardDetailViewModelMock(voucher: stampsVoucher, plan: membershipPlan)
        XCTAssertEqual(sut.headerString, headerString)
    }
    
    func test_headerString_for_redeemed_state() {
        accumulatorVoucher.state = .redeemed
        var sut = PLRRewardDetailViewModelMock(voucher: accumulatorVoucher, plan: membershipPlan)
        let headerString = String(format: "plr_voucher_detail_redeemed_header".localized, sut.voucherAmountText)
        XCTAssertEqual(sut.headerString, headerString)

        stampsVoucher.state = .redeemed
        sut = PLRRewardDetailViewModelMock(voucher: stampsVoucher, plan: membershipPlan)
        XCTAssertEqual(sut.headerString, headerString)
    }

    func test_headerString_for_expired_state() {
        accumulatorVoucher.state = .expired
        var sut = PLRRewardDetailViewModelMock(voucher: accumulatorVoucher, plan: membershipPlan)
        let headerString = String(format: "plr_voucher_detail_expired_header".localized, sut.voucherAmountText)
        XCTAssertEqual(sut.headerString, headerString)

        stampsVoucher.state = .expired
        sut = PLRRewardDetailViewModelMock(voucher: stampsVoucher, plan: membershipPlan)
        XCTAssertEqual(sut.headerString, headerString)
    }
    
    func test_headerString_for_inProgress_state() {
        stampsVoucher.state = .inProgress
        let sut = PLRRewardDetailViewModelMock(voucher: stampsVoucher, plan: membershipPlan)
        let headerString = String(format: "plr_stamp_voucher_detail_inprogress_header".localized, sut.voucherAmountText)
        XCTAssertEqual(sut.headerString, headerString)
    }
    
    func test_headerString_for_cancelled_state() {
        accumulatorVoucher.state = .cancelled
        var sut = PLRRewardDetailViewModelMock(voucher: accumulatorVoucher, plan: membershipPlan)
        let headerString = String(format: "plr_stamp_voucher_detail_cancelled_header".localized, sut.voucherAmountText)
        XCTAssertEqual(sut.headerString, headerString)

        stampsVoucher.state = .cancelled
        sut = PLRRewardDetailViewModelMock(voucher: stampsVoucher, plan: membershipPlan)
        XCTAssertEqual(sut.headerString, headerString)
    }
    
    func test_issuedDateString_is_correctly_formatted() {
        var sut = PLRRewardDetailViewModelMock(voucher: stampsVoucher, plan: membershipPlan)
        XCTAssertEqual("Added 08 Feb 1970 14:33:40", sut.issuedDateString)
        
        sut = PLRRewardDetailViewModelMock(voucher: accumulatorVoucher, plan: membershipPlan)
        XCTAssertEqual("Added 09 Sep 2001 02:46:39", sut.issuedDateString)
    }
    
    func test_subtextString_for_accumulator_voucher_inProgress_state() {
        accumulatorVoucher.state = .inProgress
        let sut = PLRRewardDetailViewModelMock(voucher: accumulatorVoucher, plan: membershipPlan)
        XCTAssertEqual(sut.subtextString, "Spend £20 with us and you\'ll get a £500 voucher.")
    }
    
    func test_subtextString_for_accumulator_voucher_issued_state() {
        accumulatorVoucher.state = .issued
        let sut = PLRRewardDetailViewModelMock(voucher: accumulatorVoucher, plan: membershipPlan)
        XCTAssertEqual(sut.subtextString, "Use the code above to redeem your reward. You will get £500 off your purchase.")
    }
    
    func test_subtextString_for_stamps_voucher_inProgress_state() {
        stampsVoucher.state = .inProgress
        let sut = PLRRewardDetailViewModelMock(voucher: stampsVoucher, plan: membershipPlan)
        XCTAssertEqual(sut.subtextString, "Use")
    }
}
