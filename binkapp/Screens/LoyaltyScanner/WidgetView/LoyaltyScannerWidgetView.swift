//
//  LoyaltyScannerWidgetView.swift
//  binkapp
//
//  Created by Nick Farrant on 06/04/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import UIKit

class LoyaltyScannerWidgetView: UIView {

    lazy var imageView: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 20, y: 20, width: 48, height: 48))
        imageView.image = UIImage(named: "attention")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Subtitle"
        label.font = .subtitle
        return label
    }()

    lazy var explainerLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.text = """
        One line of explainer text
        Second line of explainer text
        """
        label.font = UIFont(name: "NunitoSans-Light", size: 17.0) ?? UIFont()
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure() {
        backgroundColor = .white
        addSubview(imageView)
        addSubview(titleLabel)
        addSubview(explainerLabel)
        titleLabel.frame = CGRect(x: 84, y: 17, width: frame.width - (84 + 20), height: 22)
        explainerLabel.frame = CGRect(x: 84, y: 40, width: frame.width - (84 + 20), height: 44)
    }

}
