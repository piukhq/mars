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

final class JoinCardFactory {
    enum WalletType {
        case loyalty
        case payment
    }

    static func makeJoinCards(forWallet walletType: WalletType) -> [JoinCard] {
        var joinCards: [JoinCard] = []

        // Decisioning for whether to show join card for plan

        if walletType == .loyalty {
            guard let plans = Current.wallet.membershipPlans else {
                return joinCards
            }

            plans.filter({ $0.featureSet?.planCardType == .link }).forEach { plan in
                let planJoinCardHasBeenDismissed = UserDefaults.standard.bool(forKey: JoinCard.userDefaultsKey(forPlan: plan))
                print("\(plan.account?.planName ?? "") has been dismissed: \(planJoinCardHasBeenDismissed)")
                if !planJoinCardHasBeenDismissed {
                    joinCards.append(JoinCard(membershipPlan: plan))
                }
            }
        }

        return joinCards
    }
}

struct JoinCard {
    static func userDefaultsKey(forPlan plan: CD_MembershipPlan) -> String {
        // TODO: What if the plan returns no plan name?
        return "join_card_\(plan.account?.planName ?? "")_was_dismissed"
    }

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

    var iconImageUrl: URL? {
        guard let urlString = membershipPlan.firstIconImage()?.url else {
            return nil
        }
        return URL(string: urlString) ?? nil
    }

    var userDefaultsKey: String {
        return JoinCard.userDefaultsKey(forPlan: membershipPlan)
    }
}
