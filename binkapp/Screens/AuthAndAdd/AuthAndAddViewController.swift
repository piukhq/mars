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
        static let bottomButtonPadding: CGFloat = 22.0
        static let buttonsSpacing: CGFloat = 20
    }
    
    private lazy var brandHeaderView: BrandHeaderView = {
        let brandHeader = BrandHeaderView()
        brandHeader.heightAnchor.constraint(equalToConstant: 110).isActive = true
        return brandHeader
    }()

    private lazy var loginButton: BinkGradientButton = {
        let button = BinkGradientButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("login".localized, for: .normal)
        button.titleLabel?.font = UIFont.buttonText
        button.addTarget(self, action: .loginButtonTapped, for: .touchUpInside)
        button.isEnabled = false
        view.addSubview(button)
        return button
    }()
    
    private lazy var accountButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("no_account_button_title".localized, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: .accountButtonTapped, for: .touchUpInside)
        view.addSubview(button)
        return button
    }()
    
    private let viewModel: AuthAndAddViewModel
    
    init(viewModel: AuthAndAddViewModel) {
        self.viewModel = viewModel
        let datasource = FormDataSource(authAdd: viewModel.getMembershipPlan(), formPurpose: viewModel.formPurpose)
        super.init(title: "login".localized, description: "", dataSource: datasource)
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
            accountButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: Constants.buttonWidthPercentage),
            accountButton.heightAnchor.constraint(equalToConstant: Constants.buttonHeight),
            accountButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -Constants.bottomButtonPadding),
            accountButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            loginButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: Constants.buttonWidthPercentage),
            loginButton.heightAnchor.constraint(equalToConstant: Constants.buttonHeight),
            loginButton.bottomAnchor.constraint(equalTo: accountButton.topAnchor, constant: -Constants.buttonsSpacing),
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
        
        accountButton.isHidden = viewModel.accountButtonShouldHide
    }
    
    @objc func popViewController() {
        viewModel.popViewController()
    }
    
    @objc func popToRootScreen() {
        viewModel.popToRootViewController()
    }
        
    @objc func loginButtonTapped() {
        try? viewModel.addMembershipCard(with: dataSource.fields, checkboxes: dataSource.checkboxes)
    }
    
    @objc func accountButtonTapped() {
        let fields = viewModel.getMembershipPlan().featureSet?.formattedLinkingSupport
        guard (fields?.contains(where: { $0.value == "REGISTRATION" }) ?? false) else {
            viewModel.displaySimplePopup(title: "doesn't have registration fields", message: nil)
            return
        }
        viewModel.displaySimplePopup(title: "has registration fields", message: nil)
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
    static let accountButtonTapped = #selector(AuthAndAddViewController.accountButtonTapped)
}
