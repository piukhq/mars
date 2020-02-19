//
//  SegmentedTableViewCell.swift
//  binkapp
//
//  Created by Paul Tiriteu on 19/02/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import UIKit

class SegmentedTableViewCell: UITableViewCell {
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBAction func segmentedControlAction(_ sender: Any) {
        if segmentedControl.selectedSegmentIndex == 0 {
            ApiManager.apiVersion = .v11
        } else {
            ApiManager.apiVersion = .v12
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        segmentedControl.setTitle("API v1.1", forSegmentAt: 0)
        segmentedControl.setTitle("API v1.2", forSegmentAt: 1)
        
        if ApiManager.apiVersion == .v11 {
            segmentedControl.selectedSegmentIndex = 0
        } else {
            segmentedControl.selectedSegmentIndex = 1
        }
    }
}
