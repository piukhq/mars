//
//  OnboardingCollectionViewCell.swift
//  binkapp
//
//  Created by Sean Williams on 15/02/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import UIKit

class OnboardingCardCollectionViewCell: WalletCardCollectionViewCell {
    @IBOutlet private weak var headerView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var merchantGridCollectionView: UICollectionView!
    @IBOutlet private weak var titleLabelTopConstraint: NSLayoutConstraint!
    
    private lazy var width: NSLayoutConstraint = {
        let width = contentView.widthAnchor.constraint(equalToConstant: bounds.size.width)
        width.isActive = true
        return width
    }()
    
    private var walletPrompt: WalletPrompt?
    private var maxPlansToDisplay = 8
    
    override func prepareForReuse() {
        super.prepareForReuse()
        CAGradientLayer.removeGradientLayer(for: headerView)
    }
    
    func configureWithWalletPrompt(_ walletPrompt: WalletPrompt) {
        setupShadow(cornerRadius: 20)
        titleLabel.text = walletPrompt.title
        descriptionLabel.text = walletPrompt.body
        
        if UIDevice.current.isSmallSize {
            titleLabel.font = .walletPromptTitleSmall
            descriptionLabel.font = .walletPromptBodySmall
            titleLabelTopConstraint.constant = 15
        }
        
        self.walletPrompt = walletPrompt
        maxPlansToDisplay = walletPrompt.maxNumberOfPlansToDisplay
        merchantGridCollectionView.register(MerchantHeroCell.self, forCellWithReuseIdentifier: "MerchantHeroCell")
        merchantGridCollectionView.translatesAutoresizingMaskIntoConstraints = false
        merchantGridCollectionView.dataSource = self
        merchantGridCollectionView.delegate = self
        merchantGridCollectionView.reloadData()
        
        headerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toBrowseBrands)))
        
        if case .link = walletPrompt.type {
            CAGradientLayer.makeGradient(for: headerView, firstColor: .binkGradientBlueRight, secondColor: .binkGradientBlueLeft, startPoint: CGPoint(x: 0.7, y: 0.0))
            titleLabel.textColor = .white
            descriptionLabel.textColor = .white

            let layout = UICollectionViewFlowLayout()
            layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            layout.minimumLineSpacing = 0
            layout.minimumInteritemSpacing = 0
            merchantGridCollectionView?.collectionViewLayout = layout
        } else {
            contentView.backgroundColor = Current.themeManager.color(for: .walletCardBackground)
            titleLabel.textColor = Current.themeManager.color(for: .text)
            descriptionLabel.textColor = Current.themeManager.color(for: .text)
            
            let layout = UICollectionViewFlowLayout()
            layout.sectionInset = UIEdgeInsets(top: 0, left: LayoutHelper.WalletDimensions.cardHorizontalInset, bottom: LayoutHelper.WalletDimensions.cardHorizontalPadding, right: LayoutHelper.WalletDimensions.cardHorizontalInset)
            layout.minimumLineSpacing = LayoutHelper.WalletDimensions.cellInterimSpacing
            layout.minimumInteritemSpacing = LayoutHelper.WalletDimensions.cellInterimSpacing
            merchantGridCollectionView?.collectionViewLayout = layout
        }
    }
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        width.constant = bounds.size.width
        return contentView.systemLayoutSizeFitting(CGSize(width: targetSize.width, height: targetSize.height))
    }
    
    @objc private func toBrowseBrands() {
        switch walletPrompt?.type {
        case .see:
            navigateToBrowseBrands(section: .view)
        case .store:
            navigateToBrowseBrands(section: .store)
        default:
            navigateToBrowseBrands()
        }
    }
    
    private func navigateToBrowseBrands(section: CD_FeatureSet.PlanCardType? = nil) {
        let viewController = ViewControllerFactory.makeBrowseBrandsViewController(section: section?.walletPromptSectionIndex)
        let navigationRequest = ModalNavigationRequest(viewController: viewController)
        Current.navigate.to(navigationRequest)
    }
}

// MARK: - Merchant Grid Collection View

extension OnboardingCardCollectionViewCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var plansCount = walletPrompt?.membershipPlans?.count ?? 0
        
        if case .link = walletPrompt?.type {
            if !(plansCount % 2 == 0) {
                plansCount += 1 /// Add extra item for coming soon cell
            }
        }
        
        if plansCount > maxPlansToDisplay {
            plansCount = maxPlansToDisplay
        }
        return plansCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: MerchantHeroCell = collectionView.dequeue(indexPath: indexPath)
        guard let plans = walletPrompt?.membershipPlans, let walletPrompt = walletPrompt else { return cell }

        if (indexPath.row + 1) > plans.count {
            cell.configureWithPlaceholder(walletPrompt: walletPrompt)
        } else {
            let shouldShowMorePlansCell = plans.count > maxPlansToDisplay && indexPath.row == (maxPlansToDisplay - 1) ? true : false
            cell.configure(with: plans[safe: indexPath.row], walletPrompt: walletPrompt, showMorePlansCell: shouldShowMorePlansCell, indexPath: indexPath)
        }
                
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let plans = walletPrompt?.membershipPlans else { return }

            /// See & Store more plans cell
            switch walletPrompt?.type {
            case .see, .store:
                if plans.count > maxPlansToDisplay && indexPath.row == (maxPlansToDisplay - 1) {
                    toBrowseBrands()
                    return
                }
            default:
                if (indexPath.row + 1) > plans.count {
                    navigateToBrowseBrands()
                    return
                }
            }
            
            /// All other cells
            if let membershipPlan = plans[safe: indexPath.row] {
                let viewController = ViewControllerFactory.makeAddOrJoinViewController(membershipPlan: membershipPlan)
                let navigationRequest = ModalNavigationRequest(viewController: viewController)
                Current.navigate.to(navigationRequest)
            }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let walletPrompt = walletPrompt else { return .zero }
        return LayoutHelper.WalletDimensions.sizeForWalletPromptCell(walletPrompt: walletPrompt)
    }
}
