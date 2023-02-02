//
//  BrowseBrandsListRowViewModel.swift
//  binkapp
//
//  Created by Sean Williams on 16/09/2022.
//  Copyright © 2022 Bink. All rights reserved.
//

import SwiftUI

class BrowseBrandsListRowViewModel: ObservableObject {
    let title: String
    let plan: CD_MembershipPlan
    let brandExists: Bool
    let userInterfaceStyle: UIUserInterfaceStyle?
    var showSeparator: Bool
    let action: () -> Void
    
    @Published var image: UIImage?

    init(title: String, plan: CD_MembershipPlan, brandExists: Bool, userInterfaceStyle: UIUserInterfaceStyle? = nil, showSeparator: Bool, action: @escaping () -> Void) {
        self.title = title
        self.plan = plan
        self.brandExists = brandExists
        self.userInterfaceStyle = userInterfaceStyle
        self.showSeparator = showSeparator
        self.action = action
        getImage()
    }
    
    var subtitle: String? {
        return plan.featureSet?.planCardType == .link ? L10n.canBeLinkedDescription : nil
    }
    
    func getImage() {
        ImageService.getImage(forPathType: .membershipPlanIcon(plan: plan), userInterfaceStyle: userInterfaceStyle) { [weak self] image in
            self?.image = image ?? UIImage(named: Asset.binkIconLogo.name)?.grayScale()
        }
    }
}
