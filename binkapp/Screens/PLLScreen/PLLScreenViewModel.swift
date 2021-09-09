//
//  PLLViewModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit
import CardScan

class PLLScreenViewModel {
    private var membershipCard: CD_MembershipCard
    private let repository = PLLScreenRepository()
    private weak var delegate: LoyaltyCardFullDetailsModalDelegate?
    
    let journey: PllScreenJourney
    
    var activePaymentCards: [CD_PaymentCard]? {
        return Current.wallet.paymentCards?.filter { $0.paymentCardStatus == .active && !$0.isExpired }
    }
    
    var pendingPaymentCards: [CD_PaymentCard]? {
        return Current.wallet.paymentCards?.filter { $0.paymentCardStatus == .pending && !$0.isExpired }
    }
    
    var hasActivePaymentCards: Bool {
        guard let activePaymentCards = activePaymentCards else { return false }
        return !activePaymentCards.isEmpty
    }
    
    private(set) var changedLinkCards: [CD_PaymentCard] = []
    
    var shouldShowActivePaymentCards: Bool {
        return hasActivePaymentCards
    }
    
    var shouldShowPendingPaymentCards: Bool {
        guard let pendingPaymentCards = pendingPaymentCards else { return false }
        return !pendingPaymentCards.isEmpty
    }
    
    var isEmptyPll: Bool {
        return !shouldShowActivePaymentCards
    }
    
    var shouldShowBackButton: Bool {
        return journey != .newCard
    }
    
    var linkedPaymentCards: [CD_PaymentCard]? {
        let paymentCards = membershipCard.linkedPaymentCards.allObjects as? [CD_PaymentCard]
        return paymentCards
    }
    
    var titleText: String {
        return L10n.pllScreenLinkTitle
    }
    
    var primaryMessageText: String {
        return isEmptyPll ? L10n.pllScreenLinkMessage : L10n.pllScreenAddMessage(membershipCard.membershipPlan?.account?.planNameCard ?? "")
    }
    
    var secondaryMessageText: String {
        return L10n.pllScreenSecondaryMessage
    }
    
    var shouldAllowDismiss: Bool {
        return !hasActivePaymentCards
    }
        
    init(membershipCard: CD_MembershipCard, journey: PllScreenJourney, delegate: LoyaltyCardFullDetailsModalDelegate? = nil) {
        self.membershipCard = membershipCard
        self.journey = journey
        self.delegate = delegate
    }
    
    // MARK: - Public methods
    
    func addCardToChangedCardsArray(card: CD_PaymentCard) {
        if !(changedLinkCards.contains(card)) {
            changedLinkCards.append(card)
        } else {
            if let index = changedLinkCards.firstIndex(of: card) {
                changedLinkCards.remove(at: index)
            }
        }
    }
    
    func toggleLinkForMembershipCards(completion: @escaping (Bool) -> Void) {
        if changedLinkCards.isEmpty {
            /// This journey requires a PPL linkage to take place. Otherwise, end the journey.
            PllLoyaltyInAppReviewableJourney.end()
        }

        repository.toggleLinkForPaymentCards(membershipCard: membershipCard, changedLinkCards: changedLinkCards, onSuccess: {
            completion(true)
        }) { [weak self] error in
            guard let error = error else { return }
            switch error {
            case .userFacingNetworkingError(let networkingError):
                if case .userFacingError(let userFacingError) = networkingError {
                    let messagePrefix = self?.changedLinkCards.count == 1 ? L10n.cardAlreadyLinkedMessagePrefix : L10n.cardsAlreadyLinkedMessagePrefix
                    let planName = self?.membershipCard.membershipPlan?.account?.planName ?? ""
                    let planNameCard = self?.membershipCard.membershipPlan?.account?.planNameCard ?? ""
                    let planDetails = "\(planName) \(planNameCard)"
                    let formattedString = String(format: userFacingError.message, messagePrefix, planDetails, planDetails)
                    self?.displaySimplePopup(title: userFacingError.title, message: formattedString, completion: {
                        completion(false)
                    })
                }
            case .customError(let message):
                self?.displaySimplePopup(title: L10n.errorTitle, message: message, completion: {
                    completion(false)
                })
            default:
                break
            }
        }
    }
    
    func getMembershipPlan() -> CD_MembershipPlan? {
        return membershipCard.membershipPlan
    }
    
    func getMembershipCard() -> CD_MembershipCard {
        return membershipCard
    }
    
    func brandHeaderWasTapped() {
        guard let plan = membershipCard.membershipPlan else { return }
        let viewController = ViewControllerFactory.makeAboutMembershipPlanViewController(membershipPlan: plan)
        let navigationRequest = ModalNavigationRequest(viewController: viewController)
        Current.navigate.to(navigationRequest)
    }
    
    func displaySimplePopup(title: String?, message: String?, completion: @escaping () -> Void) {
        let alert = ViewControllerFactory.makeOkAlertViewController(title: title, message: message, completion: completion)
        Current.navigate.to(AlertNavigationRequest(alertController: alert))
    }
    
    func displayNoConnectivityPopup(completion: @escaping () -> Void) {
        let alert = ViewControllerFactory.makeNoConnectivityAlertController(completion: completion)
        let navigationRequest = AlertNavigationRequest(alertController: alert)
        Current.navigate.to(navigationRequest)
    }
    
    func close() {
        delegate?.modalWillDismiss()
        Current.navigate.close()
    }
    
    func toPaymentScanner(delegate: ScanDelegate?) {
        guard let viewController = ViewControllerFactory.makePaymentCardScannerViewController(strings: Current.paymentCardScannerStrings, delegate: delegate) else { return }
        PermissionsUtility.launchPaymentScanner(viewController) {
            let navigationRequest = ModalNavigationRequest(viewController: viewController)
            Current.navigate.to(navigationRequest)
        } enterManuallyAction: { [weak self] in
            self?.toAddPaymentCardScreen()
        }
    }
    
    func toAddPaymentCardScreen(model: PaymentCardCreateModel? = nil) {
        let viewController = ViewControllerFactory.makeAddPaymentCardViewController(model: model, journey: .pll)
        let navigationRequest = ModalNavigationRequest(viewController: viewController)
        Current.navigate.to(navigationRequest)
    }

    func toFAQScreen() {
        let viewController = ZendeskService.makeFAQViewController()
        let navigationRequest = ModalNavigationRequest(viewController: viewController, hideCloseButton: true)
        Current.navigate.to(navigationRequest)
    }
}

extension PLLScreenViewModel: CoreDataRepositoryProtocol {
    // We need to call this method after adding a new payment card via the PLL screen
    // Refreshing the local membership card object will present the linkages correctly
    func refreshMembershipCard(completion: EmptyCompletionBlock? = nil) {
        guard let cardId = membershipCard.id else {
            completion?()
            return
        }
        let predicate = NSPredicate(format: "id == \(cardId)")
        fetchCoreDataObjects(forObjectType: CD_MembershipCard.self, predicate: predicate) { objects in
            if let updatedMembershipCard = objects?.first {
                self.membershipCard = updatedMembershipCard
            }
            completion?()
        }
    }
}
