//
//  FeatureFlagsTableViewCell.swift
//  binkapp
//
//  Created by Sean Williams on 22/02/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import UIKit

class FeatureFlagsTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var toggleSwitch: BinkSwitch!
    
    private var feature: Feature?
    
    func configure(_ feature: Feature?) {
        guard let feature = feature else { return }
        self.feature = feature
        titleLabel.text = feature.title
        titleLabel.textColor = Current.themeManager.color(for: .text)
        descriptionLabel.text = feature.description
        descriptionLabel.textColor = .binkDynamicGray3
        descriptionLabel.isHidden = feature.description == nil ? true : false
        toggleSwitch.isOn = feature.isEnabled
    }
    
    @IBAction func didToggle(_ sender: Any) {
        toggleSwitch.isGradientVisible = toggleSwitch.isOn
        feature?.toggle(isOn: toggleSwitch.isOn)
    }
}
