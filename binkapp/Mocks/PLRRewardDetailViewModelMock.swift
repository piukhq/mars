//
//  PLRRewardDetailViewModelMock.swift
//  binkapp
//
//  Created by Sean Williams on 13/11/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import Foundation
import UIKit

class PLRRewardDetailViewModelMock {
    private var voucher: VoucherModel
    private var membershipPlan: MembershipPlanModel

    init(voucher: VoucherModel, plan: MembershipPlanModel) {
        self.voucher = voucher
        self.membershipPlan = plan
        
        self.voucher.state = .expired
    }

//    var voucherCellViewModel: PLRCellViewModel {
//        return PLRCellViewModel(voucher: voucher)
//    }

    // MARK: - String values

    var title: String? {
        return membershipPlan.account?.companyName
    }

    var codeString: String? {
        return voucher.code
    }

    var headerString: String? {
        switch (voucher.earn?.type, voucher.state) {
        case (.accumulator, .issued):
            return String(format: "plr_voucher_detail_issued_header".localized, voucherAmountText)
        case (.accumulator, .redeemed):
            return String(format: "plr_voucher_detail_redeemed_header".localized, voucherAmountText)
        case (.accumulator, .expired):
            return String(format: "plr_voucher_detail_expired_header".localized, voucherAmountText)
        case (.stamps, .inProgress):
            return "plr_stamp_voucher_detail_inprogress_header".localized
        case (.stamps, .issued):
            return String(format: "plr_voucher_detail_issued_header".localized, voucherAmountText)
        case (.stamps, .redeemed):
            return "plr_stamp_voucher_detail_redeemed_header".localized
        case (.stamps, .expired):
            return "plr_stamp_voucher_detail_expired_header".localized
        case (.stamps, .cancelled), (.accumulator, .cancelled):
            return "plr_stamp_voucher_detail_cancelled_header".localized
        default:
            return nil
        }
    }
//
//    var subtextString: String? {
//        switch (voucherEarnType, voucherState) {
//        case (.accumulator, .inProgress):
//            return String(format: "plr_voucher_detail_subtext_inprogress".localized, voucher.earn?.prefix ?? "", voucher.earn?.targetValue?.twoDecimalPointString() ?? "", voucher.burn?.prefix ?? "", voucher.burn?.value?.twoDecimalPointString() ?? "", voucher.burn?.type ?? "")
//        case (.accumulator, .issued):
//            return String(format: "plr_voucher_detail_subtext_issued".localized, voucher.burn?.prefix ?? "", voucher.burn?.value?.twoDecimalPointString() ?? "", voucher.burn?.suffix ?? "")
//            
//        case (.stamps, .inProgress):
//            return membershipPlan.dynamicContentValue(forColumn: .voucherStampsInProgressDetail)
//        case (.stamps, .issued):
//            return membershipPlan.dynamicContentValue(forColumn: .voucherStampsIssuedDetail)
//        case (.stamps, .redeemed):
//            return membershipPlan.dynamicContentValue(forColumn: .voucherStampsRedeemedDetail)
//        case (.stamps, .expired):
//            return membershipPlan.dynamicContentValue(forColumn: .voucherStampsExpiredDetail)
//        case (.stamps, .cancelled), (.accumulator, .cancelled):
//            return membershipPlan.dynamicContentValue(forColumn: .voucherStampsCancelledDetail)
//        default:
//            return nil
//        }
//    }

//    var issuedDateString: String? {
//        return String.fromTimestamp(voucher.dateIssued?.doubleValue, withFormat: .dayShortMonthYear24HourSecond, prefix: "plr_voucher_detail_issued_date_prefix".localized)
//    }
//
//    var redeemedDateString: String? {
//        return String.fromTimestamp(voucher.dateRedeemed?.doubleValue, withFormat: .dayShortMonthYear24HourSecond, prefix: "plr_voucher_detail_redeemed_date_prefix".localized)
//    }
//
//    var expiredDateString: String? {
//        switch voucherState {
//        case .expired, .cancelled:
//            return String.fromTimestamp(voucher.expiryDate?.doubleValue, withFormat: .dayShortMonthYear24HourSecond, prefix: "plr_voucher_detail_expired_date_prefix".localized)
//        case .issued:
//            return String.fromTimestamp(voucher.expiryDate?.doubleValue, withFormat: .dayShortMonthYear24HourSecond, prefix: "plr_voucher_detail_expires_date_prefix".localized)
//        default:
//            return ""
//        }
//    }
//
//    var termsAndConditionsButtonTitle: String? {
//        guard let document = voucherPlanDocument else { return nil }
//        return document.name
//    }
//
//    private var termsAndConditionsButtonUrlString: String? {
//        guard let document = voucherPlanDocument else { return nil }
//        return document.url
//    }

//    func openTermsAndConditionsWebView() {
//        guard let url = termsAndConditionsButtonUrlString else { return }
//        let viewController = ViewControllerFactory.makeWebViewController(urlString: url)
//        let navigationRequest = ModalNavigationRequest(viewController: viewController)
//        Current.navigate.to(navigationRequest)
//    }
//
//    // MARK: - View decisioning
//
//    var shouldShowCode: Bool {
//        return voucherState == .issued
//    }
//
//    var shouldShowHeader: Bool {
//        return headerString != nil
//    }
//
//    var shouldShowSubtext: Bool {
//        return subtextString != nil
//    }
//
//    var shouldShowIssuedDate: Bool {
//        guard voucher.dateIssued != 0 else { return false }
//        switch (voucherEarnType, voucherState) {
//        case (_, .issued), (_, .expired), (.stamps, .redeemed), (_, .cancelled):
//            return true
//        default:
//            return false
//        }
//    }
//
//    var shouldShowRedeemedDate: Bool {
//        guard voucher.dateRedeemed != 0 else { return false }
//        return voucherState == .redeemed
//    }
//
//    var shouldShowExpiredDate: Bool {
//        guard voucher.expiryDate != 0 else { return false }
//        switch voucherState {
//        case .expired, .issued, .cancelled:
//            return true
//        default:
//            return false
//        }
//    }

//    var shouldShowTermsAndConditionsButton: Bool {
//        var shouldDisplay = false
//        guard let planDocuments = membershipPlan.account?.formattedPlanDocuments else { return shouldDisplay }
//        for document in planDocuments {
//            for display in document.formattedDisplay {
//                if display.value == PlanDocumentDisplayModel.voucher.rawValue {
//                    shouldDisplay = true
//                    break
//                }
//            }
//        }
//        return shouldDisplay
//    }

