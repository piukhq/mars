//
//  WalletJoinCardCollectionViewCell.swift
//  binkapp
//
//  Created by Nick Farrant on 10/10/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit
import AlamofireImage

class WalletJoinCardCollectionViewCell: WalletCardCollectionViewCell {
    @IBOutlet private weak var brandIconImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var detailLabel: UILabel!

    private var joinCard: JoinCard!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func configureWithJoinCard(_ joinCard: JoinCard) {
        self.joinCard = joinCard

        setupShadow()
        
        titleLabel.text = joinCard.title
        detailLabel.text = joinCard.body
        if let iconImageUrl = joinCard.iconImageUrl {
            brandIconImageView.af_setImage(withURL: iconImageUrl)
        }
    }

    @IBAction private func dismissButtonWasPressed() {
        UserDefaults.standard.set(true, forKey: joinCard.userDefaultsKey)
        Current.wallet.refreshLocal()
    }
}
