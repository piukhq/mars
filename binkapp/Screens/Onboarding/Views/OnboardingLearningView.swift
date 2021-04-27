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
            return L10n.onboardingSlide1Header
        case .wallet:
            return L10n.onboardingSlide2Header
        case .barcodeOrCollect:
            return L10n.onboardingSlide3Header
        }
    }

    var bodyText: String {
        switch self {
        case .pll:
            return L10n.onboardingSlide1Body
        case .wallet:
            return L10n.onboardingSlide2Body
        case .barcodeOrCollect:
            return L10n.onboardingSlide3Body
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
            return LayoutHelper.Onboarding.learningViewTopPadding
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
        headerTextLabel.textColor = Current.themeManager.color(for: .text)
        bodyTextLabel.text = type.bodyText
        bodyTextLabel.textColor = Current.themeManager.color(for: .text)
        imageTopPaddingConstraint.constant = type.topPadding
    }
}
