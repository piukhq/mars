//
//  MerchantHeroCell.swift
//  binkapp
//
//  Created by Sean Williams on 22/02/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import UIKit

class MerchantHeroCell: UICollectionViewCell {
    private var imageView = UIImageView()
    private lazy var label: UILabel = {
        let label = UILabel()
        label.text = L10n.walletPromptMoreComingSoon
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont.statusLabel
        return label
    }()
    
    override var reuseIdentifier: String? {
        return "MerchantHeroCell"
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        label.removeFromSuperview()
    }
    
    func configure(with membershipPlan: CD_MembershipPlan?, walletPrompt: WalletPrompt, showMorePlansCell: Bool, indexPath: IndexPath) {
        guard let membershipPlan = membershipPlan else { return }
        let hexStringColor = membershipPlan.card?.colour ?? ""
        backgroundColor = UIColor(hexString: hexStringColor)
        layoutIfNeeded()
        imageView.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        tag = indexPath.row
        
        if case .link = walletPrompt.type {
            let placeholderName = membershipPlan.account?.planName ?? membershipPlan.account?.planNameCard ?? ""
            let placeholder = LCDPlaceholderGenerator.generate(with: hexStringColor, planName: placeholderName, destSize: frame.size, font: .textFieldLabel)
            backgroundColor = UIColor(patternImage: placeholder)
            layer.cornerRadius = 0
            imageView.layer.cornerRadius = 0
            ImageService.getImage(forPathType: .membershipPlanAlternativeHero(plan: membershipPlan), traitCollection: traitCollection) { [weak self] image in
                if self?.tag == indexPath.row {
                    self?.imageView.image = image
                }
            }
        } else {
            if showMorePlansCell {
                imageView.frame = CGRect(x: 10, y: 10, width: frame.width - 20, height: frame.height - 20)
                backgroundColor = .binkDynamicGray2
                imageView.image = UIImage(systemName: "ellipsis")
                imageView.contentMode = .scaleAspectFit
                imageView.tintColor = .white
            } else {
                ImageService.getImage(forPathType: .membershipPlanIcon(plan: membershipPlan), traitCollection: traitCollection) { [weak self] image in
                    if self?.tag == indexPath.row {
                        self?.imageView.image = image
                    }
                }
                backgroundColor = .clear
                imageView.contentMode = .scaleAspectFill
            }
            
            layer.cornerRadius = 10
            layer.cornerCurve = .continuous
            imageView.layer.cornerRadius = 10
            imageView.layer.cornerCurve = .continuous
            imageView.clipsToBounds = true
        }
        
        addSubview(imageView)
    }
    
    func configureWithPlaceholder(walletPrompt: WalletPrompt) {
        backgroundColor = UIColor(hexString: "102F82").darker(by: 5.0)
        layer.cornerRadius = 0
        let size = LayoutHelper.WalletDimensions.sizeForWalletPromptCell(walletPrompt: walletPrompt)
        label.frame = CGRect(origin: .zero, size: size)
        addSubview(label)
    }
}
