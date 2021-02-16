//
//  OnboardingCollectionViewCell.swift
//  binkapp
//
//  Created by Sean Williams on 15/02/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import UIKit

class OnboardingCardCollectionViewCell: WalletCardCollectionViewCell {
//    enum Constants {
//        static let stampViewWidth: CGFloat = 57
////        static let interimSpacing: CGFloat = 34
//    }
    
//    private lazy var layout: UICollectionViewFlowLayout = {
//        let flowLayout = UICollectionViewFlowLayout()
//        flowLayout.estimatedItemSize = CGSize(width: 1, height: 1) // To invoke automatic self sizing
//        return flowLayout
//    }()
    
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
        
        self.walletPrompt = walletPrompt
        merchantGridCollectionView.register(MerchantHeroCell.self, forCellWithReuseIdentifier: "MerchantHeroCell")
        merchantGridCollectionView.dataSource = self
        merchantGridCollectionView.delegate = self
        merchantGridCollectionView.clipsToBounds = false
    }
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        width.constant = bounds.size.width
        height.constant = 225
        
        return contentView.systemLayoutSizeFitting(CGSize(width: targetSize.width, height: targetSize.height))
    }
}

extension OnboardingCardCollectionViewCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        walletPrompt?.numberOfRows ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: MerchantHeroCell = collectionView.dequeue(indexPath: indexPath)
        cell.backgroundColor = .black15
        cell.configure()
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
    
    func configure() {
//        let imageView = UIImageView(image: UIImage(named: "bink-logo"))
//        imageView.bounds = self.bounds
//        imageView.contentMode = .scaleAspectFit
//
//        addSubview(imageView)
    }
}
