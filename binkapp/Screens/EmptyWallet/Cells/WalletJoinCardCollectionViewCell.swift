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

    private var walletPrompt: WalletPrompt!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func configureWithWalletPrompt(_ walletPrompt: WalletPrompt) {
        self.walletPrompt = walletPrompt

        setupShadow()
        
        titleLabel.text = walletPrompt.title
        detailLabel.text = walletPrompt.body
        if let iconImageUrl = walletPrompt.iconImageUrl {
            brandIconImageView.af_setImage(withURL: iconImageUrl)
        } else {
            brandIconImageView.image = UIImage(named: walletPrompt.iconImageName ?? "")
        }
    }

    @IBAction private func dismissButtonWasPressed() {
        Current.userDefaults.set(true, forKey: walletPrompt.userDefaultsDismissKey)
        Current.wallet.refreshLocal()
    }
}
