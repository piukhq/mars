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

class DebugMenuSegmentedTestTableViewCell: UITableViewCell, UIPickerViewDataSource, UIPickerViewDelegate {
    @IBOutlet weak var picker: UIPickerView!
    
    var type: PromptType?
    
//    init(type: PromptType) {
//        super.init(style: .default, reuseIdentifier: "SettingCell")
//        self.type = type
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        picker.dataSource = self
        picker.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        switch type {
        case .link:
            print("LINK")
        case .see:
            print("See")
        case .store:
            print("Store")
        default:
            print("NOTHING")
        }
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 4
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(row + 1)
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        Current.numberOfPromptCells = row
    }
}
