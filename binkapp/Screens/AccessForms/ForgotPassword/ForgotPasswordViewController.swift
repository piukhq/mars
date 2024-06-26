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

    private lazy var continueButton: BinkButton = {
        return BinkButton(type: .capsule, title: L10n.continueButtonTitle, enabled: false) { [weak self] in
            self?.continueButtonTapped()
        }
    }()
    
    init(viewModel: ForgotPasswordViewModel) {
        self.viewModel = viewModel
        super.init(title: L10n.loginForgotPassword, description: L10n.forgotPasswordDescription, dataSource: FormDataSource(accessForm: .forgottenPassword))
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
        footerButtons = [continueButton]
    }
    
    override func formValidityUpdated(fullFormIsValid: Bool) {
        continueButton.enabled = fullFormIsValid
    }
    
    func continueButtonTapped() {
        continueButton.toggleLoading(isLoading: true)
        viewModel.continueButtonTapped(completion: {
            self.continueButton.toggleLoading(isLoading: false)
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
    func formCollectionViewCell(_ cell: FormCollectionViewCell, shouldResignTextField textField: UITextField) {}
}
