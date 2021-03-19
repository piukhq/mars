//
//  FeatureFlagsTableViewCell.swift
//  binkapp
//
//  Created by Sean Williams on 22/02/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import UIKit

protocol FeatureFlagCellDelegate: AnyObject {
    func featureWasToggled(_ feature: Feature?)
}

class FeatureFlagsTableViewCell: UITableViewCell {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var toggleSwitch: BinkSwitch!
    
    private var feature: Feature?
    private weak var delegate: FeatureFlagCellDelegate?
    
    func configure(_ feature: Feature, delegate: FeatureFlagCellDelegate) {
        self.feature = feature
        self.delegate = delegate
        
        titleLabel.text = feature.title
        titleLabel.textColor = Current.themeManager.color(for: .text)
        descriptionLabel.text = feature.description
        descriptionLabel.textColor = .binkDynamicGray3
        descriptionLabel.isHidden = feature.description == nil ? true : false
        toggleSwitch.isOn = feature.isEnabled
        selectionStyle = .none
    }
    
    @IBAction func didToggle(_ sender: Any) {
        guard let feature = feature else { return }
        toggleSwitch.isGradientVisible = toggleSwitch.isOn
        Current.featureManager.toggle(feature, enabled: toggleSwitch.isOn)
        delegate?.featureWasToggled(feature)
    }
}
