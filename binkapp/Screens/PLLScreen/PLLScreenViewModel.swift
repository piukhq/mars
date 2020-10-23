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
    private let delegate: LoyaltyCardFullDetailsModalDelegate?
    
    private let paymentScannerStrings = PaymentCardScannerStrings()
    
    let journey: PllScreenJourney
    
    var activePaymentCards: [CD_PaymentCard]? {
        return Current.wallet.paymentCards?.filter { $0.paymentCardStatus == .active }
    }
    
    var pendingPaymentCards: [CD_PaymentCard]? {
        return Current.wallet.paymentCards?.filter { $0.paymentCardStatus == .pending }
    }
    
    var hasActivePaymentCards: Bool {
        return activePaymentCards != nil && activePaymentCards?.count != 0
    }
    
    private(set) var changedLinkCards = [CD_PaymentCard]()
    
    var shouldShowActivePaymentCards: Bool {
        return hasActivePaymentCards
    }
    
    var shouldShowPendingPaymentCards: Bool {
        return pendingPaymentCards != nil && pendingPaymentCards?.count != 0
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
        return "pll_screen_link_title".localized
    }
    
    var primaryMessageText: String {
        return isEmptyPll ? "pll_screen_link_message".localized : String(format: "pll_screen_add_message".localized, membershipCard.membershipPlan?.account?.planNameCard ?? "")
    }
    
    var secondaryMessageText: String {
        return "pll_screen_secondary_message".localized
    }
        
    init(membershipCard: CD_MembershipCard, journey: PllScreenJourney, delegate: LoyaltyCardFullDetailsModalDelegate? = nil) {
        self.membershipCard = membershipCard
        self.journey = journey
        self.delegate = delegate
    }
    
    // MARK:  - Public methods
    
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
        repository.toggleLinkForPaymentCards(membershipCard: membershipCard, changedLinkCards: changedLinkCards, onSuccess: {
            completion(true)
        }) { [weak self] error in
            guard let error = error else { return }
            if case .userFacingNetworkingError(let networkingError) = error {
                if case .userFacingError(let userFacingError) = networkingError {
                    let messagePrefix = self?.changedLinkCards.count == 1 ? "card_already_linked_message_prefix".localized : "cards_already_linked_message_prefix".localized
                    let planName = self?.membershipCard.membershipPlan?.account?.planName ?? ""
                    let planNameCard = self?.membershipCard.membershipPlan?.account?.planNameCard ?? ""
                    let planDetails = "\(planName) \(planNameCard)"
                    let formattedString = String(format: userFacingError.message, messagePrefix, planDetails, planDetails)
                    self?.displaySimplePopup(title: userFacingError.title, message: formattedString, completion: {
                        completion(false)
                    })
                }
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
        guard let viewController = ViewControllerFactory.makePaymentCardScannerViewController(strings: paymentScannerStrings, delegate: delegate) else { return }
        
        let enterManuallyAlert = UIAlertController.cardScannerEnterManuallyAlertController { [weak self] in
            self?.toAddPaymentCardScreen()
        }
        
        if PermissionsUtility.videoCaptureIsAuthorized {
            let navigationRequest = ModalNavigationRequest(viewController: viewController)
            Current.navigate.to(navigationRequest)
        } else if PermissionsUtility.videoCaptureIsDenied {
            if let alert = enterManuallyAlert {
                let navigationRequest = AlertNavigationRequest(alertController: alert)
                Current.navigate.to(navigationRequest)
            }
        } else {
            PermissionsUtility.requestVideoCaptureAuthorization { granted in
                if granted {
                    let navigationRequest = ModalNavigationRequest(viewController: viewController)
                    Current.navigate.to(navigationRequest)
                } else {
                    if let alert = enterManuallyAlert {
                        let navigationRequest = AlertNavigationRequest(alertController: alert)
                        Current.navigate.to(navigationRequest)
                    }
                }
            }
        }
    }
    
    func toAddPaymentCardScreen(model: PaymentCardCreateModel? = nil) {
        let viewController = ViewControllerFactory.makeAddPaymentCardViewController(model: model, journey: .pll)
        let navigationRequest = ModalNavigationRequest(viewController: viewController)
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
