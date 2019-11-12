//
//  LoyaltyCardFullDetailsViewModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class LoyaltyCardFullDetailsViewModel {
    private let router: MainScreenRouter
    private let repository: LoyaltyCardFullDetailsRepository
    
    var paymentCards: [CD_PaymentCard]? {
        return Current.wallet.paymentCards
    }
    let membershipCard: CD_MembershipCard
    
    var aboutTitle: String {
        if let planName = membershipCard.membershipPlan?.account?.planName {
            return String(format: "about_membership_plan_title".localized, planName)
        } else {
           return "about_membership_title".localized
        }
    }
    
    var deleteTitle: String {
        if let planNameCard = membershipCard.membershipPlan?.account?.planNameCard {
            return String(format: "delete_card_plan_title".localized, planNameCard)
        } else {
            return "delete_card_title".localized
        }
    }

    init(membershipCard: CD_MembershipCard, repository: LoyaltyCardFullDetailsRepository, router: MainScreenRouter) {
        self.router = router
        self.repository = repository
        self.membershipCard = membershipCard
    }  

    var brandName: String {
        return membershipCard.membershipPlan?.account?.companyName ?? ""
    }

    var balance: CD_MembershipCardBalance? {
        return membershipCard.balances.allObjects.first as? CD_MembershipCardBalance
    }

    var pointsValueText: String {
        return "\(balance?.prefix ?? "")\(balance?.value?.stringValue ?? "") \(balance?.suffix ?? "")"
    }

    // MARK: - Public methods
    
    func toBarcodeModel() {
        router.toBarcodeViewController(membershipCard: membershipCard) { }
    }
    
    func goToScreenForAction(action: BinkModuleView.BinkModuleAction) {
        switch action {
        case .login:
            //TODO: change to login screen after is implemented
            guard let membershipPlan = membershipCard.membershipPlan else { return }
            router.toAuthAndAddViewController(membershipPlan: membershipPlan, formPurpose: .loginFailed, existingMembershipCard: membershipCard)
            break
        case .loginChanges:
            //TODO: change to login changes screen after is implemented
            guard let membershipPlan = membershipCard.membershipPlan else { return }
            router.toAuthAndAddViewController(membershipPlan: membershipPlan, formPurpose: .loginFailed, existingMembershipCard: membershipCard)
            break
        case .transactions:
            router.toTransactionsViewController(membershipCard: membershipCard)
            break
        case .loginPending:
            let title = "log_in_pending_title".localized
            let description = "log_in_pending_description".localized
            router.toReusableModalTemplateViewController(configurationModel: getBasicReusableConfiguration(title: title, description: description))
            break
        case .loginUnavailable:            let title = "transaction_history_not_supported_title".localized
            let description = "transaction_history_not_supported_description".localized
            router.toReusableModalTemplateViewController(configurationModel: getBasicReusableConfiguration(title: title, description: description))
            break
        case .signUp:
            //TODO: change to sign up screen after is implemented
            router.displaySimplePopup(title: "error_title".localized, message: "to_be_implemented_message".localized)
            break
        case .signUpPending:
            let title = "sign_up_pending_title".localized
            let description = "sign_up_pending_description".localized
            router.toReusableModalTemplateViewController(configurationModel: getBasicReusableConfiguration(title: title, description: description))
            break
        case .registerGhostCard:
            //TODO: change to sign up screen after is implemented
            router.displaySimplePopup(title: "error_title".localized, message: "to_be_implemented_message".localized)
            break
        case .registerGhostCardPending:
            let title = "sign_up_pending_title".localized
            let description = "sign_up_pending_description".localized
            router.toReusableModalTemplateViewController(configurationModel: getBasicReusableConfiguration(title: title, description: description))
            break
        case .pllEmpty:
            router.toPllViewController(membershipCard: membershipCard, journey: .existingCard)
            break
        case .pll:
            router.toPllViewController(membershipCard: membershipCard, journey: .existingCard)
            break
        case .unLinkable:
            let title = "unlinkable_pll_title".localized
            let description = "unlinkable_pll_description".localized
            router.toReusableModalTemplateViewController(configurationModel: getBasicReusableConfiguration(title: title, description: description))
            break
        case .genericError:
            let state = membershipCard.status?.status?.rawValue ?? ""
            
            var description = state + "\n"
            membershipCard.status?.formattedReasonCodes?.forEach {
                description += $0.value ?? ""
            }
    
            router.toReusableModalTemplateViewController(configurationModel: getBasicReusableConfiguration(title: "error_title".localized, description: description))
            break
        }
    }
    
    func getBasicReusableConfiguration(title: String, description: String) -> ReusableModalConfiguration {
        let attributedString = NSMutableAttributedString(string: title + "\n" + description)
        
        attributedString.addAttribute(.font, value: UIFont.headline, range: NSRange(location: 0, length: title.count))
        attributedString.addAttribute(.font, value: UIFont.bodyTextLarge, range: NSRange(location: title.count, length: description.count))
        
        return ReusableModalConfiguration(title: title, text: attributedString, showCloseButton: true)
    }
    
    func toReusableModalTemplate(title: String, description: NSMutableAttributedString) {
        let configurationModel = ReusableModalConfiguration(title: "", text: description, showCloseButton: true)
        
        router.toReusableModalTemplateViewController(configurationModel: configurationModel)
    }
    
    func toSecurityAndPrivacyScreen() {
        router.toPrivacyAndSecurityViewController()
    }
    
    func popToRootController() {
        router.popToRootViewController()
    }
    
    @objc func popViewController() {
        router.popViewController()
    }
    
    func getOfferTileImageUrls() -> [String]? {
        let planImages = membershipCard.membershipPlan?.imagesSet
        return planImages?.filter({ $0.type?.intValue == 2}).compactMap { $0.url }
    }
    
    func showDeleteConfirmationAlert(yesCompletion: @escaping () -> Void, noCompletion: @escaping () -> Void) {
        router.showDeleteConfirmationAlert(withMessage: "delete_card_confirmation".localized, yesCompletion: { [weak self] in
            guard let self = self else { return }
            self.repository.delete(self.membershipCard) {
                yesCompletion()
            }
        }, noCompletion: {
            noCompletion()
        })
    }
}

// MARK: - Private methods

private extension LoyaltyCardFullDetailsViewModel {
    func toReusableModalTemplate(title: String, description: String) {
        let attributedText = NSMutableAttributedString(string: title + "\n" + description)
        attributedText.addAttribute(NSAttributedString.Key.font, value: UIFont.headline, range: NSRange(location: 0, length: title.count))
        attributedText.addAttribute(NSAttributedString.Key.font, value: UIFont.bodyTextLarge, range: NSRange(location: title.count, length: description.count))
        
        let backButton = UIBarButtonItem(image: UIImage(named: "navbarIconsBack"), style: .plain, target: self, action: #selector(popViewController))
        let configurationModel = ReusableModalConfiguration(title: "", text: attributedText, tabBarBackButton: backButton)
        
        router.toReusableModalTemplateViewController(configurationModel: configurationModel)
    }
}
