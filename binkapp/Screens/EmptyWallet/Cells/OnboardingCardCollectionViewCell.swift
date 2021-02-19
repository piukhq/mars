//
//  OnboardingCollectionViewCell.swift
//  binkapp
//
//  Created by Sean Williams on 15/02/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import UIKit

class OnboardingCardCollectionViewCell: WalletCardCollectionViewCell {
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var merchantGridCollectionView: UICollectionView!
    @IBOutlet weak var titleLabelTopConstraint: NSLayoutConstraint!
    
    private lazy var width: NSLayoutConstraint = {
        let width = contentView.widthAnchor.constraint(equalToConstant: bounds.size.width)
        width.isActive = true
        return width
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    private var walletPrompt: WalletPrompt?
    
    func configureWithWalletPrompt(_ walletPrompt: WalletPrompt) {
        cornerRadius = 20
        setupShadow()
        titleLabel.text = walletPrompt.title
        titleLabel.textColor = .white
        descriptionLabel.text = walletPrompt.body
        descriptionLabel.textColor = .white
        
        switch UIDevice.current.width {
        case (.iPhone6Size), (.iPhone5Size), (.iPhone4Size):
            titleLabel.font = UIFont.walletPromptTitleSmall
            descriptionLabel.font = UIFont.walletPromptBodySmall
            titleLabelTopConstraint.constant = 15
        default:
            break
        }
        
        headerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toBrowseBrands)))
        
        CAGradientLayer.makeGradient(for: headerView, firstColor: .binkPurple, secondColor: .blueAccent)
        
        self.walletPrompt = walletPrompt
        merchantGridCollectionView.register(MerchantHeroCell.self, forCellWithReuseIdentifier: "MerchantHeroCell")
        merchantGridCollectionView.translatesAutoresizingMaskIntoConstraints = false
        merchantGridCollectionView.dataSource = self
        merchantGridCollectionView.delegate = self
        merchantGridCollectionView.clipsToBounds = true
        
        merchantGridCollectionView.reloadData()
    }
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        width.constant = bounds.size.width
        return contentView.systemLayoutSizeFitting(CGSize(width: targetSize.width, height: targetSize.height))
    }
    
    @objc private func toBrowseBrands() {
        let viewController = ViewControllerFactory.makeBrowseBrandsViewController()
        let navigatioRequest = ModalNavigationRequest(viewController: viewController)
        Current.navigate.to(navigatioRequest)
    }
}

extension OnboardingCardCollectionViewCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var plansCount = walletPrompt?.membershipPlans?.count ?? 0
        
        switch walletPrompt?.type {
        case .link:
            if !(plansCount % 2 == 0) {
                plansCount += 1
            }
        case .see, .store:
            if plansCount > 6 {
                plansCount += 1
            }
        default:
            return 0
        }
        
        return plansCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: MerchantHeroCell = collectionView.dequeue(indexPath: indexPath)
        guard let plans = walletPrompt?.membershipPlans else { return cell }

        if (indexPath.row + 1) > plans.count {
            cell.configureWithPlaceholder(frame: collectionView.frame, walletPrompt: walletPrompt)
        } else {
            cell.configure(with: plans[indexPath.row])
        }
                
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let plans = walletPrompt?.membershipPlans else { return }

        if (indexPath.row + 1) > plans.count {
            toBrowseBrands()
        } else {
            let membershipPlan = plans[indexPath.row]
            let viewController = ViewControllerFactory.makeAddOrJoinViewController(membershipPlan: membershipPlan)
            let navigationRequest = ModalNavigationRequest(viewController: viewController)
            Current.navigate.to(navigationRequest)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return LayoutHelper.WalletDimensions.sizeForWalletPromptCell(viewFrame: collectionView.frame, walletPrompt: walletPrompt)
    }
}


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
        label.font = UIFont.statusLabel
        addSubview(label)
    }
}
