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
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            Current.apiClient.overrideVersion = .v1_2
        case 1:
            Current.apiClient.overrideVersion = .v1_3
        default:
            break
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        segmentedControl.setTitle("API v1.2", forSegmentAt: 0)
        segmentedControl.setTitle("API v1.3", forSegmentAt: 1)
        
        switch Current.apiClient.overrideVersion {
        case .v1_2:
            segmentedControl.selectedSegmentIndex = 0
        case .v1_3:
            segmentedControl.selectedSegmentIndex = 1
        case .none:
            segmentedControl.selectedSegmentIndex = 0
        }
    }
}
