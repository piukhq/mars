//
//  AuthAndAddViewController.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit
import NotificationCenter

class AuthAndAddViewController: BaseFormViewController {    
    private struct Constants {
        static let buttonWidthPercentage: CGFloat = 0.75
        static let buttonHeight: CGFloat = 52.0
        static let postCollectionViewPadding: CGFloat = 15.0
        static let cardPadding: CGFloat = 30.0
        static let bottomButtonPadding: CGFloat = 78.0
    }
    
    private lazy var brandHeaderView: BrandHeaderView = {
        let brandHeader = BrandHeaderView()
        brandHeader.heightAnchor.constraint(equalToConstant: 110).isActive = true
        return brandHeader
    }()

    private lazy var loginButton: BinkGradientButton = {
        let button = BinkGradientButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Login", for: .normal)
        button.titleLabel?.font = UIFont.buttonText
        button.addTarget(self, action: .loginButtonTapped, for: .touchUpInside)
        button.isEnabled = false
        view.addSubview(button)
        return button
    }()
    
    private let viewModel: AuthAndAddViewModel
    private var isKeyboardOpen = false
    
    var fieldsViews: [InputValidation] = []
    
    init(viewModel: AuthAndAddViewModel) {
        self.viewModel = viewModel
        let datasource = FormDataSource(authAdd: viewModel.getMembershipPlan(), formPurpose: viewModel.formPurpose)
        super.init(title: "Log in", description: "", dataSource: datasource)
        dataSource.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar()
        configureUI()
        configureLayout()
        stackScrollView.insert(arrangedSubview: brandHeaderView, atIndex: 0, customSpacing: Constants.cardPadding)
    }
    
    func setNavigationBar() {
        let closeButton = UIBarButtonItem(title: "cancel".localized, style: .plain, target: self, action: #selector(popToRootScreen))
        closeButton.tintColor = .black
        self.navigationItem.setRightBarButton(closeButton, animated: true)
        
        let backButton = UIBarButtonItem(image: UIImage(named: "navbarIconsBack"), style: .plain, target: self, action: #selector(popViewController))
        self.navigationItem.leftBarButtonItem = backButton
        
        navigationItem.setHidesBackButton(false, animated: true)
    }
    
    // MARK: - Layout
    
    func configureLayout() {
        NSLayoutConstraint.activate([
            loginButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: Constants.buttonWidthPercentage),
            loginButton.heightAnchor.constraint(equalToConstant: Constants.buttonHeight),
            loginButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -Constants.bottomButtonPadding),
            loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            ])
    }
    
    func configureUI() {
        let membershipPlan = viewModel.getMembershipPlan()
        
        brandHeaderView.configure(imageURLString: ((membershipPlan.firstIconImage()?.url) ?? nil), loyaltyPlanNameCard: (membershipPlan.account?.planNameCard ?? nil), delegate: self)
        
        titleLabel.text = viewModel.title
        titleLabel.font = UIFont.headline
        
        descriptionLabel.text = viewModel.getDescription()
        descriptionLabel.font = UIFont.bodyTextLarge
        descriptionLabel.isHidden = viewModel.getDescription() == nil
        
        loginButton.setTitle(viewModel.buttonTitle, for: .normal)
        
        if let planName = membershipPlan.account?.planName {
            descriptionLabel.text = String(format: "auth_screen_description".localized, planName)
            descriptionLabel.font = UIFont.bodyTextLarge
            descriptionLabel.isHidden = false
        }
        populateStackViewWithFields()
    }
    
