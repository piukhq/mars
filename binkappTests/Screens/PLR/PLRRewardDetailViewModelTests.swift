//
//  PLRRewardDetailViewModelTests.swift
//  binkappTests
//
//  Created by Sean Williams on 13/11/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import XCTest
@testable import binkapp

class PLRRewardDetailViewModelTests: XCTestCase, CoreDataTestable {
    static var membershipPlanResponse: MembershipPlanModel!
    static var accumulatorVoucherResponse: VoucherModel!
    static var stampsVoucherResponse: VoucherModel!
    
    static var accumulatorVoucher: CD_Voucher!
    static var stampsVoucher: CD_Voucher!
    static var membershipPlan: CD_MembershipPlan!
    static var baseAccumulatorSut = PLRRewardDetailViewModel(voucher: accumulatorVoucher, plan: membershipPlan)
    static var baseStampsSut = PLRRewardDetailViewModel(voucher: stampsVoucher, plan: membershipPlan)

    override class func setUp() {
        let planDocument = PlanDocumentModel(apiId: nil, name: "Terms & Conditions", documentDescription: nil, url: "https://policies.staging.gb.bink.com/wasabi/tc.html", display: [.voucher], checkbox: nil)
        let accountModel = MembershipPlanAccountModel(apiId: nil, planName: nil, planNameCard: nil, planURL: nil, companyName: "Tesco", category: nil, planSummary: nil, planDescription: nil, barcodeRedeemInstructions: nil, planRegisterInfo: nil, companyURL: nil, enrolIncentive: nil, forgottenPasswordUrl: nil, tiers: nil, planDocuments: [planDocument], addFields: nil, authoriseFields: nil, registrationFields: nil, enrolFields: nil)
        membershipPlanResponse = MembershipPlanModel(apiId: nil, status: nil, featureSet: nil, images: nil, account: accountModel, balances: nil, dynamicContent: dynamicContentForVoucherSubtext(), hasVouchers: true, card: nil)
        
        let accumulatorVoucherEarnModel = VoucherEarnModel(apiId: nil, currency: nil, prefix: "£", suffix: "@@@@@@", type: .accumulator, targetValue: 20, value: nil)
        let burnModel = VoucherBurnModel(apiId: nil, currency: nil, prefix: "£", suffix: nil, value: 500, type: .voucher)
        
        accumulatorVoucherResponse = VoucherModel(apiId: nil, state: .issued, code: "123456", barcode: nil, barcodeType: nil, headline: nil, subtext: nil, dateRedeemed: 1536080200, dateIssued: 999999999, expiryDate: 1535080100, earn: accumulatorVoucherEarnModel, burn: burnModel)
        
        let stampsVoucherEarnModel = VoucherEarnModel(apiId: nil, currency: nil, prefix: nil, suffix: nil, type: .stamps, targetValue: nil, value: nil)
        stampsVoucherResponse = VoucherModel(apiId: nil, state: .issued, code: "123456", barcode: nil, barcodeType: nil, headline: nil, subtext: nil, dateRedeemed: 1536080100, dateIssued: 3332020, expiryDate: 1535080100, earn: stampsVoucherEarnModel, burn: burnModel)
        
        mapResponseToManagedObject(membershipPlanResponse, managedObjectType: CD_MembershipPlan.self) { plan in
            self.membershipPlan = plan
        }
    }
    
    
    // MARK: - Helper Methods
    
    private static func dynamicContentForVoucherSubtext() -> [DynamicContentField] {
        let expired = DynamicContentField(apiId: nil, column: DynamicContentColumn.voucherStampsExpiredDetail.rawValue, value: "Expired")
        let redeemed = DynamicContentField(apiId: nil, column: DynamicContentColumn.voucherStampsRedeemedDetail.rawValue, value: "Redeemed")
        let inProgress = DynamicContentField(apiId: nil, column: DynamicContentColumn.voucherStampsInProgressDetail.rawValue, value: "Spend £7.00 or more to get a stamp. Collect 7 stamps to get a Meal Voucher of up to £7 off your next meal.")
        let issued = DynamicContentField(apiId: nil, column: DynamicContentColumn.voucherStampsIssuedDetail.rawValue, value: "Earned")
        let cancelled = DynamicContentField(apiId: nil, column: DynamicContentColumn.voucherStampsCancelledDetail.rawValue, value: "Cancelled")
        return [expired, redeemed, inProgress, issued, cancelled]
    }
    
