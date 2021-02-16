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
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var merchantGridCollectionView: UICollectionView!
    
    private lazy var width: NSLayoutConstraint = {
        let width = contentView.widthAnchor.constraint(equalToConstant: bounds.size.width)
        width.isActive = true
        return width
    }()
    
    private lazy var height: NSLayoutConstraint = {
        let height = contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 225)
        height.isActive = true
        return height
    }()
    
    private lazy var gradientLayer: CAGradientLayer = {
        let gradient = CAGradientLayer()
        headerView.layer.insertSublayer(gradient, at: 0)
        return gradient
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        translatesAutoresizingMaskIntoConstraints = false
    }
    
//    private var itemsPerRow: CGFloat = 2
    
    private var walletPrompt: WalletPrompt?
    
    func configureWithWalletPrompt(_ walletPrompt: WalletPrompt) {
        cornerRadius = 20
        setupShadow()
        headerLabel.text = walletPrompt.title
        headerLabel.textColor = .white
        descriptionLabel.text = walletPrompt.body
        descriptionLabel.textColor = .white
        
        headerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toBrowseBrands)))
        
        gradientLayer.frame = headerView.bounds
        gradientLayer.colors = [UIColor.blueAccent.cgColor, UIColor.binkPurple.cgColor]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.7, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.0, y: 0.0)
        
        self.walletPrompt = walletPrompt
        merchantGridCollectionView.register(MerchantHeroCell.self, forCellWithReuseIdentifier: "MerchantHeroCell")
        merchantGridCollectionView.dataSource = self
        merchantGridCollectionView.delegate = self
        merchantGridCollectionView.clipsToBounds = true
    }
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        width.constant = bounds.size.width
        height.constant = 225
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
        walletPrompt?.membershipPlans?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: MerchantHeroCell = collectionView.dequeue(indexPath: indexPath)
        guard let plans = walletPrompt?.membershipPlans else { return cell }
        
        cell.configure(with: plans[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width / 2
        return CGSize(width: width, height: 102)
    }
}


class MerchantHeroCell: UICollectionViewCell {
    override var reuseIdentifier: String? {
        return "MerchantHeroCell"
    }
    
    func configure(with membershipPlan: CD_MembershipPlan) {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
        imageView.setImage(forPathType: .membershipPlanAlternativeHero(plan: membershipPlan))
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        addSubview(imageView)
    }
}
