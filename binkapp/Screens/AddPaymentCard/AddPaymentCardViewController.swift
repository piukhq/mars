//
//  AddPaymentCardViewController.swift
//  binkapp
//
//  Created by Max Woodhams on 14/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit
import Keys

class AddPaymentCardViewController: BaseFormViewController {
    private let viewModel: AddPaymentCardViewModel
    private let temp = TemporaryReactiveView()
    
    private struct Constants {
        static let buttonWidthPercentage: CGFloat = 0.75
        static let buttonHeight: CGFloat = 52.0
        static let postCollectionViewPadding: CGFloat = 15.0
        static let cardPadding: CGFloat = 30.0
        static let bottomButtonPadding: CGFloat = 78.0
    }
    
    private lazy var addButton: BinkGradientButton = {
        let button = BinkGradientButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Add", for: .normal)
        button.titleLabel?.font = UIFont.buttonText
        button.addTarget(self, action: .addButtonTapped, for: .touchUpInside)
        button.isEnabled = false
        view.addSubview(button)
        return button
    }()
    
    // MARK: - Initialisation
    
    init(viewModel: AddPaymentCardViewModel) {
        self.viewModel = viewModel
        super.init(title: "Add payment card", description: "Enter your details below to add your payment card into Bink.", dataSource: viewModel.formDataSource)
        dataSource.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureLayout()
        stackScrollView.insert(arrangedSubview: temp, atIndex: 0, customSpacing: Constants.cardPadding)
        stackScrollView.add(arrangedSubviews: [hyperlinkButton(title: "Privacy and security"), hyperlinkButton(title: "More information")])
        stackScrollView.customPadding(Constants.postCollectionViewPadding, after: collectionView)
    }
    
    // MARK: - Layout
    
    func configureLayout() {
        NSLayoutConstraint.activate([
            addButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: Constants.buttonWidthPercentage),
            addButton.heightAnchor.constraint(equalToConstant: Constants.buttonHeight),
            addButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -Constants.bottomButtonPadding),
            addButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            ])
    }
    
    // MARK: - Builder
    
    private func hyperlinkButton(title: String) -> UIButton {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        let attrString = NSAttributedString(
            string: title,
            attributes: [.underlineStyle : NSUnderlineStyle.single.rawValue, .font: UIFont.linkUnderlined, .foregroundColor: UIColor.blueAccent]
        )
        button.setAttributedTitle(attrString, for: .normal)
        button.contentHorizontalAlignment = .left
        button.heightAnchor.constraint(equalToConstant: 54.0).isActive = true
        return button
    }
    
    // MARK: - Actions
    
    @objc func addButtonTapped() {
        viewModel.toPaymentTermsAndConditions(delegate: self)
    }
    
    override func formValidityUpdated(fullFormIsValid: Bool) {
        addButton.isEnabled = fullFormIsValid
    }
}

extension AddPaymentCardViewController: PaymentTermsAndConditionsViewControllerDelegate {
    func paymentTermsAndConditionsViewControllerDidAccept(_ viewController: PaymentTermsAndConditionsViewController) {
        viewModel.addPaymentCard { [weak self] success in
            if success {
                NotificationCenter.default.post(name: .didAddPaymentCard, object: nil)
                self?.viewModel.popToRootViewController()
            } else {
                self?.viewModel.displayError()
            }
        }
    }
}

extension AddPaymentCardViewController: URLSessionDelegate {
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(.useCredential, nil)
    }
}

extension AddPaymentCardViewController: FormDataSourceDelegate {
    func formDataSource(_ dataSource: FormDataSource, textField: UITextField, shouldChangeTo newValue: String?, in range: NSRange, for field: FormField) -> Bool {
        if let type = viewModel.paymentCardType,
            let newValue = newValue,
            let text = textField.text,
            field.fieldType == .cardNumber  {
            
            /*
             Potentially "needlessly" complex, but the below will insert whitespace to format card numbers correctly according
             to the pattern available in PaymentCardType.
             EXAMPLE: 4242424242424242 becomes 4242 4242 4242 4242
            */
            
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
            viewModel.setPaymentCardType(type)
            viewModel.setPaymentCardFullPan(value)
            temp.update(with: type)
        }
        
        if field.fieldType == .text {
            viewModel.setPaymentCardName(value)
        }
    }
    
    func formDataSource(_ dataSource: FormDataSource, selected options: [Any], for field: FormField) {
        // For mapping to the payment card expiry fields, we only care if we have BOTH
        guard options.count > 1 else { return }

        let month = options.first as? Int
        let year = options.last as? Int

        viewModel.setPaymentCardExpiry(month: month, year: year)
    }
}

private extension Selector {
    static let addButtonTapped = #selector(AddPaymentCardViewController.addButtonTapped)
}

//TODO: Replace me with the actual CELL for payment cards when the wallet is built
class TemporaryReactiveView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 8.0
        clipsToBounds = true
        heightAnchor.constraint(equalToConstant: 120).isActive = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        update(with: .none)
    }
    
    var gradientLayer: CAGradientLayer?
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(with paymentType: PaymentCardType?) {
        switch paymentType {
        case .visa?:
            processGradient(UIColor(hexString: "181c51"), UIColor(hexString: "13288d"))
        case .mastercard?:
            processGradient(UIColor(hexString: "eb001b"), UIColor(hexString: "f79e1b"))
        case .amex?:
            processGradient(UIColor(hexString: "006bcd"), UIColor(hexString: "57c4ff"))
        case .none:
            processGradient(UIColor(hexString: "b46fea"), UIColor(hexString: "4371fe"))
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
