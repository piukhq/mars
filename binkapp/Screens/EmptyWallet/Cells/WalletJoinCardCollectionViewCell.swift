//
//  WalletJoinCardCollectionViewCell.swift
//  binkapp
//
//  Created by Nick Farrant on 10/10/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class WalletJoinCardCollectionViewCell: WalletCardCollectionViewCell {
    @IBOutlet private weak var brandIconImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var detailLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func configureWithJoinCard(_ joinCard: JoinCard) {
        setupShadow()
        
        titleLabel.text = joinCard.title
        detailLabel.text = joinCard.body
    }
}

final class JoinCardFactory {
    enum WalletType {
        case loyalty
        case payment
    }

    static func makeJoinCards(forWallet walletType: WalletType) -> [JoinCard]? {
        return Current.wallet.membershipPlans?.filter({ $0.featureSet?.planCardType == .link }).map {
            JoinCard(membershipPlan: $0)
        }
    }
}

struct JoinCard {
    private let membershipPlan: CD_MembershipPlan

    init(membershipPlan: CD_MembershipPlan) {
        self.membershipPlan = membershipPlan
    }

    var title: String? {
        return membershipPlan.account?.planName
    }

    var body: String? {
        return "Link this card to your payment cards to automatically collect rewards."
    }
}
