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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureWithPlan(_ plan: CD_MembershipPlan) {
        planLabel.text = plan.account?.companyName
        
        let primaryColor = UIColor(hexString: plan.card?.colour ?? "")
        primaryColorView.backgroundColor = primaryColor
        
        var secondaryColor: UIColor?
        if primaryColor.isLight() {
            planLabel.textColor = .black
            secondaryColor = primaryColor.darker(by: 30)
        } else {
            planLabel.textColor = .white
            secondaryColor = primaryColor.lighter(by: 30)
        }
        secondaryColorView.backgroundColor = secondaryColor
    }
    
}
