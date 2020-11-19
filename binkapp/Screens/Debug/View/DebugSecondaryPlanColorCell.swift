//
//  DebugSecondaryPlanColorCell.swift
//  binkapp
//
//  Created by Nick Farrant on 11/05/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import UIKit

class DebugSecondaryPlanColorCell: UICollectionViewCell {
    @IBOutlet private weak var planLabel: UILabel!
    @IBOutlet private weak var primaryColorView: UIView!
    @IBOutlet private weak var secondaryColorView: UIView!
    
    func configureWithPlan(_ plan: CD_MembershipPlan) {
        let primaryColor = UIColor(hexString: plan.card?.colour ?? "")
        primaryColorView.backgroundColor = primaryColor
        secondaryColorView.backgroundColor = plan.generatedSecondaryBrandColor

        planLabel.text = plan.account?.companyName
        planLabel.textColor = primaryColor.isLight(threshold: 0.8) ? .black : .white
    }
}
