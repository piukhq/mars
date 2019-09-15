//
//  AddPaymentCardViewController.swift
//  binkapp
//
//  Created by Max Woodhams on 14/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class AddPaymentCardViewController: BaseFormViewController {
    
    private let model: PaymentCardCreateModel
    private let temp = TemporaryReactiveView()
    
    init(model: PaymentCardCreateModel) {
        self.model = model
        let dataSource = FormDataSource(model)
        super.init(
            title: "Add payment card",
            description: "Enter your details below to add your payment card into Bink.",
            dataSource: dataSource
        )
        
        dataSource.delegate = self

        stackScrollView.insert(arrangedSubview: temp, atIndex: 0, customSpacing: 30.0)
        stackScrollView.add(arrangedSubviews: [hyperlinkButton(title: "Privacy and security"), hyperlinkButton(title: "More information")])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func hyperlinkButton(title: String) -> UIButton {
        let button = UIButton(type: .custom)
        let attrString = NSAttributedString(
            string: title,
            attributes: [.underlineStyle : NSUnderlineStyle.single.rawValue, .font: UIFont.linkUnderlined, .foregroundColor: UIColor.blueAccent]
        )
        button.setAttributedTitle(attrString, for: .normal)
        button.contentHorizontalAlignment = .left
        return button
    }
}

extension AddPaymentCardViewController: FormDataSourceDelegate {
    func formDataSource(_ dataSource: FormDataSource, textField: UITextField, shouldChangeTo newValue: String?, in range: NSRange, for field: FormField) -> Bool {
        if let type = self.model.cardType, let newValue = newValue, let text = textField.text, field.fieldType == .cardNumber  {
            if newValue.count > 0 {
                let values = type.lengthRange()
                let cardLength = values.length + values.whitespaceIndexes.count
                
                if let textFieldText = textField.text, values.whitespaceIndexes.contains(range.location) && newValue.count > 0 {
                    textField.text = textFieldText + " "
                }
                
                if text.count >= cardLength && range.length == 0 {
                    return false
                } else {
                    let filtered = newValue.components(separatedBy: CharacterSet.decimalDigits.inverted).joined(separator: "")
                    return newValue == filtered
                }
            } else {
                
                // If newValue length is 0 then we can assume this is a delete, and if the next character after
                // this one is a whitespace string then let's remove it.
                
                let secondToLastCharacterLocation = range.location - 1
                if secondToLastCharacterLocation > 0, text.count > secondToLastCharacterLocation {
                    let stringRange = text.index(text.startIndex, offsetBy: secondToLastCharacterLocation)
                    let secondToLastCharacter = text[stringRange]
                    
                    if secondToLastCharacter == " " {
                        var mutableText = text
                        mutableText.remove(at: stringRange)
                        textField.text = mutableText
                    }
                }
                
                return true
            }
        }
    
        return true
    }
    
    func formDataSource(_ dataSource: FormDataSource, changed value: String?, for field: FormField) {
        if field.fieldType == .cardNumber {
            let type = PaymentCardType.type(from: value)
            self.model.cardType = type
            temp.update(with: type)
        }
    }
}

//TODO: Replace me with the actual CELL for payment cards when the wallet is built
class TemporaryReactiveView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.cornerRadius = 8.0
        clipsToBounds = true
        heightAnchor.constraint(equalToConstant: 120).isActive = true
    }
    
    var gradientLayer: CAGradientLayer?
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(with paymentType: PaymentCardType?) {
        switch paymentType {
        case .visa?:
            processGradient(UIColor.init(hexString: "181c51"), UIColor.init(hexString: "13288d"))
        case .masterCard?:
            processGradient(UIColor.init(hexString: "eb001b"), UIColor.init(hexString: "f79e1b"))
        case .amex?:
            processGradient(UIColor.init(hexString: "006bcd"), UIColor.init(hexString: "57c4ff"))
        case .none:
            processGradient(UIColor.darkGray, UIColor.lightGray)
        }
    }
    
    private func processGradient(_ firstColor: UIColor, _ secondColor: UIColor) {
        if gradientLayer == nil {
            let gradient = CAGradientLayer()
            layer.insertSublayer(gradient, at: 0)
            gradientLayer = gradient
        }
        
        gradientLayer?.frame = bounds
        gradientLayer?.colors = [firstColor.cgColor, secondColor.cgColor]
        gradientLayer?.locations = [0.0, 1.0]
        gradientLayer?.startPoint = CGPoint(x: 1.0, y: 0.0)
        gradientLayer?.endPoint = CGPoint(x: 0.0, y: 0.0)
    }
}
