//
//  PLRStampView.swift
//  binkapp
//
//  Created by Nick Farrant on 12/02/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import UIKit

class PLRStampView: UIView {
    init(color: UIColor) {
        super.init(frame: .zero)
        backgroundColor = color
        configureView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureView() {
        layer.cornerRadius = 12

        let innerView = UIView()
        innerView.backgroundColor = .white
        innerView.translatesAutoresizingMaskIntoConstraints = false
        innerView.layer.cornerRadius = 5
        addSubview(innerView)
        NSLayoutConstraint.activate([
            innerView.widthAnchor.constraint(equalToConstant: 10),
            innerView.heightAnchor.constraint(equalToConstant: 10),
            innerView.centerYAnchor.constraint(equalTo: centerYAnchor),
            innerView.centerXAnchor.constraint(equalTo: centerXAnchor),
        ])
    }
}
