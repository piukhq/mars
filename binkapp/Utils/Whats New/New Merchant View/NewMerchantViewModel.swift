//
//  NewMerchantViewModel.swift
//  binkapp
//
//  Created by Sean Williams on 03/03/2023.
//  Copyright © 2023 Bink. All rights reserved.
//

import SwiftUI

class NewMerchantViewModel: ObservableObject {
    @Published var iconImage: UIImage?
    
    var merchant: NewMerchantModel
    var membershipPlan: CD_MembershipPlan?
    
    init(merchant: NewMerchantModel) {
        self.merchant = merchant
        self.membershipPlan = Current.wallet.membershipPlans?.first(where: { $0.id == merchant.id })
        getIconImage()
    }
    
    var title: String {
        return membershipPlan?.account?.companyName ?? "Tesco"
    }
    
    var descriptionTexts: [String]? {
        return merchant.description
    }
    
    var backgroundColor: UIColor {
        return membershipPlan?.secondaryBrandColor ?? .secondarySystemBackground
    }
    
    var textColor: Color {
        return .white
//        return backgroundColor.isLight(threshold: 0.8) ? .black : .white
    }
    
    func getMembershipPlan(from id: String) {
        membershipPlan = Current.wallet.membershipPlans?.first(where: { $0.id == id })
    }
    
    func getIconImage() {
        guard let membershipPlan = membershipPlan else { return }
        ImageService.getImage(forPathType: .membershipPlanIcon(plan: membershipPlan), completion: { image in
            self.iconImage = image ?? UIImage(named: "bink-icon-logo") ?? UIImage(systemName: "lanyardcard")
        })
    }
    
    func handleNavigation() {
        guard let membershipPlan = membershipPlan else { return }
        Current.navigate.close(animated: true) {
            let browseBrandsVC = ViewControllerFactory.makeBrowseBrandsViewController()
            let navigationRequest = ModalNavigationRequest(viewController: browseBrandsVC) {
                let addJoinVC = ViewControllerFactory.makeAddOrJoinViewController(membershipPlan: membershipPlan)
                let pushNavigationRequest = PushNavigationRequest(viewController: addJoinVC)
                Current.navigate.to(pushNavigationRequest)
            }
            Current.navigate.to(navigationRequest)
        }
    }
}