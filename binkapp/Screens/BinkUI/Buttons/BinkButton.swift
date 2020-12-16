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
    private let title: String
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

    func startLoading() {
        guard let button = button as? BinkPillButton else { return }
        button.startLoading()
    }

    func stopLoading() {
        guard let button = button as? BinkPillButton else { return }
        button.stopLoading()
    }

    @objc func performAction() {
        action()
    }

    private func makeButton() -> UIButton {
        switch type {
        case .pill(let pillButtonType):
            let button = BinkPillButton()
            button.configureForType(pillButtonType, hasShadow: true)
            button.isEnabled = enabled
            button.addTarget(self, action: #selector(performAction), for: .touchUpInside)
            return button
        case .gradient:
            let button = BinkGradientButton()
            button.configure(title: title, hasShadow: true)
            button.isEnabled = enabled
            button.addTarget(self, action: #selector(performAction), for: .touchUpInside)
            return button
        case .plain:
            let button = UIButton()
            button.setTitle(title, for: .normal)
            button.setTitleColor(.black, for: .normal)
            button.titleLabel?.font = .buttonText
            button.isEnabled = enabled
            button.addTarget(self, action: #selector(performAction), for: .touchUpInside)
            return button
        }
    }

    func attachButton(to view: UIView) {
        if let stackView = view as? UIStackView {
            stackView.addArrangedSubview(button)
        } else {
            view.addSubview(button)
        }
        button.heightAnchor.constraint(equalToConstant: 52).isActive = true
        button.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.75).isActive = true
    }
}
