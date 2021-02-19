//
//  DebugMenuSegmentedTestTableViewCell.swift
//  binkapp
//
//  Created by Sean Williams on 18/02/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import UIKit

enum PromptType {
    case link
    case see
    case store
}

class DebugMenuPickerTableViewCell: UITableViewCell, UIPickerViewDataSource, UIPickerViewDelegate {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var picker: UIPickerView!
    
    var type: PromptType?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        picker.dataSource = self
        picker.delegate = self
        
        switch type {
        case .link:
            titleLabel.text = "PLL prompt count"
        case .see:
            titleLabel.text = "See prompt count"
        case .store:
            titleLabel.text = "Store prompt count"
        default:
            print("NOTHING")
        }
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        switch type {
        case .link:
            titleLabel.text = "PLL prompt count"
        case .see:
            titleLabel.text = "See prompt count"
        case .store:
            titleLabel.text = "Store prompt count"
        default:
            break
        }
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch type {
        case .link:
            return 4
        case .see:
            return 10
        case .store:
            return 10
        default:
            return 10
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(row + 1)
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        Current.numberOfPromptCells = row + 1
        Current.navigate.close(animated: true) {
            Current.wallet.refreshLocal()
        }
        
//        Current.navigate.back(toRoot: true, animated: true) {
//            Current.wallet.refreshLocal()
//        }
    }
}
