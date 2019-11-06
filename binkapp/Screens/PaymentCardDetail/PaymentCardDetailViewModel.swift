//
//  PaymentCardDetailViewModel.swift
//  binkapp
//
//  Created by Nick Farrant on 03/10/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

class PaymentCardDetailViewModel {
    private var paymentCard: CD_PaymentCard
    private let router: MainScreenRouter
    private let repository: PaymentCardDetailRepository
    private let informationRowFactory: PaymentCardDetailInformationRowFactory

    init(paymentCard: CD_PaymentCard, router: MainScreenRouter, repository: PaymentCardDetailRepository, informationRowFactory: PaymentCardDetailInformationRowFactory) {
        self.paymentCard = paymentCard
        self.router = router
        self.repository = repository
        self.informationRowFactory = informationRowFactory
    }

    // MARK: - Header views

    var navigationViewTitleText: String {
        return paymentCard.card?.nameOnCard ?? ""
    }

    var navigationViewDetailText: String {
        return "•••• \(paymentCard.card?.lastFour ?? "")"
    }

    var addedCardsTitle: String {
        return "Linked cards"
    }

    var addedCardsDescription: String {
        return "The active loyalty cards below are linked to this payment card. Simply pay as usual to collect points."
    }

    var otherCardsTitle: String {
        return shouldShowAddedLoyaltyCardTableView ? "Other cards you can add" : "No linked cards"
    }

    var otherCardsDescription: String {
        return shouldShowAddedLoyaltyCardTableView ? "You can also add the cards below and link them to your payment cards." : "You do not have any linked loyalty cards. Add some cards to collect points."
    }

    var paymentCardCellViewModel: PaymentCardCellViewModel {
        return PaymentCardCellViewModel(paymentCard: paymentCard)
    }

    // MARK: - PLL plan decisioning

    func statusForMembershipCard(atIndexPath indexPath: IndexPath) -> CD_MembershipCardStatus? {
        // TODO: rename linkable membership cards
        return linkableMembershipCards?[indexPath.row].status
    }

    var shouldShowAddedLoyaltyCardTableView: Bool {
        return pllEnabledMembershipCardsCount != 0
    }

    var shouldShowOtherCardsTableView: Bool {
        return pllPlansNotAddedToWallet?.count != 0
    }

    var pllEnabledMembershipPlans: [CD_MembershipPlan]? {
        return Current.wallet.membershipPlans?.filter { $0.featureSet?.planCardType == .link }
    }

    var pllPlansAddedToWallet: [CD_MembershipPlan]? {
        guard let pllMembershipCards = linkableMembershipCards else { return nil }

        var plansInWallet: [CD_MembershipPlan] = []

        /// For each membership card added to the wallet, track it's membership plan if not tracked already
        pllMembershipCards.forEach {
            if let plan = $0.membershipPlan {
                if !plansInWallet.contains(plan) {
                    plansInWallet.append(plan)
                }
            }
        }
        return plansInWallet
    }

    var pllPlansNotAddedToWallet: [CD_MembershipPlan]? {
        guard let pllEnabledPlans = pllEnabledMembershipPlans else { return nil }

        var plansNotInWallet: [CD_MembershipPlan] = []

        /// For each pll enabled membership plan, if it doesn't exist in the plans already added, add it here
        pllEnabledPlans.forEach {
            if let addedPlans = pllPlansAddedToWallet {
                if !addedPlans.contains($0) {
                    plansNotInWallet.append($0)
                }
            }
        }

        return plansNotInWallet
    }

    // MARK: - Linked cards

    var linkableMembershipCards: [CD_MembershipCard]? {
        // TODO: this should have the same sort as in the loyalty wallet
        return Current.wallet.membershipCards?.filter( { $0.membershipPlan?.featureSet?.planCardType == .link })
    }

    var pllEnabledMembershipCardsCount: Int {
        return linkableMembershipCards?.count ?? 0
    }

    var linkedMembershipCardIds: [String]? {
        let membershipCards = paymentCard.linkedMembershipCards as? Set<CD_MembershipCard>
        return membershipCards?.map { $0.id }
    }

    func membershipCardIsLinked(_ membershipCard: CD_MembershipCard) -> Bool {
        return linkedMembershipCardIds?.contains(membershipCard.id) ?? false
    }

    func membershipCard(forIndexPath indexPath: IndexPath) -> CD_MembershipCard? {
        return linkableMembershipCards?[indexPath.row]
    }

    // MARK: Information rows

    var informationRows: [CardDetailInformationRow] {
        return informationRowFactory.makeInformationRows()
    }

    func informationRow(forIndexPath indexPath: IndexPath) -> CardDetailInformationRow {
        return informationRows[indexPath.row]
    }

    func performActionForInformationRow(atIndexPath indexPath: IndexPath) {
        informationRows[indexPath.row].action()
    }

    func toSecurityAndPrivacyScreen() {
        router.toPrivacyAndSecurityViewController()
    }

    func deletePaymentCard() {
        router.showDeleteConfirmationAlert(withMessage: "delete_card_confirmation".localized, yesCompletion: { [weak self] in
            guard let self = self else { return }
            self.repository.delete(self.paymentCard) {
                Current.wallet.refreshLocal()
                self.router.popToRootViewController()
            }
        }, noCompletion: {})
    }

    // MARK: - Repository

    func toggleLinkForMembershipCard(_ membershipCard: CD_MembershipCard, completion: @escaping () -> Void) {
        if membershipCardIsLinked(membershipCard) {
            removeLinkToMembershipCard(membershipCard, completion: completion)
        } else {
            linkMembershipCard(withId: membershipCard.id, completion: completion)
        }
    }

    func getLinkedMembershipCards(completion: @escaping () -> Void) {
        repository.getPaymentCard(forId: paymentCard.id) { [weak self] paymentCard in
            // If we don't get a payment card back, we'll fail silently by firing the same completion handler anyway.
            // The completion will always be to reload the views, so we will just see the local data.
            if let paymentCard = paymentCard {
                self?.paymentCard = paymentCard
            }

            completion()
        }
    }

    private func linkMembershipCard(withId membershipCardId: String, completion: @escaping () -> Void) {
        repository.linkMembershipCard(withId: membershipCardId, toPaymentCardWithId: paymentCard.id) { [weak self] paymentCard in
            // If we don't get a payment card back, we'll fail silently by firing the same completion handler anyway.
            // The completion will always be to reload the views, so we will just see the local data.
            if let paymentCard = paymentCard {
                self?.paymentCard = paymentCard
            }

            completion()
        }
    }

    private func removeLinkToMembershipCard(_ membershipCard: CD_MembershipCard, completion: @escaping () -> Void) {
        repository.removeLinkToMembershipCard(membershipCard, forPaymentCard: paymentCard) { [weak self] paymentCard in
            if let paymentCard = paymentCard {
                self?.paymentCard = paymentCard
            }

            completion()
        }
    }
}
