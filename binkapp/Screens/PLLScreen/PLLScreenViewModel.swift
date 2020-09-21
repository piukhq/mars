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
    
    private let paymentScannerStrings = PaymentCardScannerStrings()
    
    let journey: PllScreenJourney
    var paymentCards: [CD_PaymentCard]? {
        return Current.wallet.paymentCards
    }
    var hasPaymentCards: Bool {
        return Current.wallet.hasPaymentCards
    }
    private(set) var changedLinkCards = [CD_PaymentCard]()
    
    var isEmptyPll: Bool {
        return paymentCards == nil ? true : paymentCards?.count == 0
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
        
    init(membershipCard: CD_MembershipCard, journey: PllScreenJourney) {
        self.membershipCard = membershipCard
        self.journey = journey
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
    
    func reloadPaymentCards(){
        Current.wallet.refreshLocal()
    }
    
    func toggleLinkForMembershipCards(completion: @escaping () -> Void) {
        repository.toggleLinkForPaymentCards(membershipCard: membershipCard, changedLinkCards: changedLinkCards, onSuccess: {
            completion()
        }) { [weak self] in
            completion()
            self?.displaySimplePopup(
                title: "pll_error_title".localized,
                message: "pll_error_message".localized
            )
        }
    }
    
    func getMembershipPlan() -> CD_MembershipPlan? {
        return membershipCard.membershipPlan
    }
    
    func getMembershipCard() -> CD_MembershipCard {
        return membershipCard
    }
    
    func brandHeaderWasTapped() {
        let title = membershipCard.membershipPlan?.account?.planName ?? ""
        let description = membershipCard.membershipPlan?.account?.planDescription ?? ""
        
        let attributedString = NSMutableAttributedString()
        let attributedTitle = NSAttributedString(string: title + "\n", attributes: [NSAttributedString.Key.font : UIFont.headline])
        let attributedBody = NSAttributedString(string: description, attributes: [NSAttributedString.Key.font : UIFont.bodyTextLarge])
        attributedString.append(attributedTitle)
        attributedString.append(attributedBody)
        
        let configuration = ReusableModalConfiguration(title: title, text: attributedString)
        let viewController = ViewControllerFactory.makeReusableTemplateViewController(configuration: configuration)
        let navigationRequest = ModalNavigationRequest(viewController: viewController)
        Current.navigate.to(navigationRequest)
    }
    
    func displaySimplePopup(title: String, message: String) {
//        router.displaySimplePopup(title: title, message: message)
    }
    
    func displayNoConnectivityPopup(completion: @escaping () -> Void) {
        let alert = ViewControllerFactory.makeNoConnectivityAlertController(completion: completion)
        let navigationRequest = AlertNavigationRequest(alertController: alert)
        Current.navigate.to(navigationRequest)
    }
    
    func close() {
        Current.navigate.close()
    }
    
    func toPaymentScanner() {
        guard let viewController = ViewControllerFactory.makePaymentCardScannerViewController(strings: paymentScannerStrings, delegate: Current.navigate.paymentCardScannerDelegate) else { return }
        
        let enterManuallyAlert = UIAlertController.cardScannerEnterManuallyAlertController { [weak self] in
            self?.toAddPaymentCardScreen()
        }
        
        if PermissionsUtility.videoCaptureIsAuthorized {
            Current.navigate.close {
                let popNavigationRequest = PopNavigationRequest(toRoot: true) {
                    let navigationRequest = ModalNavigationRequest(viewController: viewController)
                    Current.navigate.to(navigationRequest)
                }
                Current.navigate.to(popNavigationRequest)
            }
        } else if PermissionsUtility.videoCaptureIsDenied {
            if let alert = enterManuallyAlert {
                let navigationRequest = AlertNavigationRequest(alertController: alert)
                Current.navigate.to(navigationRequest)
            }
        } else {
            PermissionsUtility.requestVideoCaptureAuthorization { granted in
                if granted {
                    Current.navigate.close {
                        let popNavigationRequest = PopNavigationRequest(toRoot: true) {
                            let navigationRequest = ModalNavigationRequest(viewController: viewController)
                            Current.navigate.to(navigationRequest)
                        }
                        Current.navigate.to(popNavigationRequest)
                    }
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
        let viewController = ViewControllerFactory.makeAddPaymentCardViewController(model: model)
        let navigationRequest = PushNavigationRequest(viewController: viewController)
        Current.navigate.to(navigationRequest)
    }
}
