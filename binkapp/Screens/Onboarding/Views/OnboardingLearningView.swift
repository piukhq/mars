//
//  OnboardingLearningView.swift
//  binkapp
//
//  Created by Nick Farrant on 23/10/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

enum OnboardingLearningType: Int {
    case pll
    case wallet
    case barcodeOrCollect

    var headerText: String {
        switch self {
        case .pll:
            return "Payment linked loyalty. Magic!"
        case .wallet:
            return "All your cards in one place"
        case .barcodeOrCollect:
            return "Never miss out"
        }
    }

    var bodyText: String {
        switch self {
        case .pll:
            return "Link your payment cards to selected loyalty cards and earn rewards and benefits automatically when you pay."
        case .wallet:
            return "Store all your loyalty cards in a single digital wallet. View your rewards and points balances any time, anywhere."
        case .barcodeOrCollect:
            return "Show your loyalty cards’ barcodes on screen, or collect points instantly when you pay. Whichever way, you’re always covered."
        }
    }

    var learningImageName: String {
        switch self {
        case .pll:
            return "onboarding1"
        case .wallet:
            return "onboarding2"
        case .barcodeOrCollect:
            return "onboarding3"
        }
    }

    var topPadding: CGFloat {
        switch self {
        case .pll:
            return 0
        case .wallet, .barcodeOrCollect:
            return 50
        }
    }
}

class OnboardingLearningView: CustomView {
    @IBOutlet private weak var learningImageView: UIImageView!
    @IBOutlet private weak var headerTextLabel: UILabel!
    @IBOutlet private weak var bodyTextLabel: UILabel!
    @IBOutlet private weak var imageTopPaddingConstraint: NSLayoutConstraint!
    
    func configure(forType type: OnboardingLearningType) {
        learningImageView.image = UIImage(named: type.learningImageName)
        headerTextLabel.text = type.headerText
        bodyTextLabel.text = type.bodyText
        imageTopPaddingConstraint.constant = type.topPadding
    }

}