    enum DynamicContentColumn: String {
        case voucherStampsExpiredDetail = "Voucher_Expired_Detail"
        case voucherStampsRedeemedDetail = "Voucher_Redeemed_Detail"
        case voucherStampsInProgressDetail = "Voucher_Inprogress_Detail"
        case voucherStampsIssuedDetail = "Voucher_Issued_Detail"
        case voucherStampsCancelledDetail = "Voucher_Cancelled_Detail"
    }
    
    private func mapAccumulatorVoucher() {
        mapResponseToManagedObject(Self.accumulatorVoucherResponse, managedObjectType: CD_Voucher.self) { voucher in
            Self.accumulatorVoucher = voucher
        }
    }
    
    private func mapStampsVoucher() {
        mapResponseToManagedObject(Self.stampsVoucherResponse, managedObjectType: CD_Voucher.self) { voucher in
            Self.stampsVoucher = voucher
        }
    }
    
    
    // MARK: - Tests

    func test_termsAndConditions_button_title_is_correct() {
        let planDocument = PlanDocumentModel(apiId: nil, name: "Terms & Conditions", documentDescription: nil, url: "https://policies.staging.gb.bink.com/wasabi/tc.html", display: [.voucher], checkbox: nil)
        let accountModel = MembershipPlanAccountModel(apiId: nil, planName: nil, planNameCard: nil, planURL: nil, companyName: "Tesco", category: nil, planSummary: nil, planDescription: nil, barcodeRedeemInstructions: nil, planRegisterInfo: nil, companyURL: nil, enrolIncentive: nil, forgottenPasswordUrl: nil, tiers: nil, planDocuments: [planDocument], addFields: nil, authoriseFields: nil, registrationFields: nil, enrolFields: nil)
        Self.membershipPlanResponse.account = accountModel
        mapResponseToManagedObject(Self.membershipPlanResponse, managedObjectType: CD_MembershipPlan.self) { plan in
            Self.membershipPlan = plan
        }
        mapStampsVoucher()
        XCTAssertEqual(Self.baseStampsSut.termsAndConditionsButtonTitle, "Terms & Conditions")
    }

    func test_termsAndConditions_urlString_is_correct() {
        mapStampsVoucher()
        XCTAssertEqual(Self.baseStampsSut.termsAndConditionsButtonUrlString, "https://policies.staging.gb.bink.com/wasabi/tc.html")
    }
    
    func test_title_string_is_correct() {
        mapAccumulatorVoucher()
        XCTAssertEqual(Self.baseAccumulatorSut.title, "Tesco")
    }
    
    func test_codeString_is_correct() {
        mapAccumulatorVoucher()
        XCTAssertEqual(Self.baseAccumulatorSut.codeString, "123456")
    }

    func test_headerString_for_issued_state() {
        Self.accumulatorVoucherResponse.state = .issued
        mapAccumulatorVoucher()
        let headerString = String(format: "plr_voucher_detail_issued_header".localized, Self.baseAccumulatorSut.voucherAmountText)
        XCTAssertEqual(Self.baseAccumulatorSut.headerString, headerString)
        
        Self.stampsVoucherResponse.state = .issued
        mapStampsVoucher()
        let stampsHeaderString = String(format: "plr_voucher_detail_issued_header".localized, Self.baseStampsSut.voucherAmountText)
        XCTAssertEqual(Self.baseStampsSut.headerString, stampsHeaderString)
    }

    func test_headerString_for_redeemed_state() {
        mapAccumulatorVoucher()
        let headerString = String(format: "plr_voucher_detail_redeemed_header".localized, Self.baseAccumulatorSut.voucherAmountText)
        Self.accumulatorVoucherResponse.state = .redeemed
        mapAccumulatorVoucher()
        XCTAssertEqual(Self.baseAccumulatorSut.headerString, headerString)

        Self.stampsVoucherResponse.state = .redeemed
        mapStampsVoucher()
        XCTAssertEqual(Self.baseStampsSut.headerString, "plr_stamp_voucher_detail_redeemed_header".localized)
    }

