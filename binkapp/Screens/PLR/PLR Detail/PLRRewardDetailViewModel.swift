//
//  PLRRewardDetailViewModel.swift
//  binkapp
//
//  Created by Nick Farrant on 13/11/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

class PLRRewardDetailViewModel {
    private let voucher: CD_Voucher
    private let membershipPlan: CD_MembershipPlan

    init(voucher: CD_Voucher, plan: CD_MembershipPlan) {
        self.voucher = voucher
        self.membershipPlan = plan
    }

    var voucherCellViewModel: PLRCellViewModel {
        return PLRCellViewModel(voucher: voucher)
    }

    // MARK: - String values

    var title: String? {
        return membershipPlan.account?.companyName
    }

    var codeString: String? {
        return voucher.code
    }

    var headerString: String? {
        switch voucherState {
        case .issued:
            return String(format: "plr_voucher_detail_issued_header".localized, voucherAmountText)
        case .redeemed:
            return String(format: "plr_voucher_detail_redeemed_header".localized, voucherAmountText)
        case .expired:
            return String(format: "plr_voucher_detail_expired_header".localized, voucherAmountText)
        default:
            return nil
        }
    }

    var subtextString: String? {
        switch voucherState {
        case .inProgress:
            return String(format: "plr_voucher_detail_subtext_inprogress".localized, voucher.earn?.prefix ?? "", voucher.earn?.targetValue ?? 0.0, voucher.burn?.prefix ?? "", voucher.burn?.value ?? 0.0, voucher.burn?.type ?? "")
        case .issued:
            return String(format: "plr_voucher_detail_subtext_issued".localized, voucher.burn?.prefix ?? "", voucher.burn?.value ?? 0.0, voucher.burn?.suffix ?? "")
        default:
            return nil
        }
    }

    var issuedDateString: String? {
        return String.fromTimestamp(voucher.dateIssued?.doubleValue, withFormat: .dayShortMonthYear24HourSecond, prefix: "plr_voucher_detail_issued_date_prefix".localized)
    }

    var redeemedDateString: String? {
        return String.fromTimestamp(voucher.dateRedeemed?.doubleValue, withFormat: .dayShortMonthYear24HourSecond, prefix: "plr_voucher_detail_redeemed_date_prefix".localized)
    }

    var expiredDateString: String? {
        return String.fromTimestamp(voucher.expiryDate?.doubleValue, withFormat: .dayShortMonthYear24HourSecond, prefix: "plr_voucher_detail_expired_date_prefix".localized)
    }

    // MARK: - View decisioning

    var shouldShowCode: Bool {
        return voucherState != .inProgress
    }

    var shouldShowHeader: Bool {
        return voucherState != .inProgress
    }

    var shouldShowSubtext: Bool {
        return true
    }

    var shouldShowIssuedDate: Bool {
        return voucherState == .issued || voucherState == .expired
    }

    var shouldShowRedeemedDate: Bool {
        return voucherState == .redeemed
    }

    var shouldShowExpiredDate: Bool {
        return voucherState == .expired
    }

    var shouldShowTermsAndConditionsButton: Bool {
        guard let planDocuments = membershipPlan.account?.formattedPlanDocuments else { return false }
        var shouldDisplay = false
        planDocuments.forEach {
            if $0.display.contains(LinkingSupportType.voucher.rawValue) {
                shouldDisplay = true
            }
        }
        return shouldDisplay
    }

    // MARK: - Helpers

    var voucherState: VoucherState? {
        return VoucherState(rawValue: voucher.state ?? "")
    }

    var voucherAmountText: String {
        return "\(voucher.burn?.prefix ?? "")\(voucher.burn?.value ?? 0.0)\(voucher.burn?.suffix ?? "") \(voucher.burn?.type ?? "")"
    }
}
