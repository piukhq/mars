//
//  SegmentedTableViewCell.swift
//  binkapp
//
//  Created by Paul Tiriteu on 19/02/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import UIKit

class DebugMenuSegmentedTableViewCell: UITableViewCell {
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBAction func segmentedControlAction(_ sender: Any) {
        let version: APIClient.APIVersion?
        
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            version = .v1_2
        case 1:
            version = .v1_3
        default:
            version = nil
        }
        
        if let version = version, Configuration.runtimeConfiguration != .releaseBuild {
            Current.apiClient.overrideVersion = version
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear

        segmentedControl.setTitle("API v1.2", forSegmentAt: 0)
        segmentedControl.setTitle("API v1.3", forSegmentAt: 1)
        
        if Configuration.runtimeConfiguration != .releaseBuild {
            switch Current.apiClient.overrideVersion {
            case .v1_2:
                segmentedControl.selectedSegmentIndex = 0
            case .v1_3:
                segmentedControl.selectedSegmentIndex = 1
            case .none:
                segmentedControl.selectedSegmentIndex = 1
            }
        }
    }
}
