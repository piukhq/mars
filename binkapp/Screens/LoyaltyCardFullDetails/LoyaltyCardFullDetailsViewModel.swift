//
//  LoyaltyCardFullDetailsViewModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

protocol LoyaltyCardFullDetailsViewModelDelegate: class {
    func loyaltyCardFullDetailsViewModelDidFetchPaymentCards(_ loyaltyCardFullDetailsViewModel: LoyaltyCardFullDetailsViewModel, paymentCards: [PaymentCardModel])
}

class LoyaltyCardFullDetailsViewModel {
    private let router: MainScreenRouter
    private let repository: LoyaltyCardFullDetailsRepository
    
    let membershipCard: MembershipCardModel
    let membershipPlan: MembershipPlanModel
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
            guard let wself = self else { return }
            wself.delegate?.loyaltyCardFullDetailsViewModelDidFetchPaymentCards(wself, paymentCards: results)
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
            router.toAuthAndAddViewController(membershipPlan: membershipPlan, isFirstAuth: false)
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
        case .pllEmpty:
            router.toPllViewController(membershipCard: membershipCard, membershipPlan: membershipPlan)
            break
        case .pll:
            //TODO: change to PLL screen after is implemented
            router.displaySimplePopup(title: "error_title".localized, message: "to_be_implemented_message".localized)
            break
        case .unLinkable:
            toReusableModalTemplate(title: "unlinkable_pll_title".localized, description: "unlinkable_pll_description".localized)
            break
        case .genericError:
            let state = membershipCard.status?.state?.rawValue ?? ""
            let reasonCodes = membershipCard.status?.reasonCodes ?? [""]
            let description = state + "\n" + reasonCodes.joined(separator: ", ")
    
            toReusableModalTemplate(title: "error_title".localized, description: description)
            break
        }
        
    }
    
    private func toReusableModalTemplate(title: String, description: String) {
        let attributedText = NSMutableAttributedString(string: title + "\n" + description)
        attributedText.addAttribute(NSAttributedString.Key.font, value: UIFont.headline, range: NSRange(location: 0, length: title.count))
        attributedText.addAttribute(NSAttributedString.Key.font, value: UIFont.bodyTextLarge, range: NSRange(location: title.count, length: description.count))
        
        let backButton = UIBarButtonItem(image: UIImage(named: "navbarIconsBack")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(popViewController))
        let configurationModel = ReusableModalConfiguration(title: "", text: attributedText, tabBarBackButton: backButton)
        
        router.toReusableModalTemplateViewController(configurationModel: configurationModel)
    }
    
    func popToRootController() {
        router.popToRootViewController()
    }
    
    @objc func popViewController() {
        router.popViewController()
    }
    
    func displaySimplePopupWithTitle(_ title: String, andMessage message: String) {
        router.displaySimplePopup(title: title, message: message)
    }
    
    func getOfferTileImageUrls() -> [String]? {
        return membershipPlan.images?.filter({ $0.type == ImageType.offer.rawValue}).map({return $0.url}) as? [String] ?? [""]
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
