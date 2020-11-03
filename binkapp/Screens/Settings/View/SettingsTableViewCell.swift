//
//  SettingsTableViewCell.swift
//  binkapp
//
//  Created by Max Woodhams on 14/10/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class SettingsTableViewCell: UITableViewCell {
    
    private enum Constants {
        static let separatorHeight: CGFloat = 1.0
        static let leftRightPadding: CGFloat = 25.0
        static let chevronRightPadding: CGFloat = 28.0
        static let chevronWidthHeight: CGFloat = 20.0
        static let actionRequiredIndicatorHeight: CGFloat = 10
    }
    
    private lazy var titleStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [subtitleLabel, actionRequiredIndicator, spacer])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.distribution = .fill
        stack.alignment = .center
        stack.spacing = 10
        contentView.addSubview(stack)
        return stack
    }()
    
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
        separator.backgroundColor = UIColor(hexString: "e5e5e5")
        contentView.addSubview(separator)
        return separator
    }()
    
    private lazy var labelStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleStack, bodyLabel])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.distribution = .equalSpacing
        contentView.addSubview(stack)
        return stack
    }()
    
    private lazy var actionRequiredIndicator: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemRed
        view.layer.cornerRadius = 5
        contentView.addSubview(view)
        return view
    }()
    
    private lazy var spacer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
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
            separator.heightAnchor.constraint(equalToConstant: Constants.separatorHeight),
            separator.bottomAnchor.constraint(equalTo: bottomAnchor),
            separator.leftAnchor.constraint(equalTo: leftAnchor, constant: Constants.leftRightPadding),
            separator.rightAnchor.constraint(equalTo: rightAnchor, constant: -Constants.leftRightPadding),
            labelStack.centerYAnchor.constraint(equalTo: centerYAnchor),
            labelStack.leftAnchor.constraint(equalTo: leftAnchor, constant: Constants.leftRightPadding),
            actionRequiredIndicator.heightAnchor.constraint(equalToConstant: Constants.actionRequiredIndicatorHeight),
            actionRequiredIndicator.widthAnchor.constraint(equalToConstant: Constants.actionRequiredIndicatorHeight),
            spacer.heightAnchor.constraint(equalToConstant: Constants.actionRequiredIndicatorHeight),
            chevron.heightAnchor.constraint(equalToConstant: Constants.chevronWidthHeight),
            chevron.widthAnchor.constraint(equalToConstant: Constants.chevronWidthHeight),
            chevron.rightAnchor.constraint(equalTo: rightAnchor, constant: -Constants.chevronRightPadding),
            chevron.centerYAnchor.constraint(equalTo: centerYAnchor)
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
        actionRequiredIndicator.isHidden = !rowData.actionRequired
    }
    
    
    /// This will be called on didSelectRowAtIndexPath
    func removeActionRequired() {
        actionRequiredIndicator.removeFromSuperview()
    }
}
