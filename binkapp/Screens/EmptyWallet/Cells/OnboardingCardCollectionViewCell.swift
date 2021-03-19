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
    
    private var walletPrompt: WalletPrompt?
    private var maxPlansToDisplay = 8
    
    func configureWithWalletPrompt(_ walletPrompt: WalletPrompt) {
        setupShadow(cornerRadius: 20)
        titleLabel.text = walletPrompt.title
        descriptionLabel.text = walletPrompt.body
        
        switch UIDevice.current.width {
        case .iPhone6Size, .iPhone5Size, .iPhone4Size:
            titleLabel.font = .walletPromptTitleSmall
            descriptionLabel.font = .walletPromptBodySmall
            titleLabelTopConstraint.constant = 15
        default:
            break
        }
        
        headerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toBrowseBrands)))
        
        if case .link = walletPrompt.type {
            CAGradientLayer.makeGradient(for: headerView, firstColor: .binkPurple, secondColor: .blueAccent, startPoint: CGPoint(x: 0.7, y: 0.0))
            titleLabel.textColor = .white
            descriptionLabel.textColor = .white
        } else {
            contentView.backgroundColor = Current.themeManager.color(for: .walletCardBackground)
            titleLabel.textColor = Current.themeManager.color(for: .text)
            descriptionLabel.textColor = Current.themeManager.color(for: .text)
            
            let layout = UICollectionViewFlowLayout()
            layout.sectionInset = UIEdgeInsets(top: 0, left: LayoutHelper.WalletDimensions.cardHorizontalInset, bottom: LayoutHelper.WalletDimensions.cardHorizontalPadding, right: LayoutHelper.WalletDimensions.cardHorizontalInset)
            layout.minimumLineSpacing = LayoutHelper.WalletDimensions.cellInterimSpacing
            layout.minimumInteritemSpacing = LayoutHelper.WalletDimensions.cellInterimSpacing
            self.merchantGridCollectionView?.collectionViewLayout = layout
        }
        
        self.walletPrompt = walletPrompt
        maxPlansToDisplay = walletPrompt.maxNumberOfPlansToDisplay
        merchantGridCollectionView.register(MerchantHeroCell.self, forCellWithReuseIdentifier: "MerchantHeroCell")
        merchantGridCollectionView.translatesAutoresizingMaskIntoConstraints = false
        merchantGridCollectionView.dataSource = self
        merchantGridCollectionView.delegate = self
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
                /// Add extra item for coming soon cell
                plansCount += 1
            }
        case .see, .store:
            if plansCount > maxPlansToDisplay {
                plansCount = maxPlansToDisplay
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
            cell.configure(with: plans[indexPath.row], walletPrompt: walletPrompt, showMoreCell: plans.count > maxPlansToDisplay && indexPath.row == (maxPlansToDisplay - 1) ? true : false)
        }
                
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let plans = walletPrompt?.membershipPlans else { return }

        if (indexPath.row + 1) > plans.count {
            toBrowseBrands()
        } else {
            // TODO: - Scroll to see or store section
            
            if plans.count > maxPlansToDisplay && indexPath.row == (maxPlansToDisplay - 1) {
                toBrowseBrands()
                return
            }
            
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