    func test_headerString_for_expired_state() {
        mapAccumulatorVoucher()
        let headerString = String(format: "plr_voucher_detail_expired_header".localized, Self.baseAccumulatorSut.voucherAmountText)
        Self.accumulatorVoucherResponse.state = .expired
        mapAccumulatorVoucher()
        XCTAssertEqual(Self.baseAccumulatorSut.headerString, headerString)

        Self.stampsVoucherResponse.state = .expired
        mapStampsVoucher()
        XCTAssertEqual(Self.baseStampsSut.headerString, "plr_stamp_voucher_detail_expired_header".localized)
    }

    func test_headerString_for_inProgress_state() {
        Self.stampsVoucherResponse.state = .inProgress
        mapStampsVoucher()
        let headerString = String(format: "plr_stamp_voucher_detail_inprogress_header".localized, Self.baseStampsSut.voucherAmountText)
        XCTAssertEqual(Self.baseStampsSut.headerString, headerString)
    }

    func test_headerString_for_cancelled_state() {
        Self.accumulatorVoucherResponse.state = .cancelled
        mapAccumulatorVoucher()
        let headerString = String(format: "plr_stamp_voucher_detail_cancelled_header".localized, Self.baseAccumulatorSut.voucherAmountText)
        XCTAssertEqual(Self.baseAccumulatorSut.headerString, headerString)

        Self.stampsVoucherResponse.state = .cancelled
        mapStampsVoucher()
        XCTAssertEqual(Self.baseStampsSut.headerString, headerString)
    }

    func test_subtextString_for_accumulator_voucher_inProgress_state() {
        Self.accumulatorVoucherResponse.state = .inProgress
        mapAccumulatorVoucher()
        XCTAssertEqual(Self.baseAccumulatorSut.subtextString, "Spend £20 with us and you'll get a £500 voucher.")
    }

    func test_subtextString_for_accumulator_voucher_issued_state() {
        Self.accumulatorVoucherResponse.state = .issued
        mapAccumulatorVoucher()
        XCTAssertEqual(Self.baseAccumulatorSut.subtextString, "Use the code above to redeem your reward. You will get £500 off your purchase.")
    }

    func test_subtextString_for_stamps_voucher_inProgress_state() {
        Self.stampsVoucherResponse.state = .inProgress
        mapStampsVoucher()
        XCTAssertEqual(Self.baseStampsSut.subtextString, "Spend £7.00 or more to get a stamp. Collect 7 stamps to get a Meal Voucher of up to £7 off your next meal.")
    }

    func test_subtextString_for_stamps_voucher_issued_state() {
        Self.stampsVoucherResponse.state = .issued
        mapStampsVoucher()
        XCTAssertEqual(Self.baseStampsSut.subtextString, "Earned")
    }

    func test_subtextString_for_stamps_voucher_redeemed_state() {
        Self.stampsVoucherResponse.state = .redeemed
        mapStampsVoucher()
        XCTAssertEqual(Self.baseStampsSut.subtextString, "Redeemed")
    }

    func test_subtextString_for_stamps_voucher_expired_state() {
        Self.stampsVoucherResponse.state = .expired
        mapStampsVoucher()
        XCTAssertEqual(Self.baseStampsSut.subtextString, "Expired")
    }

    func test_subtextString_for_voucher_cancelled_state() {
        Self.stampsVoucherResponse.state = .cancelled
        mapStampsVoucher()
        XCTAssertEqual(Self.baseStampsSut.subtextString, "Cancelled")
    }

    func test_issuedDateString_is_correctly_formatted() {
        mapStampsVoucher()
        var dateIssuedString = String.fromTimestamp((Self.stampsVoucher.dateIssued as NSNumber?)?.doubleValue, withFormat: .dayShortMonthYear24HourSecond, prefix: "plr_voucher_detail_issued_date_prefix".localized)
        XCTAssertEqual(Self.baseStampsSut.issuedDateString, dateIssuedString)

        mapAccumulatorVoucher()
        dateIssuedString = String.fromTimestamp((Self.accumulatorVoucher.dateIssued as NSNumber?)?.doubleValue, withFormat: .dayShortMonthYear24HourSecond, prefix: "plr_voucher_detail_issued_date_prefix".localized)
        XCTAssertEqual(Self.baseAccumulatorSut.issuedDateString, dateIssuedString)
    }

