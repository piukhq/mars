//
//  DetailNavigationTitleView.swift
//  binkapp
//
//  Created by Nick Farrant on 09/10/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class DetailNavigationTitleView: UIView {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var detailLabel: UILabel!

    func configureWithTitle(_ title: String, detail: String) {
        titleLabel.text = title
        detailLabel.text = detail
    }

}
