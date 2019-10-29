//
//  SettingsTableViewHeader.swift
//  binkapp
//
//  Created by Max Woodhams on 21/10/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class SettingsTableViewHeader: UIView {
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.headline
        addSubview(label)
        
        return label
    }()
    
    init?(title: String?) {
        guard let title = title else { return nil }
        super.init(frame: .zero)
        customise(with: title)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func customise(with title: String) {
        
        titleLabel.text = title
        backgroundColor = .white
        
        NSLayoutConstraint.activate([
            titleLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 25.0),
            titleLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -25.0),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
