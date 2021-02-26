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

    private lazy var topSpacerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: BinkButtonsView.buttonSpacing).isActive = true
        return view
    }()

    private lazy var bottomSpacerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: BinkButtonsView.bottomSafePadding - BinkButtonsView.buttonSpacing).isActive = true
        return view
    }()

    private lazy var gradientMaskLayer: CAGradientLayer = {
        let gradientMaskLayer = CAGradientLayer()
        gradientMaskLayer.frame = backgroundMaskedView.bounds
        gradientMaskLayer.colors = [UIColor.clear.cgColor, Current.themeManager.color(for: .viewBackground).cgColor]
        gradientMaskLayer.locations = [0, 0.8]
        return gradientMaskLayer
    }()

    private lazy var backgroundMaskedView: UIView = {
        let backgroundMaskedView = UIView(frame: bounds)
        backgroundMaskedView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backgroundMaskedView.backgroundColor = Current.themeManager.color(for: .viewBackground)
        return backgroundMaskedView
    }()

    init(buttons: [BinkButton]) {
        self.buttons = buttons
        super.init(frame: .zero)
        configure()
        Current.themeManager.addObserver(self, handler: #selector(configureForCurrentTheme))
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        Current.themeManager.removeObserver(self)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundMaskedView.layer.mask = gradientMaskLayer

        if !subviews.contains(backgroundMaskedView) {
            insertSubview(backgroundMaskedView, at: 0)
        }
    }

    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        axis = .vertical
        distribution = .fill
        alignment = .center
        spacing = BinkButtonsView.buttonSpacing

        addArrangedSubview(topSpacerView)
        buttons.forEach {
            $0.attachButton(to: self)
        }
        addArrangedSubview(bottomSpacerView)
    }
    
    @objc func configureForCurrentTheme() {
        backgroundMaskedView.backgroundColor = Current.themeManager.color(for: .viewBackground)
    }

    func attach(to view: UIView) {
        view.addSubview(self)
        NSLayoutConstraint.activate([
            bottomAnchor.constraint(equalTo: view.bottomAnchor),
            leftAnchor.constraint(equalTo: view.leftAnchor),
            rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
    }

    func insertAdditionalViews(_ views: [UIView]) {
        for additionalView in views {
            insertArrangedSubview(additionalView, at: 1) // insert underneath the top spacer
        }
    }
}

extension BinkButtonsView {
    static let bottomPadding: CGFloat = 16
    static let buttonSpacing: CGFloat = 25
    static let bottomSafePadding: CGFloat = {
        let window = UIApplication.shared.windows.first { $0.isKeyWindow }
        let safeAreaBottom = window?.safeAreaInsets.bottom ?? 0
        return bottomPadding + safeAreaBottom
    }()
}
