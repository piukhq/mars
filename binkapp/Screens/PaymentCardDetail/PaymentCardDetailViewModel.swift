//
//  PaymentCardDetailViewModel.swift
//  binkapp
//
//  Created by Nick Farrant on 03/10/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

class PaymentCardDetailViewModel {
    typealias EmptyCompletionBlock = () -> Void

    private var paymentCard: CD_PaymentCard {
        didSet {
            buildInformationRows()
        }
    }
    private let repository = PaymentCardDetailRepository()
    private let informationRowFactory: WalletCardDetailInformationRowFactory

    init(paymentCard: CD_PaymentCard, informationRowFactory: WalletCardDetailInformationRowFactory) {
        self.paymentCard = paymentCard
        self.informationRowFactory = informationRowFactory
        buildInformationRows()
    }

    var informationRows: [CardDetailInformationRow] = []

    var paymentCardStatus: PaymentCardStatus {
        return paymentCard.paymentCardStatus
    }
    
    var paymentCardIsActive: Bool {
        return paymentCardStatus == .active
    }
    
    var pendingRefreshInterval: TimeInterval {
        return 30
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
        switch paymentCardStatus {
        case .active:
            return L10n.pcdActiveCardTitle
        case .pending:
            return paymentCard.isExpired ? L10n.pcdFailedCardTitle : L10n.pcdPendingCardTitle
        case .failed:
            return L10n.pcdFailedCardTitle
        }
    }

    var addedCardsDescription: String {
        switch paymentCardStatus {
        case .active:
            return L10n.pcdActiveCardDescription
        case .pending:
            return paymentCard.isExpired ? L10n.pcdFailedCardDescription : L10n.pcdPendingCardDescription
        case .failed:
            return L10n.pcdFailedCardDescription
        }
    }
    
    
    var cardAddedDateString: String? {
        guard let timestamp = paymentCard.account?.formattedConsents?.first?.timestamp?.doubleValue else { return nil }
        guard let timestampString = String.fromTimestamp(timestamp, withFormat: .dayMonthYear) else { return nil }
        return L10n.pcdPendingCardAdded(timestampString)
    }

    var otherCardsTitle: String {
        return shouldShowAddedLoyaltyCardTableView ? L10n.pcdOtherCardTitleCardsAdded : L10n.pcdOtherCardTitleNoCardsAdded
    }

    var otherCardsDescription: String {
        return shouldShowAddedLoyaltyCardTableView ? L10n.pcdOtherCardDescriptionCardsAdded : L10n.pcdOtherCardDescriptionNoCardsAdded
    }

    // MARK: - View configuration decisioning
    
    var shouldShowPaymentCardCell: Bool {
        return true
    }
    
    var shouldShowAddedCardsTitleLabel: Bool {
        switch paymentCardStatus {
        case .active:
            return shouldShowAddedLoyaltyCardTableView
        default: return true
        }
    }
    
    var shouldShowAddedCardsDescriptionLabel: Bool {
        return shouldShowAddedCardsTitleLabel
    }
    
    var shouldShowOtherCardsTitleLabel: Bool {
        switch paymentCardStatus {
        case .active:
            return shouldShowOtherCardsTableView
        default: return false
        }
    }
    
    var shouldShowOtherCardsDescriptionLabel: Bool {
        shouldShowOtherCardsTitleLabel
    }
    
    var shouldShowCardAddedLabel: Bool {
        return paymentCardStatus == .pending && !paymentCard.isExpired
    }

    var shouldShowAddedLoyaltyCardTableView: Bool {
        return paymentCardStatus == .active && pllMembershipCardsCount != 0
    }

    var shouldShowOtherCardsTableView: Bool {
        guard let plans = pllPlansNotAddedToWallet else { return false }
        return paymentCardStatus == .active && !plans.isEmpty
    }
    
    var shouldShowInformationTableView: Bool {
        return true
    }
    
    var shouldShowSeparator: Bool {
        return paymentCardStatus != .active
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
        return Current.wallet.membershipCards?.filter { $0.membershipPlan?.featureSet?.planCardType == .link }
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
        Current.navigate.back(toRoot: true) {
            let tabNavigationRequest = TabBarNavigationRequest(tab: .loyalty, popToRoot: true) {
                let viewController = ViewControllerFactory.makeLoyaltyCardDetailViewController(membershipCard: membershipCard)
                let pushNavigationRequest = PushNavigationRequest(viewController: viewController)
                Current.navigate.to(pushNavigationRequest)
            }
            Current.navigate.to(tabNavigationRequest)
        }
    }

