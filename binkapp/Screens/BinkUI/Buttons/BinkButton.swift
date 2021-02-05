//
//  BinkButton.swift
//  binkapp
//
//  Created by Nick Farrant on 16/12/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import UIKit

typealias BinkButtonAction = () -> Void

class BinkButton {
    enum ButtonType {
        case pill(BinkPillButton.PillButtonType)
        case gradient
        case plain
    }

    private let type: ButtonType
    private var title: String
    private let action: BinkButtonAction
    private lazy var button = makeButton()

    var enabled: Bool {
        didSet {
            button.isEnabled = enabled
        }
    }

    init(type: ButtonType, title: String = "", enabled: Bool = true, action: @escaping BinkButtonAction) {
        self.type = type
        self.title = title
        self.enabled = enabled
        self.action = action
    }

    func toggleLoading(isLoading: Bool) {
        guard let button = button as? BinkPillButton else { return }
        if isLoading {
            button.startLoading()
        } else {
            button.stopLoading()
        }
    }

    func setTitle(_ title: String) {
        button.setTitle(title, for: .normal)
    }

    @objc private func performAction() {
        action()
    }

    private func makeButton() -> UIButton {
        switch type {
        case .pill(let pillButtonType):
            let button = BinkPillButton(type: .system)
            button.configureForType(pillButtonType, hasShadow: true)
            button.isEnabled = enabled
            button.setTitleColor(.white, for: .normal)
            button.addTarget(self, action: #selector(performAction), for: .touchUpInside)
            return button
        case .gradient:
            let button = BinkGradientButton(type: .system)
            button.configure(title: title, hasShadow: true)
            button.isEnabled = enabled
            button.setTitleColor(.white, for: .normal)
            button.addTarget(self, action: #selector(performAction), for: .touchUpInside)
            return button
        case .plain:
            let button = BinkTrackableButton(type: .system)
            button.setTitle(title, for: .normal)
            button.titleLabel?.font = .buttonText
            button.setTitleColor(Current.themeManager.color(for: .text), for: .normal)
            button.isEnabled = enabled
            button.addTarget(self, action: #selector(performAction), for: .touchUpInside)
            return button
        }
    }

    func attachButton(to stackView: UIStackView) {
        stackView.addArrangedSubview(button)
        button.heightAnchor.constraint(equalToConstant: 52).isActive = true
        button.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 0.75).isActive = true
    }
}
