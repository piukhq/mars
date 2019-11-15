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
    private(set) var router: MainScreenRouter
    private let repository: PaymentCardDetailRepository
    private let informationRowFactory: PaymentCardDetailInformationRowFactory

    init(paymentCard: CD_PaymentCard, router: MainScreenRouter, repository: PaymentCardDetailRepository, informationRowFactory: PaymentCardDetailInformationRowFactory) {
        self.paymentCard = paymentCard
        self.router = router
        self.repository = repository
        self.informationRowFactory = informationRowFactory
    }

    // MARK: - Header views

    var paymentCardCellViewModel: PaymentCardCellViewModel {
        return PaymentCardCellViewModel(paymentCard: paymentCard)
    }

    var navigationViewTitleText: String {
        return paymentCard.card?.nameOnCard ?? ""
    }

    var navigationViewDetailText: String {
        return "•••• \(paymentCard.card?.lastFour ?? "")"
    }

    var addedCardsTitle: String {
        return "pcd_added_card_title".localized
    }

    var addedCardsDescription: String {
        return "pcd_added_card_description".localized
    }

    var otherCardsTitle: String {
        return shouldShowAddedLoyaltyCardTableView ? "pcd_other_card_title_cards_added".localized : "pcd_other_card_title_no_cards_added".localized
    }

    var otherCardsDescription: String {
        return shouldShowAddedLoyaltyCardTableView ? "pcd_other_card_description_cards_added".localized : "pcd_other_card_description_no_cards_added".localized
    }

    // MARK: - View configuration decisioning

    var shouldShowAddedLoyaltyCardTableView: Bool {
        return pllMembershipCardsCount != 0
    }

    var shouldShowOtherCardsTableView: Bool {
        return pllPlansNotAddedToWallet?.count != 0
    }

    // MARK: PLL membership plans

    var pllMembershipPlans: [CD_MembershipPlan]? {
        return Current.wallet.membershipPlans?.filter { $0.featureSet?.planCardType == .link }
    }

    var pllPlansAddedToWallet: [CD_MembershipPlan]? {
        guard let pllMembershipCards = pllMembershipCards else { return nil }

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
        guard let pllEnabledPlans = pllMembershipPlans else { return nil }

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

    var pllPlansNotAddedToWalletCount: Int {
        return pllPlansNotAddedToWallet?.count ?? 0
    }

    func pllPlanNotAddedToWallet(forIndexPath indexPath: IndexPath) -> CD_MembershipPlan? {
        return pllPlansNotAddedToWallet?[indexPath.row]
    }

    // MARK: - PLL membership cards in wallet

    var pllMembershipCards: [CD_MembershipCard]? {
        // TODO: this should have the same sort as in the loyalty wallet
        return Current.wallet.membershipCards?.filter( { $0.membershipPlan?.featureSet?.planCardType == .link })
    }

    var pllMembershipCardsCount: Int {
        return pllMembershipCards?.count ?? 0
    }

    var linkedMembershipCardIds: [String]? {
        let membershipCards = paymentCard.linkedMembershipCards as? Set<CD_MembershipCard>
        return membershipCards?.map { $0.id }
    }

    func membershipCardIsLinked(_ membershipCard: CD_MembershipCard) -> Bool {
        return linkedMembershipCardIds?.contains(membershipCard.id) ?? false
    }

    func membershipCard(forIndexPath indexPath: IndexPath) -> CD_MembershipCard? {
        return pllMembershipCards?[indexPath.row]
    }

    func statusForMembershipCard(atIndexPath indexPath: IndexPath) -> CD_MembershipCardStatus? {
        return pllMembershipCards?[indexPath.row].status
    }

    // MARK: Routing

    func toCardDetail(forMembershipCard membershipCard: CD_MembershipCard) {
        router.toLoyaltyFullDetailsScreen(membershipCard: membershipCard)
    }

    func toAddOrJoin(forMembershipPlan membershipPlan: CD_MembershipPlan) {
        router.toAddOrJoinViewController(membershipPlan: membershipPlan)
    }

    // MARK: Information rows

    var informationRows: [CardDetailInformationRow] {
        return informationRowFactory.makePaymentInformationRows()
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