    func populateStackViewWithFields() {
//        var checkboxes = [CheckboxView]()
//        let addFields = viewModel.getAddFields()
//        let authorizeFields = viewModel.getAuthorizeFields()
//        let enrolFields = viewModel.getEnrolFields()
//
//        for field in addFields {
//            switch field.type {
//            case FieldInputType.textfield.rawValue:
//                let view = LoginTextFieldView()
//                view.configure(title: field.column ?? "", placeholder: field.description, validationRegEx: field.validation ?? "", fieldType: .add, delegate: self)
//                fieldsViews.append(view)
//            case FieldInputType.password.rawValue:
//                let view = LoginTextFieldView()
//                view.configure(title: field.column ?? "", placeholder: field.description, validationRegEx: field.validation ?? "", isPassword: true, fieldType: .add, delegate: self)
//                fieldsViews.append(view)
//            case FieldInputType.dropdown.rawValue:
//                let view = DropdownView()
//                view.configure(title: field.column ?? "", choices: field.choice ?? [], fieldType: .add, delegate: self)
//                fieldsViews.append(view)
//            case FieldInputType.checkbox.rawValue:
//                let view = CheckboxView()
//                view.configure(title: field.description ?? "", columnName: field.column ?? "", fieldType: .add, delegate: self)
//                checkboxes.append(view)
//            default: break
//            }
//        }
//
//        for field in authorizeFields {
//            switch field.type {
//            case FieldInputType.textfield.rawValue:
//                let view = LoginTextFieldView()
//                view.configure(title: field.column ?? "", placeholder: field.description, validationRegEx: field.validation ?? "", fieldType: .authorise, delegate: self)
//                fieldsViews.append(view)
//            case FieldInputType.password.rawValue:
//                let view = LoginTextFieldView()
//                view.configure(title: field.column ?? "", placeholder: field.description, validationRegEx: field.validation ?? "", isPassword: true, fieldType: .authorise, delegate: self)
//                fieldsViews.append(view)
//            case FieldInputType.dropdown.rawValue:
//                let view = DropdownView()
//                view.configure(title: field.column ?? "", choices: field.choice ?? [], fieldType: .authorise, delegate: self)
//                fieldsViews.append(view)
//            case FieldInputType.checkbox.rawValue:
//                let view = CheckboxView()
//                view.configure(title: field.description ?? "", columnName: field.column ?? "", fieldType: .authorise, delegate: self)
//                checkboxes.append(view)
//            default: break
//            }
//        }
//
//        for field in enrolFields {
//            switch field.type {
//            case FieldInputType.textfield.rawValue:
//                let view = LoginTextFieldView()
//                view.configure(title: field.column ?? "", placeholder: field.description, validationRegEx: field.validation ?? "", fieldType: .enrol, delegate: self)
//                fieldsViews.append(view)
//            case FieldInputType.password.rawValue:
//                let view = LoginTextFieldView()
//                view.configure(title: field.column ?? "", placeholder: field.description, validationRegEx: field.validation ?? "", isPassword: true, fieldType: .enrol, delegate: self)
//                fieldsViews.append(view)
//            case FieldInputType.dropdown.rawValue:
//                let view = DropdownView()
//                view.configure(title: field.column ?? "", choices: field.choice ?? [], fieldType: .enrol, delegate: self)
//                fieldsViews.append(view)
//            case FieldInputType.checkbox.rawValue:
//                let view = CheckboxView()
//                view.configure(title: field.description ?? "", columnName: field.column ?? "", fieldType: .enrol, delegate: self)
//                checkboxes.append(view)
//            default: break
//            }
//        }
//
//        for box in checkboxes {
//            fieldsViews.append(box)
//        }
//
//        viewModel.setFields(fields: fieldsViews)
//
//        if fieldsViews.isEmpty == false {
//            for view in fieldsViews {
//                if view is UIView {
//                    fieldsStackView.addArrangedSubview(view as! UIView)
//                }
//            }
//        }
    }
    
    @objc func popViewController() {
        viewModel.popViewController()
    }
    
    @objc func popToRootScreen() {
        viewModel.popToRootViewController()
    }
        
    @objc func loginButtonTapped() {
        viewModel.addMembershipCard(with: dataSource.fields, checkboxes: dataSource.checkboxes)
    }
    
    override func formValidityUpdated(fullFormIsValid: Bool) {
        loginButton.isEnabled = fullFormIsValid
    }
}

extension AuthAndAddViewController: FormDataSourceDelegate {
    func formDataSource(_ dataSource: FormDataSource, textField: UITextField, shouldChangeTo newValue: String?, in range: NSRange, for field: FormField) -> Bool {
        return true
    }
}

extension AuthAndAddViewController: LoyaltyButtonDelegate {
    func brandHeaderViewWasTapped(_ brandHeaderView: BrandHeaderView) {
        viewModel.displaySimplePopup(title: (viewModel.getMembershipPlan().account?.planNameCard) ?? nil, message: (viewModel.getMembershipPlan().account?.planDescription) ?? nil)
    }
}

private extension Selector {
    static let loginButtonTapped = #selector(AuthAndAddViewController.loginButtonTapped)
}

//extension AuthAndAddViewController: CheckboxViewDelegate {
//    func checkboxView(_ checkboxView: CheckboxView, didCompleteWithColumn column: String, value: String, fieldType: FieldType) {
//        viewModel.addFieldToCard(column: column, value: value, fieldType: fieldType)
//    }
//}
