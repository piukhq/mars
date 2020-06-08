//
//  SettingsTableViewFooter.swift
//  binkapp
//
//  Created by Nick Farrant on 08/06/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import UIKit

class SettingsTableViewFooter: UIView {
    static let height: CGFloat = 80
    
    lazy var labelsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [emailLabel, versionLabel])
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .center
        return stackView
    }()
    
    lazy var emailLabel: UILabel = {
        let label = UILabel()
        label.text = Current.userManager.currentEmailAddress ?? ""
        label.font = .navbarHeaderLine2
        label.textColor = .disabledTextGrey
        return label
    }()
    
    lazy var versionLabel: UILabel = {
        let label = UILabel()
        label.text = "Bink v\(Bundle.shortVersionNumber ?? "") \(Bundle.bundleVersion ?? "")"
        label.font = .navbarHeaderLine2
        label.textColor = .disabledTextGrey
        return label
    }()
    
    init() {
        super.init(frame: .zero)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        backgroundColor = .white
        addSubview(labelsStackView)
        NSLayoutConstraint.activate([
            labelsStackView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            labelsStackView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            labelsStackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
