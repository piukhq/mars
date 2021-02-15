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
    

    override func awakeFromNib() {
        super.awakeFromNib()
        translatesAutoresizingMaskIntoConstraints = false
    }
}

