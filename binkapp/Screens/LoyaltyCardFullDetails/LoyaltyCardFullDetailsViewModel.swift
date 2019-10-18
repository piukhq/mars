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
            router.toAuthAndAddViewController(membershipPlan: membershipPlan, formPurpose: .otherLogin)
            break
        case .loginChanges:
            //TODO: change to login changes screen after is implemented
            guard let membershipPlan = membershipCard.membershipPlan else { return }
            router.toAuthAndAddViewController(membershipPlan: membershipPlan, formPurpose: .otherLogin)
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
            router.toPllViewController(membershipCard: membershipCard, isAddJourney: false)
            break
        case .pll:
            router.toPllViewController(membershipCard: membershipCard, isAddJourney: false)
            break
        case .unLinkable:
            toReusableModalTemplate(title: "unlinkable_pll_title".localized, description: "unlinkable_pll_description".localized)
            break
        case .genericError:
            let state = membershipCard.status?.status?.rawValue ?? ""
            
            var description = state + "\n"
            membershipCard.status?.formattedReasonCodes?.forEach {
                description += $0.value ?? ""
            }
    
            toReusableModalTemplate(title: "error_title".localized, description: description)
            break
        }
        
    }
    
    private func toReusableModalTemplate(title: String, description: String) {
        let attributedText = NSMutableAttributedString(string: title + "\n" + description)
        attributedText.addAttribute(NSAttributedString.Key.font, value: UIFont.headline, range: NSRange(location: 0, length: title.count))
        attributedText.addAttribute(NSAttributedString.Key.font, value: UIFont.bodyTextLarge, range: NSRange(location: title.count, length: description.count))
        
        let backButton = UIBarButtonItem(image: UIImage(named: "navbarIconsBack"), style: .plain, target: self, action: #selector(popViewController))
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
        let planImages = membershipCard.membershipPlan?.imagesSet
        return planImages?.filter({ $0.type?.intValue == 2}).compactMap { $0.url }
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
