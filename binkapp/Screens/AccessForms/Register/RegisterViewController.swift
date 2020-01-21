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
    
    //TODO: remove this if we don't need to display the old screen at all
//    private lazy var message: UILabel = {
//        let label = UILabel(frame: .zero)
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.numberOfLines = 0
//        label.attributedText = messageString
//        return label
//    }()
//
//    private lazy var messageString: NSAttributedString = {
//        let attrString = NSMutableAttributedString(string: "preferences_prompt".localized, attributes: [.font : UIFont.bodyTextLarge])
//        let base: NSString = NSString(string: attrString.string)
//        let rewardsRange = base.range(of: "preferences_prompt_highlight_rewards".localized)
//        let offersRange = base.range(of: "preferences_prompt_highlight_offers".localized)
//        let updatesRange = base.range(of: "preferences_prompt_highlight_updates".localized)
//
//        let attributes: [NSAttributedString.Key : Any]  = [.font : UIFont.subtitle]
//
//        attrString.addAttributes(attributes, range: rewardsRange)
//        attrString.addAttributes(attributes, range: offersRange)
//        attrString.addAttributes(attributes, range: updatesRange)
//
//        return attrString
//    }()
    
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
        //TODO: remove this if we don't need to display the old screen at all
//        let lastView = stackScrollView.arrangedSubviews.last
//        stackScrollView.add(arrangedSubview: message)
//
//        if let lastView = lastView {
//            stackScrollView.customPadding(18.0, after: lastView)
//        }
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
        
        Current.apiManager.doRequest(url: .register, httpMethod: .post, parameters: loginRequest, onSuccess: { [weak self] (response: LoginRegisterResponse) in
            Current.userManager.setNewUser(with: response)
            self?.router.didLogin()
            self?.updatePreferences(checkboxes: preferenceCheckboxes)
            self?.continueButton.stopLoading()
        }) { [weak self] (error) in
            self?.showError()
            self?.continueButton.stopLoading()
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
        Current.apiManager.doRequestWithNoResponse(url: .preferences, httpMethod: .put, parameters: params, completion: nil)
    }
    
    func showError() {
        let alert = UIAlertController(title: "error_title".localized, message: "register_failed".localized, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ok".localized, style: .default))
        present(alert, animated: true)
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
