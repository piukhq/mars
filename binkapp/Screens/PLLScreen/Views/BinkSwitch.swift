//
//  BinkSwitch.swift
//  binkapp
//
//  Created by Dorin Pop on 04/10/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class BinkSwitch: UISwitch {
    override func layoutSubviews() {
        super.layoutSubviews()
        onTintColor = .binkBlue
    }
}
