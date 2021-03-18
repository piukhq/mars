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
//    let spacing: CGFloat = 25.0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        translatesAutoresizingMaskIntoConstraints = false
    }
        
    func configureWithWalletPrompt(_ walletPrompt: WalletPrompt) {
        setupShadow(cornerRadius: 20)
        titleLabel.text = walletPrompt.title
        descriptionLabel.text = walletPrompt.body
        
        switch UIDevice.current.width {
        case .iPhone6Size, .iPhone5Size, .iPhone4Size:
            titleLabel.font = UIFont.walletPromptTitleSmall
            descriptionLabel.font = UIFont.walletPromptBodySmall
            titleLabelTopConstraint.constant = 15
        default:
            break
        }
        
        headerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toBrowseBrands)))
        
        if case .link = walletPrompt.type {
            CAGradientLayer.makeGradient(for: headerView, firstColor: .binkPurple, secondColor: .blueAccent)
            titleLabel.textColor = .white
            descriptionLabel.textColor = .white
        } else {
            titleLabel.textColor = .black
            descriptionLabel.textColor = .black
            
            let layout = UICollectionViewFlowLayout()
            layout.sectionInset = UIEdgeInsets(top: 0, left: LayoutHelper.WalletDimensions.cardHorizontalPadding, bottom: LayoutHelper.WalletDimensions.cardHorizontalPadding, right: LayoutHelper.WalletDimensions.cardHorizontalPadding)
            layout.minimumLineSpacing = LayoutHelper.WalletDimensions.cellInterimSpacing
            layout.minimumInteritemSpacing = LayoutHelper.WalletDimensions.cellInterimSpacing
            self.merchantGridCollectionView?.collectionViewLayout = layout
        }
        
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
                /// Add extra item for coming soon cell
                plansCount += 1
            }
        case .see, .store:
            // Check device, if small then change from 6 to 5?
            break
//            if plansCount > 6 {
//                plansCount += 1
//            }
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
            cell.configure(with: plans[indexPath.row], walletPrompt: walletPrompt)
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
    
    func configure(with membershipPlan: CD_MembershipPlan, walletPrompt: WalletPrompt?) {
        backgroundColor = .lightGray
        
//        if let hexStringColor = membershipPlan.card?.colour {
//            backgroundColor = UIColor(hexString: hexStringColor)
//            layoutIfNeeded()
//            let placeholderName = membershipPlan.account?.planNameCard ?? membershipPlan.account?.planName ?? ""
//            let placeholder = LCDPlaceholderGenerator.generate(with: hexStringColor, planName: placeholderName, destSize: self.frame.size)
//            backgroundColor = UIColor(patternImage: placeholder)
//        }
        
        if case .link = walletPrompt?.type {
            imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
            imageView.setImage(forPathType: .membershipPlanAlternativeHero(plan: membershipPlan))
        } else {
            imageView = UIImageView(frame: CGRect(x: 5, y: 5, width: frame.width - 10, height: frame.height - 10))
            imageView.setImage(forPathType: .membershipPlanIcon(plan: membershipPlan))
            layer.cornerRadius = 10
        }
        
        imageView.contentMode = .scaleAspectFill
//        imageView.clipsToBounds = true
        addSubview(imageView)
        
        let width = frame.width * UIScreen.main.scale
        let height = frame.height * UIScreen.main.scale
        print(width / UIScreen.main.scale)
        print(height / UIScreen.main.scale)
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
