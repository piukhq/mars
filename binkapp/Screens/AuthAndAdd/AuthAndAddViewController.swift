//
//  AuthAndAddViewController.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit
import NotificationCenter

class AuthAndAddViewController: UIViewController {
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var brandHeaderView: BrandHeaderView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var fieldsStackView: UIStackView!
    @IBOutlet private weak var loginButton: BinkGradientButton!
    
    private let viewModel: AuthAndAddViewModel
    private var isKeyboardOpen = false
    private var fieldsViews: [InputValidation] = []
    
    init(viewModel: AuthAndAddViewModel) {
        self.viewModel = viewModel
        super.init(nibName: "AuthAndAddViewController", bundle: Bundle(for: AuthAndAddViewController.self))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar()
        configureUI()
    }
    
    func setNavigationBar() {
        let closeButton = UIBarButtonItem(title: "cancel".localized, style: .plain, target: self, action: #selector(popToRootScreen))
        closeButton.tintColor = .black
        self.navigationItem.setRightBarButton(closeButton, animated: true)
        
        let backButton = UIBarButtonItem(image: UIImage(named: "navbarIconsBack")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(popViewController))
        self.navigationItem.leftBarButtonItem = backButton
        
        navigationItem.setHidesBackButton(false, animated: true)
    }
    
    func configureUI() {
        let membershipPlan = viewModel.getMembershipPlan()
        
        brandHeaderView.configure(imageURLString: ((membershipPlan.images?.first(where: { $0.type == ImageType.icon.rawValue})?.url) ?? nil), loyaltyPlanNameCard: (membershipPlan.account?.planNameCard ?? nil), delegate: self)
        
        titleLabel.text = viewModel.title
        titleLabel.font = UIFont.headline
        
        descriptionLabel.text = viewModel.getDescription()
        descriptionLabel.font = UIFont.bodyTextLarge
        descriptionLabel.isHidden = viewModel.getDescription() == nil
        
        loginButton.setTitle("log_in_title".localized, for: .normal)
        
        populateStackViewWithFields()
    }
    
    func populateStackViewWithFields() {
        var checkboxes = [CheckboxView]()
        let addFields = viewModel.getAddFields()
        let authorizeFields = viewModel.getAuthorizeFields()
        let enrolFields = viewModel.getEnrolFields()
        
        for field in addFields {
            switch field.type {
            case FieldInputType.textfield.rawValue:
                let view = LoginTextFieldView()
                view.configure(title: field.column ?? "", placeholder: field.description, validationRegEx: field.validation ?? "", fieldType: .authorise, delegate: self)
                fieldsViews.append(view)
            case FieldInputType.password.rawValue:
                let view = LoginTextFieldView()
                view.configure(title: field.column ?? "", placeholder: field.description, validationRegEx: field.validation ?? "", isPassword: true, fieldType: .authorise, delegate: self)
                fieldsViews.append(view)
            case FieldInputType.dropdown.rawValue:
                let view = DropdownView()
                view.configure(title: field.column ?? "", choices: field.choice ?? [], fieldType: .authorise, delegate: self)
                fieldsViews.append(view)
            case FieldInputType.checkbox.rawValue:
                let view = CheckboxView()
                view.configure(title: field.description ?? "", fieldType: .authorise)
                checkboxes.append(view)
            default: break
            }
        }
        
        for field in authorizeFields {
            switch field.type {
            case FieldInputType.textfield.rawValue:
                let view = LoginTextFieldView()
                view.configure(title: field.column ?? "", placeholder: field.description, validationRegEx: field.validation ?? "", fieldType: .authorise, delegate: self)
                fieldsViews.append(view)
            case FieldInputType.password.rawValue:
                let view = LoginTextFieldView()
                view.configure(title: field.column ?? "", placeholder: field.description, validationRegEx: field.validation ?? "", isPassword: true, fieldType: .authorise, delegate: self)
                fieldsViews.append(view)
            case FieldInputType.dropdown.rawValue:
                let view = DropdownView()
                view.configure(title: field.column ?? "", choices: field.choice ?? [], fieldType: .authorise, delegate: self)
                fieldsViews.append(view)
            case FieldInputType.checkbox.rawValue:
                let view = CheckboxView()
                view.configure(title: field.description ?? "", fieldType: .authorise)
                checkboxes.append(view)
            default: break
            }
        }
        
        for field in enrolFields {
            switch field.type {
            case FieldInputType.textfield.rawValue:
                let view = LoginTextFieldView()
                view.configure(title: field.column ?? "", placeholder: field.description, validationRegEx: field.validation ?? "", fieldType: .authorise, delegate: self)
                fieldsViews.append(view)
            case FieldInputType.password.rawValue:
                let view = LoginTextFieldView()
                view.configure(title: field.column ?? "", placeholder: field.description, validationRegEx: field.validation ?? "", isPassword: true, fieldType: .authorise, delegate: self)
                fieldsViews.append(view)
            case FieldInputType.dropdown.rawValue:
                let view = DropdownView()
                view.configure(title: field.column ?? "", choices: field.choice ?? [], fieldType: .authorise, delegate: self)
                fieldsViews.append(view)
            case FieldInputType.checkbox.rawValue:
                let view = CheckboxView()
                view.configure(title: field.description ?? "", fieldType: .authorise)
                checkboxes.append(view)
            default: break
            }
        }
        
        for box in checkboxes {
            fieldsViews.append(box)
        }
        
        if fieldsViews.isEmpty == false {
            for view in fieldsViews {
                if view is UIView {
                    fieldsStackView.addArrangedSubview(view as! UIView)
                }
            }
        }
    }
    
    @objc func popViewController() {
        viewModel.popViewController()
    }
    
    @objc func popToRootScreen() {
        viewModel.popToRootViewController()
    }
    
    @IBAction func loginButtonAction(_ sender: Any) {
        if viewModel.allFieldsAreValid() {
            viewModel.addMembershipCard()
        } else {
            print("Not all fields are valid")
        }
    }
}

extension AuthAndAddViewController: LoyaltyButtonDelegate {
    func brandHeaderViewWasTapped(_ brandHeaderView: BrandHeaderView) {
        viewModel.displaySimplePopup(title: (viewModel.getMembershipPlan().account?.planNameCard) ?? nil, message: (viewModel.getMembershipPlan().account?.planDescription) ?? nil)
    }
}

extension AuthAndAddViewController: LoginTextFieldDelegate {
    func loginTextFieldView(_ loginTextFieldView: LoginTextFieldView, didCompleteWithColumn column: String, value: String, fieldType: FieldType) {
        viewModel.addFieldToCard(column: column, value: value, fieldType: fieldType)
    }
}

extension AuthAndAddViewController: DropdownDelegate {
    func dropdownView(_ dropdownView: DropdownView, didSetDataWithColumn column: String, value: String, fieldType: FieldType) {
        viewModel.addFieldToCard(column: column, value: value, fieldType: fieldType)
    }
}
