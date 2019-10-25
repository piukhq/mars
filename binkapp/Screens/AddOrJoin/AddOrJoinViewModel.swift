//
//  AddOrJoinViewModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class AddOrJoinViewModel {
    private let membershipPlan: CD_MembershipPlan
    private let router: MainScreenRouter
    
    init(membershipPlan: CD_MembershipPlan, router: MainScreenRouter) {
        self.membershipPlan = membershipPlan
        self.router = router
    }
    
    func getMembershipPlan() -> CD_MembershipPlan {
        return membershipPlan
    }
    
    func toAuthAndAddScreen() {
        router.toAuthAndAddViewController(membershipPlan: membershipPlan, formPurpose: .firstLogin)
    }
    
    func didSelectAddNewCard() {
        guard let enrolFields = membershipPlan.account?.enrolFields, enrolFields.count > 0 else {
            toNativeJoinUnavailable()
            return
        }
        
        router.toAuthAndAddViewController(membershipPlan: membershipPlan, formPurpose: .signUp)
    }
    
    func toNativeJoinUnavailable() {
        let screenText = "native_join_unavailable_title".localized + "\n" + "native_join_unavailable_description".localized
        
        let attributedText = NSMutableAttributedString(string: screenText)
        attributedText.addAttribute(NSAttributedString.Key.font, value: UIFont.headline, range: NSRange(location: 0, length: ("native_join_unavailable_title".localized).count)
        )
        attributedText.addAttribute(NSAttributedString.Key.font, value: UIFont.bodyTextLarge, range: NSRange(location: ("native_join_unavailable_title".localized).count, length: ("native_join_unavailable_description".localized).count)
        )
        
        var configurationModel: ReusableModalConfiguration
        
        let backButton = UIBarButtonItem(image: UIImage(named: "navbarIconsBack"), style: .plain, target: self, action: #selector(popViewController))
        
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
    
    func brandHeaderWasTapped() {
        let title: String = membershipPlan.account?.planNameCard ?? ""
        let description: String = membershipPlan.account?.planDescription ?? ""
        
        let attributedString = NSMutableAttributedString(string: title + "\n" + description)
        attributedString.addAttribute(.font, value: UIFont.headline, range: NSRange(location: 0, length: title.count))
        attributedString.addAttribute(.font, value: UIFont.bodyTextLarge, range: NSRange(location: title.count, length: description.count))
        
        let configuration = ReusableModalConfiguration(title: title, text: attributedString, showCloseButton: true)
        router.toReusableModalTemplateViewController(configurationModel: configuration)
    }
    
    func displaySimplePopup(title: String?, message: String?) {
        router.displaySimplePopup(title: title, message: message)
    }
    
    @objc func popViewController() {
        router.dismissViewController()
    }
    
    func popToRootViewController() {
        router.popToRootViewController()
    }
}
