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
            return "onboarding_slide1_header".localized
        case .wallet:
            return "onboarding_slide2_header".localized
        case .barcodeOrCollect:
            return "onboarding_slide3_header".localized
        }
    }

    var bodyText: String {
        switch self {
        case .pll:
            return "onboarding_slide1_body".localized
        case .wallet:
            return "onboarding_slide2_body".localized
        case .barcodeOrCollect:
            return "onboarding_slide3_body".localized
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
