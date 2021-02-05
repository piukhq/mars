//
//  PLRStampViewCell.swift
//  binkapp
//
//  Created by Nick Farrant on 15/05/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import UIKit

class PLRStampViewCell: UICollectionViewCell {
    enum Constants {
        static let innerViewWidthHeight: CGFloat = 10
        static let innerViewCornerRadius: CGFloat = 5
        static let outerViewCornerRadius: CGFloat = 12
    }

    func configure(index: Int, stampsCollected: Int, state: VoucherState?) {
        backgroundColor = stampColor(index: index, stampsCollected: stampsCollected, state: state)
        configureView()
    }

    private func configureView() {
        layer.cornerRadius = Constants.outerViewCornerRadius

        let innerView = UIView()
        innerView.backgroundColor = Current.themeManager.color(for: .walletCardBackground)
        innerView.translatesAutoresizingMaskIntoConstraints = false
        innerView.layer.cornerRadius = Constants.innerViewCornerRadius
        addSubview(innerView)
        NSLayoutConstraint.activate([
            innerView.widthAnchor.constraint(equalToConstant: Constants.innerViewWidthHeight),
            innerView.heightAnchor.constraint(equalToConstant: Constants.innerViewWidthHeight),
            innerView.centerYAnchor.constraint(equalTo: centerYAnchor),
            innerView.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }

    private func stampColor(index: Int, stampsCollected: Int, state: VoucherState?) -> UIColor {
        if index < stampsCollected {
            switch state {
            case .redeemed:
                return .blueAccent
            case .issued:
                return .greenOk
            case .inProgress:
                return .amberPending
            default:
                return .blueInactive
            }
        } else {
            return .binkDynamicGray
        }
    }
}
