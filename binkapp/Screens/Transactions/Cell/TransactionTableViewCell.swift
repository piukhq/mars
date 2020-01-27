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
    
    func configure(transaction: CD_MembershipTransaction) {
        let transactionValue = transaction.formattedAmounts?.first?.value?.intValue ?? 0
        let timestamp = transaction.timestamp?.doubleValue ?? 0.0
        let timestampDate = Date(timeIntervalSince1970: timestamp)
        if let transactionDescription = transaction.transactionDescription {
            descriptionLabel.text = timestampDate.getFormattedString(format: DateFormat.dayMonthYear.rawValue) + ", " + transactionDescription
        } else {
            descriptionLabel.text = timestampDate.getFormattedString(format: DateFormat.dayMonthYear.rawValue)
        }
        
        guard let prefix = transaction.formattedAmounts?.first?.prefix else {
            let suffix = transaction.formattedAmounts?.first?.suffix != "" ? transaction.formattedAmounts?.first?.currency : nil
            setValueLabel(text: "%d \(suffix ?? "")", transactionValue: transactionValue, addDecimals: false)
            return
        }
        setValueLabel(text: "\(prefix)%.02f", transactionValue: transactionValue, addDecimals: true)
    }
    
    func setValueLabel(text: String, transactionValue: Int, addDecimals: Bool) {
        if transactionValue < 0 {
            let value = abs(transactionValue)
            valueLabel.text = "-" + String(format: text, addDecimals ? Float(value) : value)
            valueLabel.textColor = .black
            transactionImageView.image = UIImage(named: "down")
        } else if transactionValue > 0 {
            valueLabel.text = "+" + String(format: text, addDecimals ? Float(transactionValue) : transactionValue)
            valueLabel.textColor = .greenOk
            transactionImageView.image = UIImage(named: "up")
        } else {
            valueLabel.text = String(format: text, addDecimals ? Float(transactionValue) : transactionValue)
            valueLabel.textColor = .amberPending
        }
    }
    
    func configureUI() {
        selectionStyle = .none
        valueLabel.font = .subtitle
        descriptionLabel.font = .bodyTextSmall
    }
}
