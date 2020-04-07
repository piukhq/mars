//
//  LoyaltyScannerWidgetView.swift
//  binkapp
//
//  Created by Nick Farrant on 06/04/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import UIKit

class LoyaltyScannerWidgetView: CustomView {
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

    func scanError() {
        layer.addBinkAnimation(.shake)
        HapticFeedbackUtil.giveFeedback(forType: .notification(type: .error))
        setState(.error)
    }

    func addTarget(_ target: Any?, selector: Selector?) {
        addGestureRecognizer(UITapGestureRecognizer(target: target, action: selector))
    }

    private func configure() {
        clipsToBounds = true
        layer.cornerRadius = 4

        titleLabel.font = .subtitle
        explainerLabel.font = .bodyTextLarge
        explainerLabel.numberOfLines = 2

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
        case error

        var title: String {
            switch self {
            case .enterManually:
                return "Enter manually"
            case .error:
                return "Unrecognised barcode"
            }
        }

        var explainerText: String {
            switch self {
            case .enterManually:
                return "You can also type in the card details yourself."
            case .error:
                return "Please try adding the card manually."
            }
        }

        var imageName: String {
            switch self {
            case .enterManually:
                return "loyalty_scanner_enter_manually"
            case .error:
                return "loyalty_scanner_error"
            }
        }
    }
}
