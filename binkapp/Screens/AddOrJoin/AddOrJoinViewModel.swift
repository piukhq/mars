//
//  AddOrJoinViewModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class AddOrJoinViewModel {
    private let membershipPlan: MembershipPlanModel
    private let router: MainScreenRouter
    
    init(membershipPlan: MembershipPlanModel, router: MainScreenRouter) {
        self.membershipPlan = membershipPlan
        self.router = router
    }
    
    func getMembershipPlan() -> MembershipPlanModel {
        return membershipPlan
    }
    
    func toAuthAndAddScreen() {
        router.toAuthAndAddViewController(membershipPlan: membershipPlan, formPurpose: .firstLogin)
    }
    
    func didSelectAddNewCard() {
        if membershipPlan.featureSet?.cardType == .link {
            //TODO: go to sign up form
            router.toAuthAndAddViewController(membershipPlan: membershipPlan, formPurpose: .signUp)
        } else {
            let screenText = "native_join_unavailable_title".localized + "\n" + "native_join_unavailable_description".localized
            
            let attributedText = NSMutableAttributedString(string: screenText)
            attributedText.addAttribute(NSAttributedString.Key.font, value: UIFont.headline, range: NSRange(location: 0, length: ("native_join_unavailable_title".localized).count)
            )
            attributedText.addAttribute(NSAttributedString.Key.font, value: UIFont.bodyTextLarge, range: NSRange(location: ("native_join_unavailable_title".localized).count, length: ("native_join_unavailable_description".localized).count)
            )
            
            var configurationModel: ReusableModalConfiguration
            
            let backButton = UIBarButtonItem(image: UIImage(named: "navbarIconsBack")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(popViewController))
            
            guard let planURL = membershipPlan.account?.planURL else {
                configurationModel = ReusableModalConfiguration(title: "", text: attributedText, tabBarBackButton: backButton)
                router.toReusableModalTemplateViewController(configurationModel: configurationModel)
                return
            }
            
            configurationModel = ReusableModalConfiguration(title: "", text: attributedText, primaryButtonTitle: "to_merchant_site_button".localized, mainButtonCompletion: {
                if let url = URL(string: planURL) {
                    UIApplication.shared.open(url)
                }
            }, tabBarBackButton: backButton)
            
            router.toReusableModalTemplateViewController(configurationModel: configurationModel)
            
        }
    }
    
    func displaySimplePopup(title: String?, message: String?) {
        router.displaySimplePopup(title: title, message: message)
    }
    
    @objc func popViewController() {
        router.popViewController()
    }
    
    func popToRootViewController() {
        router.popToRootViewController()
    }
}
