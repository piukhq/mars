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
    @IBOutlet private weak var filterTitleLable: UILabel!
    @IBOutlet private weak var customSeparatorView: UIView!
    
    var cellWasTapped: Bool = false {
        didSet {
            if cellWasTapped {
                imageView.image = UIImage(imageLiteralResourceName: "inactive_check")
            } else {
                imageView.image = UIImage(imageLiteralResourceName: "active_check")
            }
        }
    }
    private(set) var filterTitle: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configureCell(with name: String) {
        backgroundColor = .clear
        filterTitleLable.text = name
        filterTitleLable.textColor = Current.themeManager.color(for: .text)
        filterTitle = name
    }
    
    func hideSeparator() {
        customSeparatorView.isHidden = true
    }
}
