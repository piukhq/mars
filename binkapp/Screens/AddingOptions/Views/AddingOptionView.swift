//
//  AddingOptionView.swift
//  binkapp
//
//  Created by Paul Tiriteu on 02/08/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class AddingOptionView: CustomView {
    @IBOutlet weak var optionTypeImageView: UIImageView!
    @IBOutlet weak var cardsStackView: UIStackView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    private var addingOption: AddingOptions?
    
    func configure(addingOption: AddingOptions) {
        self.addingOption = addingOption
        configureByAddingOption(option: addingOption)
    }
    
    override func configureUI() {
        titleLabel.font = UIFont.headline
        descriptionLabel.font = UIFont.bodyTextLarge
        
        frame.size.height = 150
        
        view.layer.cornerRadius = 10
        clipsToBounds = true
        
        layer.applyDefaultBinkShadow()
        layer.masksToBounds = false
    }
    
    func configureByAddingOption(option: AddingOptions) {
        switch option {
        case .loyalty:
            optionTypeImageView.image = UIImage(named: "loyalty")
            titleLabel.text = "add_loyalty_card_title".localized
            descriptionLabel.text = "scan_a_card_description".localized
            break
        case .browse:
            optionTypeImageView.image = UIImage(named: "browse")
            titleLabel.text = "browse_brands_title".localized
            descriptionLabel.text = "find_and_join_description".localized
            break
        case .payment:
            optionTypeImageView.image = UIImage(named: "payment")
            titleLabel.text = "add_payment_card_title".localized
            descriptionLabel.text = "scan_and_link_description".localized
            cardsStackView.addArrangedSubview(UIImageView(image: UIImage(named: "mastercard")))
            cardsStackView.addArrangedSubview(UIImageView(image: UIImage(named: "amex")))
            cardsStackView.addArrangedSubview(UIImageView(image: UIImage(named: "visa")))
            break
        }
    }
}
