//
//  BinkButtonView.swift
//  binkapp
//
//  Created by Nick Farrant on 15/12/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import UIKit

class BinkButtonsView: UIStackView {
    private var buttons: [BinkButton]

    init(buttons: [BinkButton]) {
        self.buttons = buttons
        super.init(frame: .zero)
        configure()
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        axis = .vertical
        distribution = .fill
        alignment = .center
        spacing = 25

        buttons.forEach {
            $0.attachButton(to: self)
        }
    }

    func attach(to view: UIView) {
        view.addSubview(self)
        NSLayoutConstraint.activate([
            bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -BinkButtonsView.bottomPadding),
            leftAnchor.constraint(equalTo: view.leftAnchor),
            rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
    }
}

extension BinkButtonsView {
    static let bottomPadding: CGFloat = 16
    static let bottomSafePadding: CGFloat = {
        let safeAreaBottom = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
        return bottomPadding + safeAreaBottom
    }()
}