    func toAddOrJoin(forMembershipPlan membershipPlan: CD_MembershipPlan) {
        Current.navigate.back(toRoot: true) {
            let viewController = ViewControllerFactory.makeAddOrJoinViewController(membershipPlan: membershipPlan)
            let navigationRequest = ModalNavigationRequest(viewController: viewController)
            Current.navigate.to(navigationRequest)
        }
    }

    // MARK: Information rows
    private func buildInformationRows() {
        informationRows = informationRowFactory.makePaymentInformationRows(for: paymentCardStatus)
    }

    func informationRow(forIndexPath indexPath: IndexPath) -> CardDetailInformationRow {
        return informationRows[indexPath.row]
    }

    func performActionForInformationRow(atIndexPath indexPath: IndexPath) {
        informationRows[safe: indexPath.row]?.action()
    }

    func toSecurityAndPrivacyScreen() {
        let title: String = L10n.securityAndPrivacyTitle
        let description: String = L10n.securityAndPrivacyDescription
        let configuration = ReusableModalConfiguration(title: title, text: ReusableModalConfiguration.makeAttributedString(title: title, description: description))
        let viewController = ViewControllerFactory.makeSecurityAndPrivacyViewController(configuration: configuration)
        let navigationRequest = ModalNavigationRequest(viewController: viewController)
        Current.navigate.to(navigationRequest)
    }
    
    func toFAQsScreen() {
        let viewController = ZendeskService.makeFAQViewController()
        let navigationRequest = ModalNavigationRequest(viewController: viewController, hideCloseButton: true)
        Current.navigate.to(navigationRequest)
    }
    
    func showDeleteConfirmationAlert() {
        let alert = ViewControllerFactory.makeDeleteConfirmationAlertController(message: L10n.deleteCardConfirmation, deleteAction: { [weak self] in
            guard let self = self else { return }
            guard Current.apiClient.networkIsReachable else {
                let alert = ViewControllerFactory.makeNoConnectivityAlertController()
                let navigationRequest = AlertNavigationRequest(alertController: alert)
                Current.navigate.to(navigationRequest)
                return
            }
            self.repository.delete(self.paymentCard) {
                if #available(iOS 14.0, *) {
                    BinkLogger.infoPrivateHash(event: PaymentCardLoggerEvent.paymentCardDeleted, value: self.paymentCard.id)
                }
                Current.wallet.refreshLocal()
                Current.navigate.back()
            }
        })
        let navigationRequest = AlertNavigationRequest(alertController: alert)
        Current.navigate.to(navigationRequest)
    }

    // MARK: - Repository
    
    func refreshPaymentCard(completion: @escaping EmptyCompletionBlock) {
        repository.getPaymentCard(forId: paymentCard.id) { paymentCard in
            if let paymentCard = paymentCard {
                self.paymentCard = paymentCard
            }
            completion()
        }
    }

    func toggleLinkForMembershipCard(_ membershipCard: CD_MembershipCard, completion: @escaping () -> Void) {
        guard Current.apiClient.networkIsReachable else {
            let alert = ViewControllerFactory.makeNoConnectivityAlertController()
            let navigationRequest = AlertNavigationRequest(alertController: alert)
            Current.navigate.to(navigationRequest)
            completion()
            return
        }
        if membershipCardIsLinked(membershipCard) {
            removeLinkToMembershipCard(membershipCard) { error in
                guard let error = error else { return }
                let alert = ViewControllerFactory.makeOkAlertViewController(title: L10n.errorTitle, message: error.message, completion: completion)
                Current.navigate.to(AlertNavigationRequest(alertController: alert))
            }
        } else {
            linkMembershipCard(membershipCard, completion: completion)
        }
    }

    private func linkMembershipCard(_ membershipCard: CD_MembershipCard, completion: @escaping () -> Void) {
        repository.linkMembershipCard(membershipCard, toPaymentCard: paymentCard) { [weak self] paymentCard, error in
            if let error = error, case .userFacingNetworkingError(let networkingError) = error {
                if case .userFacingError(let userFacingError) = networkingError {
                    let message = userFacingError.message(membershipPlan: membershipCard.membershipPlan)
                    let alert = ViewControllerFactory.makeOkAlertViewController(title: userFacingError.title, message: message)
                    let navigationRequest = AlertNavigationRequest(alertController: alert)
                    Current.navigate.to(navigationRequest)
                    completion()
                    return
                }
            }
            
            if let paymentCard = paymentCard {
                self?.paymentCard = paymentCard
            }
            completion()
        }
    }

    private func removeLinkToMembershipCard(_ membershipCard: CD_MembershipCard, completion: @escaping (WalletServiceError?) -> Void) {
        repository.removeLinkToMembershipCard(membershipCard, forPaymentCard: paymentCard) { [weak self] paymentCard, error in
            if let paymentCard = paymentCard {
                self?.paymentCard = paymentCard
            }

            completion(error)
        }
    }
}
