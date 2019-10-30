//
//  PLLViewModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class PLLScreenViewModel {
    private var membershipCard: CD_MembershipCard
    private let repository: PLLScreenRepository
    private let router: MainScreenRouter
    let journey: PllScreenJourney
    var paymentCards: [CD_PaymentCard]? {
        return Current.wallet.paymentCards
    }
    private var changedLinkCards = [CD_PaymentCard]()
    
    var isEmptyPll: Bool {
        return paymentCards == nil ? true : paymentCards?.count == 0
    }
    
    var isNavigationVisisble: Bool {
        return isEmptyPll || journey == .newCard
    }
    
    var linkedPaymentCards: [CD_PaymentCard]? {
        let paymentCards = membershipCard.linkedPaymentCards.allObjects as? [CD_PaymentCard]
        return paymentCards
    }
    
    var titleText: String {
        return isEmptyPll ? "pll_screen_add_title".localized : "pll_screen_link_title".localized
    }
    
    var primaryMessageText: String {
        return isEmptyPll ? "pll_screen_link_message".localized : "pll_screen_add_message".localized
    }
    
    var secondaryMessageText: String {
        return "pll_screen_secondary_message".localized
    }
        
    init(membershipCard: CD_MembershipCard, repository: PLLScreenRepository, router: MainScreenRouter, journey: PllScreenJourney) {
        self.membershipCard = membershipCard
        self.repository = repository
        self.router = router
        self.journey = journey
    }
    
    // MARK:  - Public methods
    
    func popViewController() {
        router.popViewController()
    }
    
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
        Current.wallet.reload()
    }
    
    func toggleLinkForMembershipCards(completion: @escaping () -> Void) {
        repository.toggleLinkForPaymentCards(membershipCard: membershipCard, changedLinkCards: changedLinkCards, onSuccess: {
            completion()
        }) { (error) in
            self.displaySimplePopup(title: "error_title".localized, message: error.localizedDescription)
        }
    }
    
    func getMembershipPlan() -> CD_MembershipPlan? {
        return membershipCard.membershipPlan
    }
    
    func getMembershipCard() -> CD_MembershipCard {
        return membershipCard
    }
    
    func brandHeaderWasTapped() {
        let title: String = membershipCard.membershipPlan?.account?.planNameCard ?? ""
        let description: String = membershipCard.membershipPlan?.account?.planDescription ?? ""
        
        let attributedString = NSMutableAttributedString()
        let attributedTitle = NSAttributedString(string: title + "\n", attributes: [NSAttributedString.Key.font : UIFont.headline])
        let attributedBody = NSAttributedString(string: description, attributes: [NSAttributedString.Key.font : UIFont.bodyTextLarge])
        attributedString.append(attributedTitle)
        attributedString.append(attributedBody)
        
        let configuration = ReusableModalConfiguration(title: title, text: attributedString, showCloseButton: true)
        router.toReusableModalTemplateViewController(configurationModel: configuration)
    }
    
    func displaySimplePopup(title: String, message: String) {
        router.displaySimplePopup(title: title, message: message)
    }
    
    func toFullDetailsCardScreen() {
        router.toLoyaltyFullDetailsScreen(membershipCard: membershipCard)
    }
    
    func toAddPaymentCardScreen() {
        router.toAddPaymentViewController()
    }
}
