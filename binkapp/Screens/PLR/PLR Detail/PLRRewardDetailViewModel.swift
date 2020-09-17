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
            var formattedText = ""
            formattedText.append(voucher.burn?.prefix ?? "")
            
            // We store burn value as 0 by default if the API returns nothing
            // We can safely assume that no burn value will ever be 0, so we can guard against it here
            if let burnValue = voucher.burn?.value, burnValue != 0 {
                formattedText.append(String(describing: burnValue))
            }
            formattedText.append(" ")
            formattedText.append(voucher.burn?.suffix ?? "")
            return String(format: "plr_stamp_voucher_detail_issued_header".localized, formattedText)
        case (.stamps, .redeemed):
            return "plr_stamp_voucher_detail_redeemed_header".localized
        case (.stamps, .expired):
            return "plr_stamp_voucher_detail_expired_header".localized
        default:
            return nil
        }
    }

    var subtextString: String? {
        switch (voucherEarnType, voucherState) {
        case (.accumulator, .inProgress):
            return String(format: "plr_voucher_detail_subtext_inprogress".localized, voucher.earn?.prefix ?? "", voucher.earn?.targetValue?.twoDecimalPointString() ?? "", voucher.burn?.prefix ?? "", voucher.burn?.value?.twoDecimalPointString() ?? "", voucher.burn?.type ?? "")
        case (.accumulator, .issued):
            return String(format: "plr_voucher_detail_subtext_issued".localized, voucher.burn?.prefix ?? "", voucher.burn?.value?.twoDecimalPointString() ?? "", voucher.burn?.suffix ?? "")
            
        case (.stamps, .inProgress):
            return membershipPlan.dynamicContentValue(forColumn: .voucherStampsInProgressDetail)
        case (.stamps, .issued):
            return membershipPlan.dynamicContentValue(forColumn: .voucherStampsIssuedDetail)
        case (.stamps, .redeemed):
            return membershipPlan.dynamicContentValue(forColumn: .voucherStampsRedeemedDetail)
        case (.stamps, .expired):
            return membershipPlan.dynamicContentValue(forColumn: .voucherStampsExpiredDetail)
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
        switch voucherState {
        case .expired:
            return String.fromTimestamp(voucher.expiryDate?.doubleValue, withFormat: .dayShortMonthYear24HourSecond, prefix: "plr_voucher_detail_expired_date_prefix".localized)
        case .issued:
            return String.fromTimestamp(voucher.expiryDate?.doubleValue, withFormat: .dayShortMonthYear24HourSecond, prefix: "plr_voucher_detail_expires_date_prefix".localized)
        default:
            return ""
        }
    }

    var termsAndConditionsButtonTitle: String? {
        guard let document = voucherPlanDocument else { return nil }
        return document.name
    }

    private var termsAndConditionsButtonUrlString: String? {
        guard let document = voucherPlanDocument else { return nil }
        return document.url
    }

    func openTermsAndConditionsWebView() {
//        guard let url = termsAndConditionsButtonUrlString else { return }
//        router.openWebView(withUrlString: url)
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
        case (_, .issued), (_, .expired), (.stamps, .redeemed):
            return true
        default:
            return false
        }
    }

    var shouldShowRedeemedDate: Bool {
        guard voucher.dateRedeemed != 0 else { return false }
        return voucherState == .redeemed
    }

    var shouldShowExpiredDate: Bool {
        guard voucher.expiryDate != 0 else { return false }
        return voucherState == .expired || voucherState == .issued
    }

    var shouldShowTermsAndConditionsButton: Bool {
        var shouldDisplay = false
        guard let planDocuments = membershipPlan.account?.formattedPlanDocuments else { return shouldDisplay }
        for document in planDocuments {
            for display in document.formattedDisplay {
                if display.value == PlanDocumentDisplayModel.voucher.rawValue {
                    shouldDisplay = true
                    break
                }
            }
        }
        return shouldDisplay
    }

    // MARK: - Helpers

    var voucherState: VoucherState? {
        return VoucherState(rawValue: voucher.state ?? "")
    }

    var voucherEarnType: VoucherEarnType? {
        return voucher.earnType
    }

    var voucherAmountText: String {
        return "\(voucher.burn?.prefix ?? "")\(voucher.burn?.value?.twoDecimalPointString() ?? "")\(voucher.burn?.suffix ?? "") \(voucher.burn?.type ?? "")"
    }

    private var voucherPlanDocument: CD_PlanDocument? {
        guard let planDocuments = membershipPlan.account?.formattedPlanDocuments else { return nil }
        for document in planDocuments {
            if let _ = document.formattedDisplay.first(where: { $0.value == PlanDocumentDisplayModel.voucher.rawValue }) {
                return document
            }
        }
        return nil
    }
}
