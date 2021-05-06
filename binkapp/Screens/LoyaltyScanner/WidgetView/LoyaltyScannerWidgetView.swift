//
//  LoyaltyScannerWidgetView.swift
//  binkapp
//
//  Created by Nick Farrant on 06/04/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import UIKit

class LoyaltyScannerWidgetView: CustomView {
    enum Constants {
        static let cornerRadius: CGFloat = 4
    }

    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var explainerLabel: UILabel!

    private var state: WidgetState = .enterManually

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }

    func unrecognizedBarcode() {
        error(state: .unrecognizedBarcode)
    }

    func timeout() {
        error(state: .timeout)
    }

    func addTarget(_ target: Any?, selector: Selector?) {
        addGestureRecognizer(UITapGestureRecognizer(target: target, action: selector))
    }

    func configure() {
        clipsToBounds = true
        layer.cornerRadius = Constants.cornerRadius

        backgroundColor = Current.themeManager.color(for: .viewBackground).withAlphaComponent(0.5)
        titleLabel.font = .subtitle
        titleLabel.textColor = Current.themeManager.color(for: .text)
        explainerLabel.font = .bodyTextLarge
        explainerLabel.numberOfLines = 2
        explainerLabel.textColor = Current.themeManager.color(for: .text)
        imageView.tintColor = .green

        setState(state)
    }

    private func error(state: WidgetState) {
        layer.addBinkAnimation(.shake)
        HapticFeedbackUtil.giveFeedback(forType: .notification(type: .error))
        setState(state)
    }

    private func setState(_ state: WidgetState) {
        titleLabel.text = state.title
        explainerLabel.text = state.explainerText
        imageView.image = UIImage(named: state.imageName)
        self.state = state
    }
}

extension LoyaltyScannerWidgetView {
    enum WidgetState {
        case enterManually
        case unrecognizedBarcode
        case timeout

        var title: String {
            switch self {
            case .enterManually, .timeout:
                return L10n.loyaltyScannerWidgetTitleEnterManuallyText
            case .unrecognizedBarcode:
                return L10n.loyaltyScannerWidgetTitleUnrecognizedBarcodeText
            }
        }

        var explainerText: String {
            switch self {
            case .enterManually, .timeout:
                return L10n.loyaltyScannerWidgetExplainerEnterManuallyText
            case .unrecognizedBarcode:
                return L10n.loyaltyScannerWidgetExplainerUnrecognizedBarcodeText
            }
        }

        var imageName: String {
            switch self {
            case .enterManually:
                return Asset.loyaltyScannerEnterManually.name
            case .unrecognizedBarcode, .timeout:
                return Asset.loyaltyScannerError.name
            }
        }
    }
}
