//
//  RegisterViewController.swift
//  binkapp
//
//  Created by Max Woodhams on 03/11/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class RegisterViewController: BaseFormViewController {
    private let api = ApiManager()

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
        super.init(title: "Sign up with email", description: "All it takes is an email and password.", dataSource: FormDataSource(accessForm: .register))
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
                
        api.doRequest(url: .register, httpMethod: .post, parameters: loginRequest, onSuccess: { [weak self] (response: LoginRegisterResponse) in
            Current.userManager.setNewUser(with: response)
            self?.router.didLogin()
            self?.updatePreferences(checkboxes: preferenceCheckboxes)
            // Silently process the preferences
        }) { (error) in
            print(error)
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
//        api.doRequestWithNoResponse(url: .preferences, httpMethod: .put, parameters: params, completion: nil)
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

private extension Selector {
    static let continueButtonTapped = #selector(RegisterViewController.continueButtonTapped)
}
