//
//  TransactionTableViewCell.swift
//  binkapp
//
//  Created by Paul Tiriteu on 13/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class TransactionTableViewCell: UITableViewCell {
    @IBOutlet private weak var valueLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var transactionImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureUI()
    }
    
    func configure(transactionValue: Int, timestamp: Double, prefix: String?, suffix: String?) {
        if transactionValue < 0 {
            valueLabel.text = "-" + (prefix ?? "") + "\(abs(transactionValue))" + (suffix ?? "")
            valueLabel.textColor = .black
            transactionImageView.image = UIImage(named: "down")
        } else if transactionValue > 0 {
            valueLabel.text = "+" + (prefix ?? "") + "\(transactionValue)" + (suffix ?? "")
            valueLabel.textColor = .greenOk
            transactionImageView.image = UIImage(named: "up")
        } else {
            valueLabel.text = (prefix ?? "") + "\(transactionValue)" + (suffix ?? "")
            valueLabel.textColor = .amber
        }
        let timestampDate = Date(timeIntervalSince1970: timestamp)
        descriptionLabel.text = timestampDate.getFormattedString(format: DateFormat.dayMonthYear.rawValue)
    }
    
    func configureUI() {
        selectionStyle = .none
        valueLabel.font = .subtitle
        descriptionLabel.font = .bodyTextSmall
    }
}
