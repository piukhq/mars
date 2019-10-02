//
//  LoyaltyCardFullDetailsViewModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

protocol LoyaltyCardFullDetailsViewModelDelegate: class {
    func loyaltyCardFullDetailsViewModelDidFetchPaymentCards(_ loyaltyCardFullDetailsViewModel: LoyaltyCardFullDetailsViewModel, paymentCards: [PaymentCardModel])
}

class LoyaltyCardFullDetailsViewModel {
    private let router: MainScreenRouter
    private let repository: LoyaltyCardFullDetailsRepository
    
    let membershipCard: MembershipCardModel
    let membershipPlan: MembershipPlanModel
    var paymentCards: [PaymentCardModel]?
    weak var delegate: LoyaltyCardFullDetailsViewModelDelegate?
    
    init(membershipCard: MembershipCardModel, membershipPlan: MembershipPlanModel, repository: LoyaltyCardFullDetailsRepository, router: MainScreenRouter) {
        self.router = router
        self.repository = repository
        self.membershipPlan = membershipPlan
        self.membershipCard = membershipCard
    }
    
    // MARK: - Public methds
    
    func getPaymentCards() {
        repository.getPaymentCards { [weak self] (results) in
            guard let self = self else { return }
            self.paymentCards = results
            self.delegate?.loyaltyCardFullDetailsViewModelDidFetchPaymentCards(self, paymentCards: results)
        }
    }
    
    func toBarcodeModel() {
        router.toBarcodeViewController(membershipPlan: membershipPlan, membershipCard: membershipCard)
    }
    
    func toTransactionsViewController() {
        router.toTransactionsViewController(membershipCard: membershipCard, membershipPlan: membershipPlan)
    }
    
    func goToScreenForAction(action: BinkModuleView.BinkModuleAction) {
        switch action {
        case .login:
            //TODO: change to login screen after is implemented
            router.displaySimplePopup(title: "error_title".localized, message: "to_be_implemented_message".localized)
            break
        case .loginChanges:
            //TODO: change to login changes screen after is implemented
            router.displaySimplePopup(title: "error_title".localized, message: "to_be_implemented_message".localized)
            break
        case .transactions:
            router.toTransactionsViewController(membershipCard: membershipCard, membershipPlan: membershipPlan)
            break
        case .loginPending:
            router.toSimpleInfoViewController(pendingType: .login)
            break
        case .loginUnavailable:
            //TODO: change to login unavailable screen after is implemented
            router.displaySimplePopup(title: "error_title".localized, message: "to_be_implemented_message".localized)
            break
        case .signUp:
            //TODO: change to sign up screen after is implemented
            router.displaySimplePopup(title: "error_title".localized, message: "to_be_implemented_message".localized)
            break
        case .signUpPending:
            router.toSimpleInfoViewController(pendingType: .signup)
            break
        case .registerGhostCard:
            //TODO: change to sign up screen after is implemented
            router.displaySimplePopup(title: "error_title".localized, message: "to_be_implemented_message".localized)
            break
        case .registerGhostCardPending:
            router.toSimpleInfoViewController(pendingType: .register)
            break
        case .pllEmpty:
            router.toPllViewController(membershipCard: membershipCard, membershipPlan: membershipPlan)
            break
        case .pll:
            //TODO: change to PLL screen after is implemented
            router.toPllViewController(membershipCard: membershipCard, membershipPlan: membershipPlan, paymentCards: self.paymentCards)
            break
        case .unLinkable:
            //TODO: change to unlinkable error screen after is implemented
            router.displaySimplePopup(title: "error_title".localized, message: "to_be_implemented_message".localized)
            break
        case .genericError:
            //TODO: change to generic error screen after is implemented
            router.displaySimplePopup(title: "error_title".localized, message: "to_be_implemented_message".localized)
            break
        }
    }
    
    func popToRootController() {
        router.popToRootViewController()
    }
    
    func displaySimplePopupWithTitle(_ title: String, andMessage message: String) {
        router.displaySimplePopup(title: title, message: message)
    }
    
    func showDeleteConfirmationAlert(yesCompletion: @escaping () -> Void, noCompletion: @escaping () -> Void) {
        router.showDeleteConfirmationAlert(withMessage: "delete_card_confirmation".localized, yesCompletion: {
            if let cardId = self.membershipCard.id {
                self.repository.deleteMembershipCard(id: cardId, onSuccess: { _ in
                    yesCompletion()
                }, onError: { (error: Error) in
                    self.displaySimplePopupWithTitle("Error", andMessage: error.localizedDescription)
                })
            }
        }, noCompletion: {
            noCompletion()
        })
    }
}
