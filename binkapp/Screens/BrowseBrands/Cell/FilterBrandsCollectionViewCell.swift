//
//  FilterBrandsCollectionViewCell.swift
//  binkapp
//
//  Created by Pop Dorin on 02/03/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import UIKit

class FilterBrandsCollectionViewCell: UICollectionViewCell {
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var filterTitleLabel: UILabel!
    @IBOutlet private weak var customSeparatorView: UIView!
    
    var cellWasTapped: Bool = false {
        didSet {
            if cellWasTapped {
                imageView.tintColor = .binkDynamicGray2
            } else {
                imageView.tintColor = .blueAccent
            }
        }
    }
    private(set) var filterTitle: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        customSeparatorView.isHidden = false
    }
    
    func configureCell(with name: String) {
        backgroundColor = .clear
        customSeparatorView.backgroundColor = Current.themeManager.color(for: .divider)
        filterTitleLabel.text = name
        filterTitleLabel.textColor = Current.themeManager.color(for: .text)
        filterTitle = name
        imageView.image = UIImage(imageLiteralResourceName: "active_check")
    }
    
    func hideSeparator() {
        customSeparatorView.isHidden = true
    }
}
