//
//  BinkButtonView.swift
//  binkapp
//
//  Created by Nick Farrant on 15/12/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import UIKit

typealias BinkButtonAction = () -> Void

class BinkButtonConfiguration {
    enum ButtonType {
        case pill(BinkPillButton.PillButtonType)
        case gradient
        case plain
    }

    let type: ButtonType
    let title: String
    let enabled: Bool
    let target: Any?
    private let action: BinkButtonAction

    init(type: ButtonType, title: String, enabled: Bool = true, target: Any?, action: @escaping BinkButtonAction) {
        self.type = type
        self.title = title
        self.enabled = enabled
        self.target = target
        self.action = action
    }

    @objc func performAction() {
        action()
    }
}

class BinkButtonsView: UIStackView {
    private let buttons: [BinkButtonConfiguration]

    init(buttons: [BinkButtonConfiguration]) {
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
            let button = makeButton(for: $0)
            button.heightAnchor.constraint(equalToConstant: 52).isActive = true
            addArrangedSubview(button)
        }
    }

    func attach(to view: UIView) {
        // Add and configure view
        view.addSubview(self)
        NSLayoutConstraint.activate([
            bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            leftAnchor.constraint(equalTo: view.leftAnchor),
            rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
    }

    private func makeButton(for configuration: BinkButtonConfiguration) -> UIButton {
        switch configuration.type {
        case .pill(let pillButtonType):
            let button = BinkPillButton()
            button.configureForType(pillButtonType, hasShadow: true)
            button.addTarget(configuration.target, action: #selector(configuration.performAction), for: .touchUpInside)
            return button
        case .gradient:
            let button = BinkGradientButton()
            button.configure(title: configuration.title, hasShadow: true)
            button.addTarget(configuration.target, action: #selector(configuration.performAction), for: .touchUpInside)
            return button
        case .plain:
            let button = UIButton()
            button.setTitle(configuration.title, for: .normal)
            button.addTarget(configuration.target, action: #selector(configuration.performAction), for: .touchUpInside)
            return button
        }
    }
}
