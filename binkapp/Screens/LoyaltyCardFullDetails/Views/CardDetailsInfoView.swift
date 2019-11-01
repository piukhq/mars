//
//  CardDetailsInfoView.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

protocol CardDetailsInfoViewDelegate: NSObject {
    func cardDetailsInfoViewDidTapMoreInfo(_ cardDetailsInfoView: CardDetailsInfoView)
}

class CardDetailsInfoView: CustomView {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var infoLabel: UILabel!
    
    weak var delegate: CardDetailsInfoViewDelegate?
    
    func configure(title: String, andInfo info: String){
        titleLabel.text = title
        infoLabel.text = info
    }
    
    // MARK: - Actions
    
    @IBAction func moreInfoTapped(_ sender: Any) {
        delegate?.cardDetailsInfoViewDidTapMoreInfo(self)
    }
}
