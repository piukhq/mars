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
        router.toAuthAndAddViewController(membershipPlan: membershipPlan)
    }
    
    func didSelectAddNewCard() {
        if membershipPlan.featureSet?.cardType == FeatureSetModel.PlanCardType.link {
            //TODO: go to sign up form
            router.displaySimplePopup(title: "Goes to Sign Up Form", message: "Not implemented yet")
        } else {
            let screenText = "native_join_unavailable_title".localized + "\n" + "native_join_unavailable_description".localized
            
            let attributedText = NSMutableAttributedString(string: screenText)
            
            attributedText.addAttribute(
                NSAttributedString.Key.font,
                value: UIFont.headline,
                range: NSRange(location: 0, length: ("native_join_unavailable_title".localized).count)
            )
            
            attributedText.addAttribute(
                NSAttributedString.Key.font,
                value: UIFont.bodyTextLarge,
                range: NSRange(location: ("native_join_unavailable_title".localized).count, length: ("native_join_unavailable_description".localized).count)
            )
            
            let backButton = UIBarButtonItem(image: UIImage(named: "navbarIconsBack")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(popViewController))
            
            if let planURL = membershipPlan.account?.planURL {
                let configurationModel = ReusableModalConfiguration(title: "", text: attributedText, mainButtonTitle: "to_merchant_site_button".localized, mainButtonCompletion: {
                    if let url = URL(string: planURL) {
                        UIApplication.shared.open(url)
                    }
                }, tabBarBackButton: backButton)
                router.toReusableModalTemplateViewController(configurationModel: configurationModel)
            } else {
                let configurationModel = ReusableModalConfiguration(title: "", text: attributedText, tabBarBackButton: backButton)
                router.toReusableModalTemplateViewController(configurationModel: configurationModel)
            }
            
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
