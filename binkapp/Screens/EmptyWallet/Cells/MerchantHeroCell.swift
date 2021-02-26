//
//  MerchantHeroCell.swift
//  binkapp
//
//  Created by Sean Williams on 22/02/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import UIKit

class MerchantHeroCell: UICollectionViewCell {
    var imageView = UIImageView()
    
    override var reuseIdentifier: String? {
        return "MerchantHeroCell"
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
    
    func configure(with membershipPlan: CD_MembershipPlan) {
        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
        
        if let hexStringColor = membershipPlan.card?.colour {
            backgroundColor = UIColor(hexString: hexStringColor)
            layoutIfNeeded()
            let placeholderName = membershipPlan.account?.planNameCard ?? membershipPlan.account?.planName ?? ""
            let placeholder = LCDPlaceholderGenerator.generate(with: hexStringColor, planName: placeholderName, destSize: self.frame.size)
            backgroundColor = UIColor(patternImage: placeholder)
        }
        
        imageView.setImage(forPathType: .membershipPlanAlternativeHero(plan: membershipPlan))
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        addSubview(imageView)
    }
    
    func configureWithPlaceholder(frame: CGRect, walletPrompt: WalletPrompt?) {
        backgroundColor = UIColor(hexString: "102F82").darker(by: 5.0)
        
        let size = LayoutHelper.WalletDimensions.sizeForWalletPromptCell(viewFrame: frame, walletPrompt: walletPrompt)
        let label = UILabel(frame: CGRect(origin: .zero, size: size))
        label.text = "wallet_prompt_more_coming_soon".localized
        label.textAlignment = .center
        label.textColor = .white
        label.font = .statusLabel
        addSubview(label)
    }
}
