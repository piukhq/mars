//
//  TransactionView.swift
//  binkapp
//
//  Created by Paul Tiriteu on 27/02/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import UIKit

class TransactionView: CustomView {
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var separatorView: UIView!
    
    override func configureUI() {
        valueLabel.font = .subtitle
        valueLabel.textColor = Current.themeManager.color(for: .text)
        descriptionLabel.font = .bodyTextSmall
        descriptionLabel.textColor = Current.themeManager.color(for: .text)
    }
    
    func configure(with transaction: CD_MembershipTransaction) {
        let transactionValue = transaction.formattedAmounts?.first?.value?.intValue ?? 0
        let timestamp = transaction.timestamp?.doubleValue ?? 0.0
        let timestampDate = Date(timeIntervalSince1970: timestamp)
        if let transactionDescription = transaction.transactionDescription {
            descriptionLabel.text = timestampDate.getFormattedString(format: .dayMonthYear) + ", " + transactionDescription
        } else {
            descriptionLabel.text = timestampDate.getFormattedString(format: .dayMonthYear)
        }
      
        guard let prefix = transaction.formattedAmounts?.first?.prefix else {
            guard let firstSuffix = transaction.formattedAmounts?.first?.suffix else { return }
            let suffix = !firstSuffix.isEmpty ? transaction.formattedAmounts?.first?.currency : nil
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
            imageView.image = Asset.down.image
        } else if transactionValue > 0 {
            valueLabel.text = "+" + String(format: text, addDecimals ? Float(transactionValue) : transactionValue)
            valueLabel.textColor = .greenOk
            imageView.image = Asset.up.image
        } else {
            valueLabel.text = String(format: text, addDecimals ? Float(transactionValue) : transactionValue)
            valueLabel.textColor = .amberPending
            imageView.image = Asset.neutralArrow.image
        }
    }
    
    func hideSeparatorView() {
        separatorView.isHidden = true
    }
}
