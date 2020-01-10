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
            return String(format: "plr_voucher_detail_subtext_inprogress".localized, voucher.earn?.prefix ?? "", voucher.earn?.targetValue?.twoDecimalPointString() ?? "", voucher.burn?.prefix ?? "", voucher.burn?.value?.twoDecimalPointString() ?? "", voucher.burn?.type ?? "")
        case .issued:
            return String(format: "plr_voucher_detail_subtext_issued".localized, voucher.burn?.prefix ?? "", voucher.burn?.value?.twoDecimalPointString() ?? "", voucher.burn?.suffix ?? "")
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

    var termsAndConditionsButtonTitle: String? {
        guard let document = voucherPlanDocument else { return nil }
        return document.name
    }

    private var termsAndConditionsButtonUrlString: String? {
        guard let document = voucherPlanDocument else { return nil }
        return document.url
    }

    func openTermsAndConditionsUrl() {
        guard let url = termsAndConditionsButtonUrlString else { return }
        MainScreenRouter.openExternalURL(with: url)
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
        guard voucher.dateIssued != 0 else { return false }
        return voucherState == .issued || voucherState == .expired
    }

    var shouldShowRedeemedDate: Bool {
        guard voucher.dateRedeemed != 0 else { return false }
        return voucherState == .redeemed
    }

    var shouldShowExpiredDate: Bool {
        guard voucher.expiryDate != 0 else { return false }
        return voucherState == .expired
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

    var voucherAmountText: String {
        return "\(voucher.burn?.prefix ?? "")\(voucher.burn?.value?.twoDecimalPointString() ?? "")\(voucher.burn?.suffix ?? "") \(voucher.burn?.type ?? "")"
    }

    private var voucherPlanDocument: CD_PlanDocument? {
        guard let planDocuments = membershipPlan.account?.formattedPlanDocuments else { return nil }
        // Currently we assume the only plan document for PLR will be terms and conditions
        // Change this when this is no longer the case
        guard let voucherDocument = planDocuments.first else { return nil }
        guard let display = voucherDocument.formattedDisplay.first else { return nil }
        guard display.value == PlanDocumentDisplayModel.voucher.rawValue else { return nil }
        return voucherDocument
    }
}
