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

        backgroundColor = Current.themeManager.color(for: .viewBackground)
        titleLabel.font = .subtitle
        titleLabel.textColor = Current.themeManager.color(for: .text)
        explainerLabel.font = .bodyTextLarge
        explainerLabel.numberOfLines = 2
        explainerLabel.textColor = Current.themeManager.color(for: .text)

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
                return "loyalty_scanner_widget_title_enter_manually_text".localized
            case .unrecognizedBarcode:
                return "loyalty_scanner_widget_title_unrecognized_barcode_text".localized
            }
        }

        var explainerText: String {
            switch self {
            case .enterManually, .timeout:
                return "loyalty_scanner_widget_explainer_enter_manually_text".localized
            case .unrecognizedBarcode:
                return "loyalty_scanner_widget_explainer_unrecognized_barcode_text".localized
            }
        }

        var imageName: String {
            switch self {
            case .enterManually:
                return "loyalty_scanner_enter_manually"
            case .unrecognizedBarcode, .timeout:
                return "loyalty_scanner_error"
            }
        }
    }
}
