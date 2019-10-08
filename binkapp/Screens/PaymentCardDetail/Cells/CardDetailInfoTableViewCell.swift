//
//  CardDetailInfoTableViewCell.swift
//  binkapp
//
//  Created by Nick Farrant on 07/10/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class CardDetailInfoTableViewCell: UITableViewCell {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!

    func configureWithInformationRow(_ informationRow: CardDetailInformationRow) {
        titleLabel.text = informationRow.type.title
        subtitleLabel.text = informationRow.type.subtitle
    }
    
}
