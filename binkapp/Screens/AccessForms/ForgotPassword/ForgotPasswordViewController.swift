//
//  ForgotPasswordViewController.swift
//  binkapp
//
//  Created by Paul Tiriteu on 29/11/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class ForgotPasswordViewController: BaseFormViewController {
    private let viewModel: ForgotPasswordViewModel
    
    private lazy var continueButton: BinkPillButton = {
        let button = BinkGradientButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("continue_button_title".localized, for: .normal)
        button.titleLabel?.font = UIFont.buttonText
        button.addTarget(self, action: .continueButtonTapped, for: .touchUpInside)
        button.isEnabled = false
        view.addSubview(button)
        return button
    }()
    
    init(viewModel: ForgotPasswordViewModel) {
        self.viewModel = viewModel
        super.init(title: "login_forgot_password".localized, description: "forgot_password_description".localized, dataSource: FormDataSource(accessForm: .forgottenPassword))
        dataSource.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureLayout()
        viewModel.navigationController = navigationController
    }
    
    func configureLayout() {
        NSLayoutConstraint.activate([
            continueButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: LayoutHelper.PillButton.widthPercentage),
            continueButton.heightAnchor.constraint(equalToConstant: LayoutHelper.PillButton.height),
            continueButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -LayoutHelper.PillButton.bottomPadding),
            continueButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    override func formValidityUpdated(fullFormIsValid: Bool) {
        continueButton.isEnabled = fullFormIsValid
    }
    
    @objc func continueButtonTapped() {
        continueButton.startLoading()
        viewModel.continueButtonTapped(completion: {
            self.continueButton.stopLoading()
        })
    }
}

extension ForgotPasswordViewController: FormDataSourceDelegate {
    func formDataSource(_ dataSource: FormDataSource, textField: UITextField, shouldChangeTo newValue: String?, in range: NSRange, for field: FormField) -> Bool {
        return true
    }
    
    func formDataSource(_ dataSource: FormDataSource, changed value: String?, for field: FormField) {
        viewModel.email = value ?? ""
    }
}

extension ForgotPasswordViewController: FormCollectionViewCellDelegate {
    func formCollectionViewCell(_ cell: FormCollectionViewCell, didSelectField: UITextField) {}
}

private extension Selector {
    static let continueButtonTapped = #selector(ForgotPasswordViewController.continueButtonTapped)
}
