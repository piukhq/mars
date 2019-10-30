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

    var shouldShowBinkLogo: Bool {
        switch self {
        case .pll:
            return true
        case .wallet, .barcodeOrCollect:
            return false
        }
    }

    var learningImageSize: CGSize {
        switch self {
        case .pll:
            return CGSize(width: 236, height: 134)
        case .wallet:
            return CGSize(width: 241, height: 209)
        case .barcodeOrCollect:
            return CGSize(width: 244, height: 209)
        }
    }

    var topPadding: CGFloat {
        switch self {
        case .pll:
            return 100
        case .wallet, .barcodeOrCollect:
            return 132
        }
    }
}

class OnboardingLearningView: UIView {
    lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.spacing = 25
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    lazy var binkLogoImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "bink-logo"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    lazy var smallLearningImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    lazy var learningImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    lazy var textStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    lazy var headerTextLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = .subtitle
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy var bodyTextLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = .bodyTextLarge
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let type: OnboardingLearningType

    init(type: OnboardingLearningType) {
        self.type = type
        super.init(frame: .zero)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure() {
        addSubview(stackView)
        stackView.addArrangedSubview(binkLogoImageView)
        stackView.addArrangedSubview(smallLearningImageView)
        stackView.addArrangedSubview(learningImageView)
        stackView.addArrangedSubview(textStackView)
        textStackView.addArrangedSubview(headerTextLabel)
        textStackView.addArrangedSubview(bodyTextLabel)

        binkLogoImageView.isHidden = !type.shouldShowBinkLogo
        smallLearningImageView.isHidden = binkLogoImageView.isHidden
        learningImageView.isHidden = type.shouldShowBinkLogo
        smallLearningImageView.image = UIImage(named: type.learningImageName)
        learningImageView.image = UIImage(named: type.learningImageName)
        headerTextLabel.text = type.headerText
        bodyTextLabel.text = type.bodyText

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: type.topPadding),
            stackView.leftAnchor.constraint(equalTo: leftAnchor, constant: 25),
            stackView.rightAnchor.constraint(equalTo: rightAnchor, constant: -25),

            binkLogoImageView.heightAnchor.constraint(equalToConstant: 82),
            binkLogoImageView.widthAnchor.constraint(equalToConstant: 158),

            smallLearningImageView.heightAnchor.constraint(equalToConstant: 134),
            smallLearningImageView.widthAnchor.constraint(equalToConstant: 236),

            learningImageView.heightAnchor.constraint(equalToConstant: 209),
            learningImageView.widthAnchor.constraint(equalToConstant: 244),
        ])
    }

}

extension LayoutHelper {
    struct OnboardingLearningView {
        struct PLL {

        }

        struct Wallet {

        }

        struct BarcodeOrCollect {

        }
    }
}
