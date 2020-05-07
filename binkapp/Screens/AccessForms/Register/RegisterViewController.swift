//
//  RegisterViewController.swift
//  binkapp
//
//  Created by Max Woodhams on 03/11/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class RegisterViewController: BaseFormViewController {

    private lazy var continueButton: BinkGradientButton = {
        let button = BinkGradientButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Continue", for: .normal)
        button.titleLabel?.font = UIFont.buttonText
        button.addTarget(self, action: .continueButtonTapped, for: .touchUpInside)
        button.isEnabled = false
        view.addSubview(button)
        return button
    }()
    
    private let router: MainScreenRouter
        
    init(router: MainScreenRouter) {
        self.router = router
        super.init(title: "register_title".localized, description: "register_subtitle".localized, dataSource: FormDataSource(accessForm: .register))
        dataSource.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        NSLayoutConstraint.activate([
            continueButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: LayoutHelper.PillButton.widthPercentage),
            continueButton.heightAnchor.constraint(equalToConstant: LayoutHelper.PillButton.height),
            continueButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -LayoutHelper.PillButton.bottomPadding),
            continueButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setScreenName(trackedScreen: .register)
    }
    
    override func formValidityUpdated(fullFormIsValid: Bool) {
        continueButton.isEnabled = fullFormIsValid
    }
    
    @objc func continueButtonTapped() {
        
        let fields = dataSource.currentFieldValues()
                
        let loginRequest = LoginRegisterRequest(
            email: fields["email"],
            password: fields["password"]
        )
        
        let preferenceCheckboxes = dataSource.checkboxes.filter { $0.columnKind == .userPreference }
                
        continueButton.startLoading()
        
        Current.apiManager.doRequest(url: .register, httpMethod: .post, parameters: loginRequest, isUserDriven: true, onSuccess: { [weak self] (response: LoginRegisterResponse) in
            guard let email = response.email else {
                self?.handleRegistrationError()
                return
            }
            Current.userManager.setNewUser(with: response)
            Current.apiManager.doRequestWithNoResponse(url: .service, httpMethod: .post, parameters: APIConstants.makeServicePostRequest(email: email), isUserDriven: false) { [weak self] (success, error) in
                // If there is an error, or the response is not successful, bail out
                guard error == nil, success else {
                    self?.handleRegistrationError()
                    return
                }
                self?.router.didLogin()
                self?.updatePreferences(checkboxes: preferenceCheckboxes)
                self?.continueButton.stopLoading()
            }
        }) { [weak self] _ in
            self?.handleRegistrationError()
        }
    }
    
    func updatePreferences(checkboxes: [CheckboxView]) {
        
        var params = [String: Any]()
        
        checkboxes.forEach {
            if let columnName = $0.columnName {
                params[columnName] = $0.value
            }
        }
        
        guard params.count > 0 else { return }
        
        // We don't worry about whether this was successful or not
        Current.apiManager.doRequestWithNoResponse(url: .preferences, httpMethod: .put, parameters: params, isUserDriven: true, completion: nil)
    }
    
    private func showError() {
        let alert = UIAlertController(title: "error_title".localized, message: "register_failed".localized, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ok".localized, style: .default))
        present(alert, animated: true)
    }

    private func handleRegistrationError() {
        Current.userManager.removeUser()
        continueButton.stopLoading()
        showError()
    }
    
    override func checkboxView(_ checkboxView: CheckboxView, didTapOn URL: URL) {
        router.openWebView(withUrlString: URL.absoluteString)
    }
}

extension RegisterViewController: FormDataSourceDelegate {
    func formDataSource(_ dataSource: FormDataSource, textField: UITextField, shouldChangeTo newValue: String?, in range: NSRange, for field: FormField) -> Bool {
        return true
    }
    
    func formDataSource(_ dataSource: FormDataSource, manualValidate field: FormField) -> Bool {
        // Make sure this field is the confirmPassword field
        guard field.fieldType == .confirmPassword, let passwordToCheckAgainst = dataSource.currentFieldValues()["password"] else {
            return false
        }
        
        return field.value == passwordToCheckAgainst
    }
}

extension RegisterViewController: FormCollectionViewCellDelegate {
    func formCollectionViewCell(_ cell: FormCollectionViewCell, didSelectField: UITextField) {}
    func formCollectionViewCell(_ cell: FormCollectionViewCell, shouldResignTextField textField: UITextField) {}
}

private extension Selector {
    static let continueButtonTapped = #selector(RegisterViewController.continueButtonTapped)
}
