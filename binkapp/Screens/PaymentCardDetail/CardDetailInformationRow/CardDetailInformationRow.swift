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
        case faqs

        var title: String {
            switch self {
            case .about(let card):
                if let planName = card.membershipPlan?.account?.planName {
                    return L10n.aboutCustomTitle(planName)
                } else {
                    return L10n.infoTitle
                }
            case .securityAndPrivacy:
                return "Security and privacy"
            case .deleteMembershipCard(let card):
                if let planNameCard = card.membershipPlan?.account?.planNameCard {
                    return L10n.deleteCardPlanTitle(planNameCard)
                } else {
                    return L10n.deleteCardTitle
                }
            case .deletePaymentCard:
                return "Delete this card"
            case .rewardsHistory:
                return "Rewards history"
            case .faqs:
                return "FAQs"
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
            case .faqs:
                return "Learn more"
            }
        }
    }
}

protocol CardDetailInformationRowFactory {
    func makeLoyaltyInformationRows(membershipCard: CD_MembershipCard) -> [CardDetailInformationRow]
    func makePaymentInformationRows(for status: PaymentCardStatus) -> [CardDetailInformationRow]
}

protocol CardDetailInformationRowFactoryDelegate: AnyObject {
    func cardDetailInformationRowFactory(_ factory: WalletCardDetailInformationRowFactory, shouldPerformActionForRowType informationRowType: CardDetailInformationRow.RowType)
}

class WalletCardDetailInformationRowFactory: CardDetailInformationRowFactory {
    weak var delegate: CardDetailInformationRowFactoryDelegate?

    func makeLoyaltyInformationRows(membershipCard: CD_MembershipCard) -> [CardDetailInformationRow] {
        guard let plan = membershipCard.membershipPlan else {
            return []
        }
        if plan.isPLR {
            return [makeRewardsHistoryRow(), makeAboutPlanRow(membershipCard: membershipCard), makeSecurityAndPrivacyRow(), makeDeleteMembershipCardRow(membershipCard: membershipCard)]
        }
        return [makeAboutPlanRow(membershipCard: membershipCard), makeSecurityAndPrivacyRow(), makeDeleteMembershipCardRow(membershipCard: membershipCard)]
    }

    func makePaymentInformationRows(for status: PaymentCardStatus) -> [CardDetailInformationRow] {
        switch status {
        case .active:
            return [makeSecurityAndPrivacyRow(), makeDeletePaymentCardRow()]
        case .failed, .pending:
            return [makeSecurityAndPrivacyRow(), makeDeletePaymentCardRow(), makeFAQsRow()]
        }
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
    
    private func makeFAQsRow() -> CardDetailInformationRow {
        return CardDetailInformationRow(type: .faqs) { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.delegate?.cardDetailInformationRowFactory(self, shouldPerformActionForRowType: .faqs)
            }
        }
    }
}
