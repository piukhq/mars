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
    var label = UILabel()
    
    override var reuseIdentifier: String? {
        return "MerchantHeroCell"
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        backgroundColor = .clear
        layer.cornerRadius = 0
        label.removeFromSuperview()
    }
    
    func configure(with membershipPlan: CD_MembershipPlan?, walletPrompt: WalletPrompt?, showMorePlansCell: Bool) {
        guard let membershipPlan = membershipPlan else { return }
        let hexStringColor = membershipPlan.card?.colour ?? ""
            backgroundColor = UIColor(hexString: hexStringColor)
            layoutIfNeeded()
        
        if case .link = walletPrompt?.type {
            let placeholderName = membershipPlan.account?.planName ?? membershipPlan.account?.planNameCard ?? ""
            let placeholder = LCDPlaceholderGenerator.generate(with: hexStringColor, planName: placeholderName, destSize: self.frame.size, font: .textFieldLabel)
            backgroundColor = UIColor(patternImage: placeholder)
            imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
            imageView.setImage(forPathType: .membershipPlanAlternativeHero(plan: membershipPlan))
        } else {
            layer.cornerRadius = 10
            imageView = UIImageView(frame: CGRect(x: 5, y: 5, width: frame.width - 10, height: frame.height - 10))
            
            if showMorePlansCell {
                backgroundColor = .binkDynamicGray2
                imageView.image = UIImage(systemName: "ellipsis")
                imageView.contentMode = .scaleAspectFit
                imageView.tintColor = .white
            } else {
                imageView.setImage(forPathType: .membershipPlanIcon(plan: membershipPlan))
                imageView.contentMode = .scaleAspectFill
                backgroundColor = .binkDynamicGray // Remove
            }
        }
        
        addSubview(imageView)
    }
    
    func configureWithPlaceholder(frame: CGRect, walletPrompt: WalletPrompt?) {
        backgroundColor = UIColor(hexString: "102F82").darker(by: 5.0)
        
        let size = LayoutHelper.WalletDimensions.sizeForWalletPromptCell(viewFrame: frame, walletPrompt: walletPrompt)
        label = UILabel(frame: CGRect(origin: .zero, size: size))
        label.text = "wallet_prompt_more_coming_soon".localized
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont.statusLabel
        addSubview(label)
    }
}
