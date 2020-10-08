//
//  binkPersonTableViewCell.swift
//  binkapp
//
//  Created by Sean Williams on 07/10/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import UIKit

class BinkPersonTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    func configure(with teamMember: String) {
        titleLabel.text = teamMember
        titleLabel.font = UIFont.bodyTextLarge
    }    
}
