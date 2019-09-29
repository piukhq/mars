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
    let membershipCard: CD_MembershipCard
    weak var delegate: LoyaltyCardFullDetailsViewModelDelegate?

    init(membershipCard: CD_MembershipCard, repository: LoyaltyCardFullDetailsRepository, router: MainScreenRouter) {
        self.router = router
        self.repository = repository
        self.membershipCard = membershipCard
    }  
    
    // MARK: - Public methds
    
    func getPaymentCards() {
        repository.getPaymentCards { [weak self] (results) in
            guard let wself = self else { return }
            wself.delegate?.loyaltyCardFullDetailsViewModelDidFetchPaymentCards(wself, paymentCards: results)
        }
    }
    
    func toBarcodeModel() {
//        router.toBarcodeViewController(membershipCard: ) {}
    }
    
    func toTransactionsViewController() {
//        router.toTransactionsViewController(membershipCard: membershipCard, membershipPlan: membershipPlan)
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
            router.toTransactionsViewController(membershipCard: membershipCard)
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
            router.toPllViewController(membershipCard: membershipCard)
            break
        case .pll:
            //TODO: change to PLL screen after is implemented
            router.displaySimplePopup(title: "error_title".localized, message: "to_be_implemented_message".localized)
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
        router.showDeleteConfirmationAlert(withMessage: "delete_card_confirmation".localized, yesCompletion: { [weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf.repository.deleteMembershipCard(id: strongSelf.membershipCard.id, onSuccess: { _ in
                yesCompletion()
            }, onError: { (error: Error) in
                strongSelf.displaySimplePopupWithTitle("Error", andMessage: error.localizedDescription)
            })
        }, noCompletion: {
            noCompletion()
        })
    }
}
