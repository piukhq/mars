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
    var voucher: VoucherModel
    var membershipPlan: MembershipPlanModel

    init(voucher: VoucherModel, plan: MembershipPlanModel) {
        self.voucher = voucher
        self.membershipPlan = plan
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
        switch (voucherEarnType, voucherState) {
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

    var subtextString: String? {
        let burnValue = voucher.burn?.value as NSNumber?

        switch (voucherEarnType, voucherState) {
        case (.accumulator, .inProgress):
            let targetValue = voucher.earn?.targetValue as NSNumber?
            return String(format: "plr_voucher_detail_subtext_inprogress".localized, voucher.earn?.prefix ?? "", targetValue?.twoDecimalPointString() ?? "", voucher.burn?.prefix ?? "", burnValue?.twoDecimalPointString() ?? "", voucher.burn?.type?.rawValue ?? "")
        case (.accumulator, .issued):
            return String(format: "plr_voucher_detail_subtext_issued".localized, voucher.burn?.prefix ?? "", burnValue?.twoDecimalPointString() ?? "", voucher.burn?.suffix ?? "")
        case (.stamps, .inProgress):
            return membershipPlan.dynamicContent?.first(where: { $0.column == DynamicContentColumn.voucherStampsInProgressDetail.rawValue })?.value
        case (.stamps, .issued):
            return membershipPlan.dynamicContent?.first(where: { $0.column == DynamicContentColumn.voucherStampsIssuedDetail.rawValue })?.value
        case (.stamps, .redeemed):
            return membershipPlan.dynamicContent?.first(where: { $0.column == DynamicContentColumn.voucherStampsRedeemedDetail.rawValue })?.value
        case (.stamps, .expired):
            return membershipPlan.dynamicContent?.first(where: { $0.column == DynamicContentColumn.voucherStampsExpiredDetail.rawValue })?.value
        case (.stamps, .cancelled), (.accumulator, .cancelled):
            return membershipPlan.dynamicContent?.first(where: { $0.column == DynamicContentColumn.voucherStampsCancelledDetail.rawValue })?.value
        default:
            return nil
        }
    }
    
    enum DynamicContentColumn: String {
        case voucherStampsExpiredDetail = "Voucher_Expired_Detail"
        case voucherStampsRedeemedDetail = "Voucher_Redeemed_Detail"
        case voucherStampsInProgressDetail = "Voucher_Inprogress_Detail"
        case voucherStampsIssuedDetail = "Voucher_Issued_Detail"
        case voucherStampsCancelledDetail = "Voucher_Cancelled_Detail"
    }

    var issuedDateString: String? {
        let dateIssued = voucher.dateIssued as NSNumber?
        return String.fromTimestamp(dateIssued?.doubleValue, withFormat: .dayShortMonthYear24HourSecond, prefix: "plr_voucher_detail_issued_date_prefix".localized)
    }

    var redeemedDateString: String? {
        let dateRedeemed = voucher.dateRedeemed as NSNumber?
        return String.fromTimestamp(dateRedeemed?.doubleValue, withFormat: .dayShortMonthYear24HourSecond, prefix: "plr_voucher_detail_redeemed_date_prefix".localized)
    }

    var expiredDateString: String? {
        let expiryDate = voucher.expiryDate as NSNumber?
        
        switch voucherState {
        case .expired, .cancelled:
            return String.fromTimestamp(expiryDate?.doubleValue, withFormat: .dayShortMonthYear24HourSecond, prefix: "plr_voucher_detail_expired_date_prefix".localized)
        case .issued:
            return String.fromTimestamp(expiryDate?.doubleValue, withFormat: .dayShortMonthYear24HourSecond, prefix: "plr_voucher_detail_expires_date_prefix".localized)
        default:
            return ""
        }
    }

    var termsAndConditionsButtonTitle: String? {
        guard let document = voucherPlanDocument else { return nil }
        return document.name
    }

    var termsAndConditionsButtonUrlString: String? {
        guard let document = voucherPlanDocument else { return nil }
        return document.url
    }


    // MARK: - View decisioning

    var shouldShowCode: Bool {
        return voucherState == .issued
    }

    var shouldShowHeader: Bool {
        return headerString != nil
    }

    var shouldShowSubtext: Bool {
        return subtextString != nil
    }

    var shouldShowIssuedDate: Bool {
        guard voucher.dateIssued != 0 else { return false }
        switch (voucherEarnType, voucherState) {
        case (_, .issued), (_, .expired), (.stamps, .redeemed), (_, .cancelled):
            return true
        default:
            return false
        }
    }
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

    let voucherAmountText = "voucher"
    
    var voucherState: VoucherState? {
        return voucher.state
    }
    
    var voucherEarnType: VoucherEarnType? {
        return voucher.earn?.type
    }

    private var voucherPlanDocument: PlanDocumentModel? {
        guard let planDocuments = membershipPlan.account?.planDocuments else { return nil }
        for document in planDocuments {
            if let _ = document.display?.first(where: { $0.rawValue == PlanDocumentDisplayModel.voucher.rawValue }) {
                return document
            }
        }
        return nil
    }
}
