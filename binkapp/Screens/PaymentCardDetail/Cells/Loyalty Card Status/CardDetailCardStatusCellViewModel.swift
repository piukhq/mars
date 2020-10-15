//
//  PaymentCardDetailLoyaltyCardStatusCellViewModel.swift
//  binkapp
//
//  Created by Nick Farrant on 05/11/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

struct CardDetailCardStatusCellViewModel: CardDetailCardCellViewModelProtocol {
    enum State {
        case pll
        case paymentCardDetail
    }

    var membershipCard: CD_MembershipCard?
    var paymentCard: CD_PaymentCard?
    
    private var state: State {
        return membershipCard == nil ? .pll : .paymentCardDetail
    }

    init(membershipCard: CD_MembershipCard) {
        self.membershipCard = membershipCard
    }
    
    init(paymentCard: CD_PaymentCard) {
        self.paymentCard = paymentCard
    }

    var headerText: String? {
        switch state {
        case .paymentCardDetail:
            return membershipCard?.membershipPlan?.account?.companyName
        case .pll:
            return "yo yo yo"
        }
    }

    var detailText: String? {
        switch state {
        case .paymentCardDetail:
            switch membershipCard?.status?.status {
            case .unauthorised, .failed, .pending:
                return nil
            default:
                return "pdc_you_can_link".localized
            }
        case .pll:
            return "yo yo yo"
        }
    }
    
    var membershipCardStatus: MembershipCardStatus? {
        return membershipCard?.status?.status
    }
    
    var paymentCardStatus: PaymentCardStatus? {
        return paymentCard?.paymentCardStatus
    }
    
    var statusText: String? {
        switch state {
        case .paymentCardDetail:
            switch membershipCard?.status?.status {
            case .unauthorised, .failed:
                return "retry_title".localized
            default:
                return membershipCard?.status?.status?.rawValue.capitalized
            }
        case .pll:
            return "yo yo yo"
        }
    }
}
