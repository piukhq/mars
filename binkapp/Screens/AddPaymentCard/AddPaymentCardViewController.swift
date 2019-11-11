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
    private lazy var card: PaymentCardCollectionViewCell = {
        let cell: PaymentCardCollectionViewCell = .fromNib()
        return cell
    }()
    
    private struct Constants {
        static let cardPadding: CGFloat = 30.0
        static let cardHeight: CGFloat = 120.0
        static let hyperlinkHeight: CGFloat = 54.0
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
    
    private var hasSetupCell = false
    
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

        stackScrollView.insert(arrangedSubview: card, atIndex: 0, customSpacing: Constants.cardPadding)
        stackScrollView.add(arrangedSubviews: [hyperlinkButton(title: "security_and_privacy_title".localized)])
        configureLayout()
    }
    
    // MARK: - Layout
    
    func configureLayout() {
        
        var constraints = [
            addButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: LayoutHelper.PillButton.widthPercentage),
            addButton.heightAnchor.constraint(equalToConstant: LayoutHelper.PillButton.height),
            addButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -LayoutHelper.PillButton.bottomPadding),
            addButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ]
        
        constraints.append(contentsOf: [
            card.heightAnchor.constraint(equalToConstant: Constants.cardHeight),
                card.widthAnchor.constraint(equalTo: collectionView.widthAnchor)
        ])

        NSLayoutConstraint.activate(constraints)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // This is due to strange layout issues on first appearance
        if !hasSetupCell {
            hasSetupCell = true
            card.frame = CGRect(
                origin: .zero,
                size: CGSize(width: collectionView.contentSize.width, height: Constants.cardHeight)
            )
            card.configureWithAddViewModel(viewModel.paymentCard)
        }
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
        button.heightAnchor.constraint(equalToConstant: Constants.hyperlinkHeight).isActive = true
        button.addTarget(self, action: .privacyButtonTapped, for: .touchUpInside)
        return button
    }
    
    // MARK: - Actions
    
    @objc func addButtonTapped() {
        viewModel.toPaymentTermsAndConditions(delegate: self)
    }
    
    @objc func privacyButtonTapped() {
        viewModel.toPrivacyAndSecurity()
    }
    
    override func formValidityUpdated(fullFormIsValid: Bool) {
        addButton.isEnabled = fullFormIsValid
    }
}

extension AddPaymentCardViewController: PaymentTermsAndConditionsViewControllerDelegate {
    func paymentTermsAndConditionsViewControllerDidAccept(_ viewController: PaymentTermsAndConditionsViewController) {
        addButton.startLoading()
        viewModel.addPaymentCard { [weak self] success in
            if success {
                Current.wallet.refreshLocal()
                // We post the notification so that we can switch tabs if necessary
                NotificationCenter.default.post(name: .didAddPaymentCard, object: nil)
                self?.viewModel.popToRootViewController()
            } else {
                self?.addButton.stopLoading()
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
            field.fieldType == .cardNumber {
            
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
        }

        if field.fieldType == .text { viewModel.setPaymentCardName(value) }
        card.configureWithAddViewModel(viewModel.paymentCard)
    }
    
    func formDataSource(_ dataSource: FormDataSource, selected options: [Any], for field: FormField) {
        // For mapping to the payment card expiry fields, we only care if we have BOTH
        guard options.count > 1 else { return }

        let month = options.first as? Int
        let year = options.last as? Int

        viewModel.setPaymentCardExpiry(month: month, year: year)
    }

    func formDataSource(_ dataSource: FormDataSource, manualValidate field: FormField) -> Bool {
        return false
    }
}

private extension Selector {
    static let addButtonTapped = #selector(AddPaymentCardViewController.addButtonTapped)
    static let privacyButtonTapped = #selector(AddPaymentCardViewController.privacyButtonTapped)
}
