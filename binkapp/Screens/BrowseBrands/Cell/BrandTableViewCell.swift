//
//  BrandTableViewCell.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit
import AlamofireImage

class BrandTableViewCell: UITableViewCell {
    @IBOutlet private weak var logoImageView: UIImageView!
    @IBOutlet private weak var labelsStackView: UIStackView!
    @IBOutlet private weak var brandLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var separatorView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(imageURL: String, brandName: String, description: Bool = false) {
        let url = URL(string: imageURL)!
        
        logoImageView.af_setImage(withURL: url, placeholderImage: UIImage())
        
        brandLabel.font = UIFont.subtitle
        brandLabel.text = brandName
        
        descriptionLabel.isHidden = !description
        descriptionLabel.font = UIFont.bodyTextSmall
        descriptionLabel.text = "can_be_linked_description".localized
    }
    
    func hideSeparatorView() {
        separatorView.isHidden = true
    }
}