    func test_redeemedDateString_is_correct() {
        mapStampsVoucher()
        var dateRedeemedString = String.fromTimestamp((Self.stampsVoucher.dateRedeemed as NSNumber?)?.doubleValue, withFormat: .dayShortMonthYear24HourSecond, prefix: "plr_voucher_detail_redeemed_date_prefix".localized)
        XCTAssertEqual(Self.baseStampsSut.redeemedDateString, dateRedeemedString)

        mapAccumulatorVoucher()
        dateRedeemedString = String.fromTimestamp((Self.accumulatorVoucher.dateRedeemed as NSNumber?)?.doubleValue, withFormat: .dayShortMonthYear24HourSecond, prefix: "plr_voucher_detail_redeemed_date_prefix".localized)
        XCTAssertEqual(Self.baseAccumulatorSut.redeemedDateString, dateRedeemedString)
    }

    func test_expiredDateString_is_correct() {
        Self.stampsVoucherResponse.state = .expired
        mapStampsVoucher()
        let formattedExpiryDate = String.fromTimestamp((Self.stampsVoucher.expiryDate as NSNumber?)?.doubleValue, withFormat: .dayShortMonthYear24HourSecond, prefix: "plr_voucher_detail_expired_date_prefix".localized)
        let formattedExpiresDate = String.fromTimestamp((Self.stampsVoucher.expiryDate as NSNumber?)?.doubleValue, withFormat: .dayShortMonthYear24HourSecond, prefix: "plr_voucher_detail_expires_date_prefix".localized)

        XCTAssertEqual(Self.baseStampsSut.expiredDateString, formattedExpiryDate)

        Self.stampsVoucherResponse.state = .cancelled
        mapStampsVoucher()
        XCTAssertEqual(Self.baseStampsSut.expiredDateString, formattedExpiryDate)

        Self.stampsVoucherResponse.state = .issued
        mapStampsVoucher()
        XCTAssertEqual(Self.baseStampsSut.expiredDateString, formattedExpiresDate)

        Self.accumulatorVoucherResponse.state = .expired
        mapAccumulatorVoucher()
        XCTAssertEqual(Self.baseStampsSut.expiredDateString, formattedExpiryDate)

        Self.accumulatorVoucherResponse.state = .cancelled
        mapAccumulatorVoucher()
        XCTAssertEqual(Self.baseStampsSut.expiredDateString, formattedExpiryDate)

        Self.accumulatorVoucherResponse.state = .issued
        mapAccumulatorVoucher()
        XCTAssertEqual(Self.baseStampsSut.expiredDateString, formattedExpiresDate)
    }

    func test_shouldShowCode_if_in_issued_state() {
        Self.stampsVoucherResponse.state = .expired
        mapStampsVoucher()
        XCTAssertFalse(Self.baseStampsSut.shouldShowCode)

        Self.stampsVoucherResponse.state = .issued
        mapStampsVoucher()
        XCTAssertTrue(Self.baseStampsSut.shouldShowCode)
    }

    func test_shouldShowHeader_if_string_exists() {
        mapStampsVoucher()
        XCTAssertTrue(Self.baseStampsSut.shouldShowHeader)

        Self.stampsVoucherResponse.state = nil
        mapStampsVoucher()
        XCTAssertFalse(Self.baseStampsSut.shouldShowHeader)
    }

    func test_shouldShowSubtext_if_string_exists() {
        mapStampsVoucher()
        XCTAssertTrue(Self.baseStampsSut.shouldShowSubtext)

        Self.stampsVoucherResponse.state = nil
        mapStampsVoucher()
        XCTAssertFalse(Self.baseStampsSut.shouldShowSubtext)
    }

