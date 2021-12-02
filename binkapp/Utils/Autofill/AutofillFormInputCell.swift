//
//  AutofillFormInputCell.swift
//  binkapp
//
//  Created by Sean Williams on 24/11/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import UIKit

class AutofillFormInputCell: UICollectionViewCell {
    private lazy var label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        label.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        label.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
        label.rightAnchor.constraint(equalTo: rightAnchor, constant: -10).isActive = true
        return label
    }()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = nil
    }
    
    func configureWithValue(_ value: String) {
        label.text = value
        backgroundColor = .systemGray5
        layer.cornerCurve = .continuous
        layer.cornerRadius = 4
    }
}
