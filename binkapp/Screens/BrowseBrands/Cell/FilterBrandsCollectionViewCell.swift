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
    
    private var cellWasTapped: Bool = false {
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
        filterTitleLable.text = name
        filterTitle = name
    }

    func switchImage() {
       cellWasTapped = !cellWasTapped
    }
    
    func hideSeparator() {
        customSeparatorView.isHidden = true
    }
}
