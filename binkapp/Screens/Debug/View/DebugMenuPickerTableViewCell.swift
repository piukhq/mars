//
//  DebugMenuSegmentedTestTableViewCell.swift
//  binkapp
//
//  Created by Sean Williams on 18/02/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import UIKit

class DebugMenuPickerTableViewCell: UITableViewCell, UIPickerViewDataSource, UIPickerViewDelegate {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var picker: UIPickerView!
    
    var debugRow: DebugMenuRow?
    
    func configure(debugRow: DebugMenuRow) {
        self.debugRow = debugRow
        picker.dataSource = self
        picker.delegate = self
        
        switch debugRow.cellType {
        case .picker(.link):
            titleLabel.text = "PLL wallet prompt count"
        case .picker(.see):
            titleLabel.text = "See wallet prompt count"
        case .picker(.store):
            titleLabel.text = "Store wallet prompt count"
        default:
            break
        }
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 60
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(row + 1)
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch debugRow?.cellType {
        case .picker(.link):
            Current.numberOfLinkPromptCells = row + 1
        case .picker(.see):
            Current.numberOfSeePromptCells = row + 1
        case .picker(.store):
            Current.numberOfStorePromptCells = row + 1
        default:
            break
        }
        
        Current.wallet.refreshLocal()
    }
}
