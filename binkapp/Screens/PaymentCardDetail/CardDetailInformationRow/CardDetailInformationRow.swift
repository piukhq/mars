//
//  CardDetailInformationRow.swift
//  binkapp
//
//  Created by Nick Farrant on 08/10/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

struct CardDetailInformationRow {
    var type: RowType
    var action: () -> Void

    enum RowType {
        case about(membershipCard: CD_MembershipCard)
        case securityAndPrivacy
        case deleteMembershipCard(membershipCard: CD_MembershipCard)
        case deletePaymentCard
        case rewardsHistory

        var title: String {
            switch self {
            case .about(let card):
                if let planName = card.membershipPlan?.account?.planName {
                    return String(format: "about_custom_title".localized, planName)
                } else {
                    return "info_title".localized
                }
            case .securityAndPrivacy:
                return "Security and privacy"
            case .deleteMembershipCard(let card):
                return "Delete \(card.membershipPlan?.account?.planName ?? "this card")"
            case .deletePaymentCard:
                return "Delete this card"
            case .rewardsHistory:
                return "Rewards history"
            }
        }

        var subtitle: String {
            switch self {
            case .about:
                return "Learn more about how it works"
            case .securityAndPrivacy:
                return "How we protect your data"
            case .deletePaymentCard, .deleteMembershipCard:
                return "Remove this card from Bink"
            case .rewardsHistory:
                return "See your past rewards"
            }
        }
    }
}

protocol CardDetailInformationRowFactory {
    func makeLoyaltyInformationRows(membershipCard: CD_MembershipCard) -> [CardDetailInformationRow]
    func makePaymentInformationRows() -> [CardDetailInformationRow]
}

protocol CardDetailInformationRowFactoryDelegate: AnyObject {
    func cardDetailInformationRowFactory(_ factory: PaymentCardDetailInformationRowFactory, shouldPerformActionForRowType informationRowType: CardDetailInformationRow.RowType)
}

class PaymentCardDetailInformationRowFactory: CardDetailInformationRowFactory {
    weak var delegate: CardDetailInformationRowFactoryDelegate?

    func makeLoyaltyInformationRows(membershipCard: CD_MembershipCard) -> [CardDetailInformationRow] {
        guard let plan = membershipCard.membershipPlan else {
            fatalError("Membership card has no associated plan. We should never be in this state.")
        }
        if plan.isPLR {
            return [makeRewardsHistoryRow(), makeAboutPlanRow(membershipCard: membershipCard), makeSecurityAndPrivacyRow(), makeDeleteMembershipCardRow(membershipCard: membershipCard)]
        }
        return [makeAboutPlanRow(membershipCard: membershipCard), makeSecurityAndPrivacyRow(), makeDeleteMembershipCardRow(membershipCard: membershipCard)]
    }

    func makePaymentInformationRows() -> [CardDetailInformationRow] {
        return [makeSecurityAndPrivacyRow(), makeDeletePaymentCardRow()]
    }

    private func makeRewardsHistoryRow() -> CardDetailInformationRow {
        return CardDetailInformationRow(type: .rewardsHistory) { [weak self] in
            guard let self = self else { return }
            self.delegate?.cardDetailInformationRowFactory(self, shouldPerformActionForRowType: .rewardsHistory)
        }
    }

    private func makeAboutPlanRow(membershipCard: CD_MembershipCard) -> CardDetailInformationRow {
        return CardDetailInformationRow(type: .about(membershipCard: membershipCard)) { [weak self] in
            guard let self = self else { return }
            self.delegate?.cardDetailInformationRowFactory(self, shouldPerformActionForRowType: .about(membershipCard: membershipCard))
        }
    }

    private func makeSecurityAndPrivacyRow() -> CardDetailInformationRow {
        return CardDetailInformationRow(type: .securityAndPrivacy) { [weak self] in
            guard let self = self else { return }
            self.delegate?.cardDetailInformationRowFactory(self, shouldPerformActionForRowType: .securityAndPrivacy)
        }
    }

    private func makeDeleteMembershipCardRow(membershipCard: CD_MembershipCard) -> CardDetailInformationRow {
        return CardDetailInformationRow(type: .deleteMembershipCard(membershipCard: membershipCard)) { [weak self] in
            guard let self = self else { return }
            self.delegate?.cardDetailInformationRowFactory(self, shouldPerformActionForRowType: .deleteMembershipCard(membershipCard: membershipCard))
        }
    }

    private func makeDeletePaymentCardRow() -> CardDetailInformationRow {
        return CardDetailInformationRow(type: .deletePaymentCard) { [weak self] in
            guard let self = self else { return }
            self.delegate?.cardDetailInformationRowFactory(self, shouldPerformActionForRowType: .deletePaymentCard)
        }
    }
}
