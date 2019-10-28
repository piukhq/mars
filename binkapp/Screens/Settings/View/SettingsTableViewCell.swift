//
//  SettingsTableViewCell.swift
//  binkapp
//
//  Created by Max Woodhams on 14/10/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class SettingsTableViewCell: UITableViewCell {
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .subtitle
        return label
    }()
    
    private lazy var bodyLabel: UILabel = {
        let label = UILabel()
        label.font = .bodyTextLarge
        return label
    }()
    
    private lazy var separator: UIView = {
        let separator = UIView()
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.heightAnchor.constraint(equalToConstant: 1.0).isActive = true
        separator.backgroundColor = UIColor(hexString: "e5e5e5")
        contentView.addSubview(separator)
        return separator
    }()
    
    private lazy var labelStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [subtitleLabel, bodyLabel])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.distribution = .equalSpacing
        contentView.addSubview(stack)
        return stack
    }()
    
    private lazy var chevron: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "iconsChevronRight"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .center
        contentView.addSubview(imageView)
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        customise()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func customise() {
        NSLayoutConstraint.activate([
            labelStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            labelStack.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 25.0),
            labelStack.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -25.0),
            separator.leftAnchor.constraint(equalTo: labelStack.leftAnchor),
            separator.rightAnchor.constraint(equalTo: labelStack.rightAnchor),
            separator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            chevron.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            chevron.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -28.0)
        ])
    }
    
    func setup(with rowData: SettingsRow, showSeparator: Bool) {
        subtitleLabel.text = rowData.title
    
        if let body = rowData.subtitle {
            bodyLabel.isHidden = false
            bodyLabel.text = body
        } else {
            bodyLabel.isHidden = true
        }
        
        separator.isHidden = !showSeparator
    }
}
