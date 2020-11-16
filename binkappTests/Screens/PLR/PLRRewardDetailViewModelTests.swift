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
        let documents = PlanDocumentModel(apiId: nil, name: "Terms & Conditions", documentDescription: nil, url: "https://policies.staging.gb.bink.com/wasabi/tc.html", display: [.voucher], checkbox: nil)
        let accountModel = MembershipPlanAccountModel(apiId: nil, planName: nil, planNameCard: nil, planURL: nil, companyName: nil, category: nil, planSummary: nil, planDescription: nil, barcodeRedeemInstructions: nil, planRegisterInfo: nil, companyURL: nil, enrolIncentive: nil, forgottenPasswordUrl: nil, tiers: nil, planDocuments: [documents], addFields: nil, authoriseFields: nil, registrationFields: nil, enrolFields: nil)
        membershipPlan = MembershipPlanModel(apiId: nil, status: nil, featureSet: nil, images: nil, account: accountModel, balances: nil, dynamicContent: dynamicContentForVoucherSubtext(), hasVouchers: true, card: nil)
        
        let accumulatorVoucherEarnModel = VoucherEarnModel(apiId: nil, currency: nil, prefix: "£", suffix: "@@@@@@", type: .accumulator, targetValue: 20, value: nil)
        let burnModel = VoucherBurnModel(apiId: nil, currency: nil, prefix: "£", suffix: nil, value: 500, type: .voucher)
        accumulatorVoucher = VoucherModel(apiId: nil, state: nil, code: "123456", barcode: nil, barcodeType: nil, headline: nil, subtext: nil, dateRedeemed: 1536080200, dateIssued: 999999999, expiryDate: 1535480100, earn: accumulatorVoucherEarnModel, burn: burnModel)
        
        let stampsVoucherEarnModel = VoucherEarnModel(apiId: nil, currency: nil, prefix: nil, suffix: nil, type: .stamps, targetValue: nil, value: nil)
        stampsVoucher = VoucherModel(apiId: nil, state: nil, code: "123456", barcode: nil, barcodeType: nil, headline: nil, subtext: nil, dateRedeemed: 1536080100, dateIssued: 3332020, expiryDate: 1535080100, earn: stampsVoucherEarnModel, burn: nil)
    }
    
    private func dynamicContentForVoucherSubtext() -> [DynamicContentField] {
        let expired = DynamicContentField(apiId: nil, column: PLRRewardDetailViewModelMock.DynamicContentColumn.voucherStampsExpiredDetail.rawValue, value: "Expired")
        let redeemed = DynamicContentField(apiId: nil, column: PLRRewardDetailViewModelMock.DynamicContentColumn.voucherStampsRedeemedDetail.rawValue, value: "Redeemed")
        let inProgress = DynamicContentField(apiId: nil, column: PLRRewardDetailViewModelMock.DynamicContentColumn.voucherStampsInProgressDetail.rawValue, value: "Spend £7.00 or more to get a stamp. Collect 7 stamps to get a Meal Voucher of up to £7 off your next meal.")
        let issued = DynamicContentField(apiId: nil, column: PLRRewardDetailViewModelMock.DynamicContentColumn.voucherStampsIssuedDetail.rawValue, value: "Earned")
        let cancelled = DynamicContentField(apiId: nil, column: PLRRewardDetailViewModelMock.DynamicContentColumn.voucherStampsCancelledDetail.rawValue, value: "Cancelled")
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
        XCTAssertEqual(sut.subtextString, "Spend £7.00 or more to get a stamp. Collect 7 stamps to get a Meal Voucher of up to £7 off your next meal.")
    }
    
    func test_subtextString_for_stamps_voucher_issued_state() {
        stampsVoucher.state = .issued
        let sut = PLRRewardDetailViewModelMock(voucher: stampsVoucher, plan: membershipPlan)
        XCTAssertEqual(sut.subtextString, "Earned")
    }
    
    func test_subtextString_for_stamps_voucher_redeemed_state() {
        stampsVoucher.state = .redeemed
        let sut = PLRRewardDetailViewModelMock(voucher: stampsVoucher, plan: membershipPlan)
        XCTAssertEqual(sut.subtextString, "Redeemed")
    }
    
    func test_subtextString_for_stamps_voucher_expired_state() {
        stampsVoucher.state = .expired
        let sut = PLRRewardDetailViewModelMock(voucher: stampsVoucher, plan: membershipPlan)
        XCTAssertEqual(sut.subtextString, "Expired")
    }
    
    func test_subtextString_for_voucher_cancelled_state() {
        stampsVoucher.state = .cancelled
        let sut = PLRRewardDetailViewModelMock(voucher: stampsVoucher, plan: membershipPlan)
        XCTAssertEqual(sut.subtextString, "Cancelled")
    }
    
    func test_issuedDateString_is_correctly_formatted() {
        var sut = PLRRewardDetailViewModelMock(voucher: stampsVoucher, plan: membershipPlan)
        XCTAssertEqual(sut.issuedDateString, "Added 08 Feb 1970 14:33:40")
        
        sut = PLRRewardDetailViewModelMock(voucher: accumulatorVoucher, plan: membershipPlan)
        XCTAssertEqual(sut.issuedDateString, "Added 09 Sep 2001 02:46:39")
    }
    
    func test_redeemedDateString_is_correct() {
        var sut = PLRRewardDetailViewModelMock(voucher: stampsVoucher, plan: membershipPlan)
        XCTAssertEqual(sut.redeemedDateString, "Redeemed 04 Sep 2018 17:55:00")
        
        sut = PLRRewardDetailViewModelMock(voucher: accumulatorVoucher, plan: membershipPlan)
        XCTAssertEqual(sut.redeemedDateString, "Redeemed 04 Sep 2018 17:56:40")
    }
    
    func test_expiredDateString_is_correct() {
        stampsVoucher.state = .expired
        let sut = PLRRewardDetailViewModelMock(voucher: stampsVoucher, plan: membershipPlan)
        XCTAssertEqual(sut.expiredDateString, "Expired 24 Aug 2018 04:08:20")
        
        sut.voucher.state = .cancelled
        XCTAssertEqual(sut.expiredDateString, "Expired 24 Aug 2018 04:08:20")
        
        sut.voucher.state = .issued
        XCTAssertEqual(sut.expiredDateString, "Expires 24 Aug 2018 04:08:20")
        
        accumulatorVoucher.state = .expired
        sut.voucher = accumulatorVoucher
        XCTAssertEqual(sut.expiredDateString, "Expired 28 Aug 2018 19:15:00")
        
        sut.voucher.state = .cancelled
        XCTAssertEqual(sut.expiredDateString, "Expired 28 Aug 2018 19:15:00")
        
        sut.voucher.state = .issued
        XCTAssertEqual(sut.expiredDateString, "Expires 28 Aug 2018 19:15:00")
    }
    
    func test_termsAndConditions_button_title_is_correct() {
        let sut = PLRRewardDetailViewModelMock(voucher: stampsVoucher, plan: membershipPlan)
        XCTAssertEqual(sut.termsAndConditionsButtonTitle, "Terms & Conditions")
    }
    
    func test_termsAndConditions_urlString_is_correct() {
        let sut = PLRRewardDetailViewModelMock(voucher: stampsVoucher, plan: membershipPlan)
        XCTAssertEqual(sut.termsAndConditionsButtonUrlString, "https://policies.staging.gb.bink.com/wasabi/tc.html")
    }
    
    func test_shouldShowCode_if_in_issued_state() {
        stampsVoucher.state = .expired
        let sut = PLRRewardDetailViewModelMock(voucher: stampsVoucher, plan: membershipPlan)
        XCTAssertFalse(sut.shouldShowCode)
        
        sut.voucher.state = .issued
        XCTAssertTrue(sut.shouldShowCode)
    }
    
    func test_shouldShowHeader_if_string_exists() {
        let sut = PLRRewardDetailViewModelMock(voucher: stampsVoucher, plan: membershipPlan)
        XCTAssertFalse(sut.shouldShowHeader)
        
        sut.voucher.state = .issued
        XCTAssertTrue(sut.shouldShowHeader)
    }
    
    func test_shouldShowSubtext_if_string_exists() {
        let sut = PLRRewardDetailViewModelMock(voucher: stampsVoucher, plan: membershipPlan)
        XCTAssertFalse(sut.shouldShowSubtext)
        
        sut.voucher.state = .issued
        XCTAssertTrue(sut.shouldShowSubtext)
    }
    
    func test_shouldShowIssuedDate_for_stamps_voucher() {
        let sut = PLRRewardDetailViewModelMock(voucher: stampsVoucher, plan: membershipPlan)
        sut.voucher.state = .issued
        XCTAssertTrue(sut.shouldShowIssuedDate)

        sut.voucher.state = .expired
        XCTAssertTrue(sut.shouldShowIssuedDate)
        
        sut.voucher.state = .redeemed
        XCTAssertTrue(sut.shouldShowIssuedDate)
        
        sut.voucher.state = .cancelled
        XCTAssertTrue(sut.shouldShowIssuedDate)
        
        sut.voucher.state = .inProgress
        XCTAssertFalse(sut.shouldShowIssuedDate)
        
        sut.voucher.dateIssued = 0
        XCTAssertFalse(sut.shouldShowIssuedDate)
    }
    
    func test_shouldShowIssuedDate_for_accumulator_voucher() {
        let sut = PLRRewardDetailViewModelMock(voucher: accumulatorVoucher, plan: membershipPlan)
        sut.voucher.state = .issued
        XCTAssertTrue(sut.shouldShowIssuedDate)

        sut.voucher.state = .expired
        XCTAssertTrue(sut.shouldShowIssuedDate)
        
        sut.voucher.state = .redeemed
        XCTAssertFalse(sut.shouldShowIssuedDate)
        
        sut.voucher.state = .cancelled
        XCTAssertTrue(sut.shouldShowIssuedDate)
        
        sut.voucher.state = .inProgress
        XCTAssertFalse(sut.shouldShowIssuedDate)
        
        sut.voucher.dateIssued = 0
        XCTAssertFalse(sut.shouldShowIssuedDate)
    }
    
    func test_shouldShowRedeemedDate_for_redeemed_state() {
        let sut = PLRRewardDetailViewModelMock(voucher: stampsVoucher, plan: membershipPlan)
        XCTAssertFalse(sut.shouldShowRedeemedDate)
        
        sut.voucher.state = .redeemed
        XCTAssertTrue(sut.shouldShowRedeemedDate)
        
        sut.voucher.dateRedeemed = 0
        XCTAssertFalse(sut.shouldShowRedeemedDate)
    }
}
