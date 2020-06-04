//
//  PLRStampView.swift
//  binkapp
//
//  Created by Nick Farrant on 12/02/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import UIKit

class PLRStampView: UIView {
    struct Constants {
        static let innerViewWidthHeight: CGFloat = 10
        static let innerViewCornerRadius: CGFloat = 5
        static let outerViewCornerRadius: CGFloat = 12
    }

    init(color: UIColor) {
        super.init(frame: .zero)
        backgroundColor = color
        configureView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureView() {
        layer.cornerRadius = Constants.outerViewCornerRadius

        let innerView = UIView()
        innerView.backgroundColor = .white
        innerView.translatesAutoresizingMaskIntoConstraints = false
        innerView.layer.cornerRadius = Constants.innerViewCornerRadius
        addSubview(innerView)
        NSLayoutConstraint.activate([
            innerView.widthAnchor.constraint(equalToConstant: Constants.innerViewWidthHeight),
            innerView.heightAnchor.constraint(equalToConstant: Constants.innerViewWidthHeight),
            innerView.centerYAnchor.constraint(equalTo: centerYAnchor),
            innerView.centerXAnchor.constraint(equalTo: centerXAnchor),
        ])
    }
}