    // MARK: - Helpers

//    var voucherState: VoucherState? {
//        return VoucherState(rawValue: voucher.state)
//    }
//
//    var voucherEarnType: VoucherEarnType? {
//        return voucher.earnType
//    }

    var voucherAmountText: String {
        var string = ""
        if let prefix = voucher.burn?.prefix {
            string.append(prefix)
        }
        let voucherBurnValue = Float(voucher.burn?.value ?? 0.0)
        if let value = twoDecimalPointString(floatValue: voucherBurnValue) {
            string.append(value)
        }
        if let suffix = voucher.burn?.suffix {
            string.append(" ")
            string.append(suffix)
        }
        if let type = voucher.burn?.type?.rawValue {
            string.append(" ")
            string.append(type)
        }
        return string
    }
    
    func twoDecimalPointString(floatValue: Float) -> String? {
        guard floatValue.hasDecimals else {
            return "\(self)"
        }
        return String(format: "%.02f", floatValue)
    }
//
//    private var voucherPlanDocument: CD_PlanDocument? {
//        guard let planDocuments = membershipPlan.account?.formattedPlanDocuments else { return nil }
//        for document in planDocuments {
//            if let _ = document.formattedDisplay.first(where: { $0.value == PlanDocumentDisplayModel.voucher.rawValue }) {
//                return document
//            }
//        }
//        return nil
//    }
    
}


