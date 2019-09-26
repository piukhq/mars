//
//  LoyaltyCardFullDetailsViewModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

class LoyaltyCardFullDetailsViewModel {
    private let router: MainScreenRouter
    private let repository: LoyaltyCardFullDetailsRepository
    let membershipCard: MembershipCardModel
    let membershipPlan: MembershipPlanModel
    
    init(membershipCard: MembershipCardModel, membershipPlan: MembershipPlanModel, repository: LoyaltyCardFullDetailsRepository, router: MainScreenRouter) {
        self.router = router
        self.repository = repository
        self.membershipPlan = membershipPlan
        self.membershipCard = membershipCard
    }
    
    // MARK: - Public methds
    
    func toBarcodeModel() {
        router.toBarcodeViewController(membershipPlan: membershipPlan, membershipCard: membershipCard)
    }
    
    func toTransactionsViewController() {
        router.toTransactionsViewController(membershipCard: membershipCard, membershipPlan: membershipPlan)
    }
    
    func goToScreenForAction(action: PointsModuleView.PointsModuleAction) {
        switch action {
        case .login:
            //TODO: change to login screen after is implemented
            router.displaySimplePopup(title: "error_title".localized, message: "to_be_implemented_message".localized)
            break
        case .loginChanges:
            //TODO: change to login changes screen after is implemented
            router.toAuthAndAddViewController(membershipPlan: membershipPlan, isFirstAuth: false)
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
