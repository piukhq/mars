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
    }
}
