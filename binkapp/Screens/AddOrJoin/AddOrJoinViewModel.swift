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
        let fields = membershipPlan.featureSet?.formattedLinkingSupport
        guard (fields?.contains(where: { $0.value == LinkingSupportType.enrol.rawValue }) ?? false) else {
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
        
        guard let planURL = membershipPlan.account?.planURL else {
            configurationModel = ReusableModalConfiguration(title: "", text: attributedText, showCloseButton: true)
            router.toReusableModalTemplateViewController(configurationModel: configurationModel)
            return
        }
        
        configurationModel = ReusableModalConfiguration(title: "", text: attributedText, primaryButtonTitle: "to_merchant_site_button".localized, mainButtonCompletion: {
            if let url = URL(string: planURL) {
                UIApplication.shared.open(url)
            }
        }, showCloseButton: true)
        
        router.toReusableModalTemplateViewController(configurationModel: configurationModel)
    }
    
    func brandHeaderWasTapped() {
        let title: String = membershipPlan.account?.planNameCard ?? ""
        let description: String = membershipPlan.account?.planDescription ?? ""
        
        let attributedString = NSMutableAttributedString()
        let attributedTitle = NSAttributedString(string: title + "\n", attributes: [NSAttributedString.Key.font : UIFont.headline])
        let attributedBody = NSAttributedString(string: description, attributes: [NSAttributedString.Key.font : UIFont.bodyTextLarge])
        attributedString.append(attributedTitle)
        attributedString.append(attributedBody)
        
        let configuration = ReusableModalConfiguration(title: title, text: attributedString, showCloseButton: true)
        router.toReusableModalTemplateViewController(configurationModel: configuration)
    }
    
    func displaySimplePopup(title: String?, message: String?) {
        router.displaySimplePopup(title: title, message: message)
    }
    
    @objc func popViewController() {
        router.popViewController()
    }
    
    @objc func dismissViewController() {
        router.dismissViewController()
    }
    
    func popToRootViewController() {
        router.popToRootViewController()
    }
}