    func test_shouldShowIssuedDate_for_stamps_voucher() {
        Self.stampsVoucherResponse.state = .issued
        mapStampsVoucher()
        XCTAssertTrue(Self.baseStampsSut.shouldShowIssuedDate)

        Self.stampsVoucherResponse.state = .expired
        mapStampsVoucher()
        XCTAssertTrue(Self.baseStampsSut.shouldShowIssuedDate)

        Self.stampsVoucherResponse.state = .redeemed
        mapStampsVoucher()
        XCTAssertTrue(Self.baseStampsSut.shouldShowIssuedDate)

        Self.stampsVoucherResponse.state = .cancelled
        mapStampsVoucher()
        XCTAssertTrue(Self.baseStampsSut.shouldShowIssuedDate)

        Self.stampsVoucherResponse.state = .inProgress
        mapStampsVoucher()
        XCTAssertFalse(Self.baseStampsSut.shouldShowIssuedDate)

        Self.stampsVoucherResponse.dateIssued = 0
        mapStampsVoucher()
        XCTAssertFalse(Self.baseStampsSut.shouldShowIssuedDate)
    }

    func test_shouldShowIssuedDate_for_accumulator_voucher() {
        Self.accumulatorVoucherResponse.state = .issued
        mapAccumulatorVoucher()
        XCTAssertTrue(Self.baseAccumulatorSut.shouldShowIssuedDate)

        Self.accumulatorVoucherResponse.state = .expired
        mapAccumulatorVoucher()
        XCTAssertTrue(Self.baseAccumulatorSut.shouldShowIssuedDate)

        Self.accumulatorVoucherResponse.state = .redeemed
        mapAccumulatorVoucher()
        XCTAssertFalse(Self.baseAccumulatorSut.shouldShowIssuedDate)

        Self.accumulatorVoucherResponse.state = .cancelled
        mapAccumulatorVoucher()
        XCTAssertTrue(Self.baseAccumulatorSut.shouldShowIssuedDate)

        Self.accumulatorVoucherResponse.state = .inProgress
        mapAccumulatorVoucher()
        XCTAssertFalse(Self.baseAccumulatorSut.shouldShowIssuedDate)

        Self.accumulatorVoucherResponse.dateIssued = 0
        mapAccumulatorVoucher()
        XCTAssertFalse(Self.baseAccumulatorSut.shouldShowIssuedDate)
    }

    func test_shouldShowRedeemedDate_for_redeemed_state() {
        mapStampsVoucher()
        XCTAssertFalse(Self.baseStampsSut.shouldShowRedeemedDate)

        Self.stampsVoucherResponse.state = .redeemed
        mapStampsVoucher()
        XCTAssertTrue(Self.baseStampsSut.shouldShowRedeemedDate)

        Self.stampsVoucherResponse.dateRedeemed = 0
        mapStampsVoucher()
        XCTAssertFalse(Self.baseStampsSut.shouldShowRedeemedDate)
    }

    func test_shouldShowExpiredDate() {
        Self.stampsVoucherResponse.state = .issued
        mapStampsVoucher()
        XCTAssertTrue(Self.baseStampsSut.shouldShowExpiredDate)

        Self.stampsVoucherResponse.state = .expired
        mapStampsVoucher()
        XCTAssertTrue(Self.baseStampsSut.shouldShowExpiredDate)

        Self.stampsVoucherResponse.state = .cancelled
        mapStampsVoucher()
        XCTAssertTrue(Self.baseStampsSut.shouldShowExpiredDate)

        Self.stampsVoucherResponse.state = .redeemed
        mapStampsVoucher()
        XCTAssertFalse(Self.baseStampsSut.shouldShowExpiredDate)

        Self.stampsVoucherResponse.state = .inProgress
        mapStampsVoucher()
        XCTAssertFalse(Self.baseStampsSut.shouldShowExpiredDate)

        Self.stampsVoucherResponse.expiryDate = 0
        mapStampsVoucher()
        XCTAssertFalse(Self.baseStampsSut.shouldShowExpiredDate)
    }

    func test_shouldShowTermsAndConditionsButton_if_voucher() {
        mapStampsVoucher()
        XCTAssertTrue(Self.baseStampsSut.shouldShowTermsAndConditionsButton)

        Self.baseStampsSut.membershipPlan.account?.planDocuments = []
        XCTAssertFalse(Self.baseStampsSut.shouldShowTermsAndConditionsButton)

        let planDocument = PlanDocumentModel(apiId: nil, name: nil, documentDescription: nil, url: nil, display: [.add], checkbox: nil)
        Self.membershipPlanResponse.account?.planDocuments = [planDocument]
        mapStampsVoucher()
        XCTAssertFalse(Self.baseStampsSut.shouldShowTermsAndConditionsButton)
    }
}
