//
//  CardDetailInfoTableViewCell.swift
//  binkapp
//
//  Created by Nick Farrant on 07/10/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import SwiftUI
import UIKit

class CardDetailInfoTableViewCell: UITableViewCell {    
    override func prepareForReuse() {
        super.prepareForReuse()
        setSeparatorDefaultWidth()
    }
    
    

    func configureWithInformationRow(_ informationRow: CardDetailInformationRow) {
//        titleLabel.text = informationRow.type.title
//        titleLabel.textColor = Current.themeManager.color(for: .text)
//        subtitleLabel.text = informationRow.type.subtitle
//        subtitleLabel.textColor = Current.themeManager.color(for: .text)
//        rightDisclosureView.tintColor = Current.themeManager.color(for: .text)
//        backgroundColor = .clear
//        selectedBackgroundView = binkTableViewCellSelectedBackgroundView()
        accessibilityIdentifier = informationRow.type.title
        
//        let hostingController = UIHostingController(rootView: CardDetailInfoTableView(rowData: informationRow, showSeparator: false))
//        attach(to: hostingController.view)
    }
    
    func attach(to view: UIView) {
        addSubview(view)
        NSLayoutConstraint.activate([
            bottomAnchor.constraint(equalTo: view.bottomAnchor),
            topAnchor.constraint(equalTo: view.topAnchor),
            leftAnchor.constraint(equalTo: view.leftAnchor),
            rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
    }
}
