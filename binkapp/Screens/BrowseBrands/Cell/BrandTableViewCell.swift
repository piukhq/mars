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
    
    func configure(imageURL: String?, brandName: String, description: Bool = false) {
        if let imageURLString = imageURL, let url = URL(string: imageURLString) {
            logoImageView.af_setImage(withURL: url, placeholderImage: UIImage())
        }

//        if let path = imageURL {
//            logoImageView.setImage(fromUrlString: path)
//        }
            
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
