//
//  OnboardingCollectionViewCell.swift
//  binkapp
//
//  Created by Sean Williams on 15/02/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import UIKit

enum PlanCardType: Int {
    case link
    case see
    case store
}

protocol OnboardingCardDelegate: AnyObject {
    func scrollToSection(_ section: PlanCardType?)
}

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
    private weak var delegate: OnboardingCardDelegate?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        CAGradientLayer.removeGradientLayer(for: headerView)
    }
    
    func configureWithWalletPrompt(_ walletPrompt: WalletPrompt) {
        setupShadow(cornerRadius: 20)
        titleLabel.text = walletPrompt.title
        descriptionLabel.text = walletPrompt.body
        
        if UIDevice.current.iPhoneSE {
            titleLabel.font = .walletPromptTitleSmall
            descriptionLabel.font = .walletPromptBodySmall
            titleLabelTopConstraint.constant = 15
        }
        
        headerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toBrowseBrands)))
        
        if case .link = walletPrompt.type {
            CAGradientLayer.makeGradient(for: headerView, firstColor: .binkPurple, secondColor: .blueAccent, startPoint: CGPoint(x: 0.7, y: 0.0))
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
        switch walletPrompt?.type {
        case .see:
            navigateToBrowseBrands(section: .see)
        case .store:
            navigateToBrowseBrands(section: .store)
        default:
            navigateToBrowseBrands()
        }
    }
    
    private func navigateToBrowseBrands(section: PlanCardType? = .link) {
        let viewController = ViewControllerFactory.makeBrowseBrandsViewController()
        delegate = viewController
        let navigatioRequest = ModalNavigationRequest(viewController: viewController) {
            self.delegate?.scrollToSection(section)
        }
        Current.navigate.to(navigatioRequest)
    }
}

// MARK: - Merchant Grid Collection View

extension OnboardingCardCollectionViewCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var plansCount = walletPrompt?.membershipPlans?.count ?? 0
        
        switch walletPrompt?.type {
        case .link:
            if !(plansCount % 2 == 0) {
                plansCount += 1 /// Add extra item for coming soon cell
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
        guard let plans = walletPrompt?.membershipPlans, let walletPrompt = walletPrompt else { return cell }

        if (indexPath.row + 1) > plans.count {
            cell.configureWithPlaceholder(walletPrompt: walletPrompt)
        } else {
            cell.configure(with: plans[safe: indexPath.row], walletPrompt: walletPrompt, showMorePlansCell: plans.count > maxPlansToDisplay && indexPath.row == (maxPlansToDisplay - 1) ? true : false)
        }
                
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let plans = walletPrompt?.membershipPlans else { return }

        if (indexPath.row + 1) > plans.count {
            navigateToBrowseBrands()
        } else {
            /// More plans cell
            if plans.count > maxPlansToDisplay && indexPath.row == (maxPlansToDisplay - 1) {
                toBrowseBrands()
                return
            }
            
            /// All other cells
            if let membershipPlan = plans[safe: indexPath.row] {
                let viewController = ViewControllerFactory.makeAddOrJoinViewController(membershipPlan: membershipPlan)
                let navigationRequest = ModalNavigationRequest(viewController: viewController)
                Current.navigate.to(navigationRequest)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let walletPrompt = walletPrompt else { return .zero }
        return LayoutHelper.WalletDimensions.sizeForWalletPromptCell(walletPrompt: walletPrompt)
    }
}
