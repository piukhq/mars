//
//  PLLViewModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class PLLScreenViewModel {
    private let membershipCard: CD_MembershipCard
    private let router: MainScreenRouter
    
    init(membershipCard: CD_MembershipCard, router: MainScreenRouter) {
        self.membershipCard = membershipCard
        self.router = router
    }
    
    // MARK:  - Public methods
    
    func getMembershipPlan() -> CD_MembershipPlan {
        return membershipCard.membershipPlan!
    }
    
    func brandHeaderWasTapped() {
        let title: String = membershipCard.membershipPlan?.account?.planNameCard ?? ""
        let description: String = membershipCard.membershipPlan?.account?.planDescription ?? ""
        
        let attributedString = NSMutableAttributedString(string: title + "\n" + description)
        attributedString.addAttribute(.font, value: UIFont.headline, range: NSRange(location: 0, length: title.count))
        attributedString.addAttribute(.font, value: UIFont.bodyTextLarge, range: NSRange(location: title.count, length: description.count))
        
        let configuration = ReusableModalConfiguration(title: title, text: attributedString, showCloseButton: true)
        router.toReusableModalTemplateViewController(configurationModel: configuration)
    }
    
    func displaySimplePopup(title: String, message: String) {
        router.displaySimplePopup(title: title, message: message)
    }
    
    func toFullDetailsCardScreen() {
        router.toLoyaltyFullDetailsScreen(membershipCard: membershipCard)
    }
}
