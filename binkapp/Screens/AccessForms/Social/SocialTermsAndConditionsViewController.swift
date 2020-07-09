//
//  SocialTermsAndConditionsViewController.swift
//  binkapp
//
//  Created by Max Woodhams on 03/11/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

enum SocialLoginRequestType {
    case facebook(FacebookRequest)
    case apple(SignInWithAppleRequest)
}

class SocialTermsAndConditionsViewController: BaseFormViewController {

    private lazy var continueButton: BinkGradientButton = {
        let button = BinkGradientButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("continue_button_title".localized, for: .normal)
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
    
    private let router: MainScreenRouter?
    private let requestType: SocialLoginRequestType
    
    init(router: MainScreenRouter?, requestType: SocialLoginRequestType) {
        self.router = router
        self.requestType = requestType
        super.init(title: "social_tandcs_title".localized, description: "social_tandcs_subtitle".localized, dataSource: FormDataSource(accessForm: .socialTermsAndConditions))
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setScreenName(trackedScreen: .socialTermsAndConditions)
    }
    
    override func formValidityUpdated(fullFormIsValid: Bool) {
        continueButton.isEnabled = fullFormIsValid
    }
    
    @objc func continueButtonTapped() {
        let preferenceCheckboxes = dataSource.checkboxes.filter { $0.columnKind == .userPreference }
        continueButton.startLoading()
        
        switch requestType {
        case .facebook(let request):
            loginWithFacebook(request: request, preferenceCheckboxes: preferenceCheckboxes)
        case .apple(let request):
            loginWithApple(request: request, preferenceCheckboxes: preferenceCheckboxes)
        }        
    }
    
    // FIXME: To avoid the code duplicate below, in future we need to build the Facebook and Apple request objects from a common object type
    
    private func loginWithFacebook(request: FacebookRequest, preferenceCheckboxes: [CheckboxView]) {
        let networtRequest = BinkNetworkRequest(endpoint: .facebook, method: .post, headers: nil, isUserDriven: true)
        Current.apiClient.performRequestWithParameters(networtRequest, parameters: request, expecting: LoginRegisterResponse.self) { [weak self] result in
            switch result {
            case .success(let response):
                guard let email = response.email else {
                    self?.handleAuthError()
                    return
                }
                Current.userManager.setNewUser(with: response)
                
                let request = BinkNetworkRequest(endpoint: .service, method: .post, headers: nil, isUserDriven: false)
                Current.apiClient.performRequestWithNoResponse(request, parameters: APIConstants.makeServicePostRequest(email: email)) { [weak self] (success, error) in
                    guard success else {
                        self?.handleAuthError()
                        return
                    }
                    
                    // Get latest user profile data in background and ignore any failure
                    // TODO: Move to UserService in future ticket
                    let request = BinkNetworkRequest(endpoint: .me, method: .get, headers: nil, isUserDriven: false)
                    Current.apiClient.performRequest(request, expecting: UserProfileResponse.self) { result in
                        guard let response = try? result.get() else { return }
                        Current.userManager.setProfile(withResponse: response, updateZendeskIdentity: true)
                    }
                    
                    self?.router?.didLogin()
                    self?.updatePreferences(checkboxes: preferenceCheckboxes)
                    self?.continueButton.stopLoading()
                }
            case .failure:
                self?.handleAuthError()
            }
        }
    }
    
    private func loginWithApple(request: SignInWithAppleRequest, preferenceCheckboxes: [CheckboxView]) {
        let networtRequest = BinkNetworkRequest(endpoint: .apple, method: .post, headers: nil, isUserDriven: true)
        Current.apiClient.performRequestWithParameters(networtRequest, parameters: request, expecting: LoginRegisterResponse.self) { [weak self] result in
            switch result {
            case .success(let response):
                guard let email = response.email else {
                    self?.handleAuthError()
                    return
                }
                Current.userManager.setNewUser(with: response)
                
                let request = BinkNetworkRequest(endpoint: .service, method: .post, headers: nil, isUserDriven: false)
                Current.apiClient.performRequestWithNoResponse(request, parameters: APIConstants.makeServicePostRequest(email: email)) { [weak self] (success, error) in
                    guard success else {
                        self?.handleAuthError()
                        return
                    }
                    
                    // Get latest user profile data in background and ignore any failure
                    // TODO: Move to UserService in future ticket
                    let request = BinkNetworkRequest(endpoint: .me, method: .get, headers: nil, isUserDriven: false)
                    Current.apiClient.performRequest(request, expecting: UserProfileResponse.self) { result in
                        guard let response = try? result.get() else { return }
                        Current.userManager.setProfile(withResponse: response, updateZendeskIdentity: true)
                    }
                    
                    self?.router?.didLogin()
                    self?.updatePreferences(checkboxes: preferenceCheckboxes)
                    self?.continueButton.stopLoading()
                }
            case .failure:
                self?.handleAuthError()
            }
        }
    }
    
    func updatePreferences(checkboxes: [CheckboxView]) {

        var params = [String: String]()

        checkboxes.forEach {
            if let columnName = $0.columnName {
                params[columnName] = $0.value
            }
        }

        guard params.count > 0 else { return }

        // We don't worry about whether this was successful or not
        let request = BinkNetworkRequest(endpoint: .preferences, method: .put, headers: nil, isUserDriven: false)
        Current.apiClient.performRequestWithNoResponse(request, parameters: params, completion: nil)
    }
    
    private func showError() {
        let alert = UIAlertController(title: "error_title".localized, message: "social_tandcs_error".localized, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ok".localized, style: .default))
        present(alert, animated: true)
    }

    private func handleAuthError() {
        Current.userManager.removeUser()
        continueButton.stopLoading()
        showError()
    }
    
    override func checkboxView(_ checkboxView: CheckboxView, didTapOn URL: URL) {
        router?.openWebView(withUrlString: URL.absoluteString)
    }
}

extension SocialTermsAndConditionsViewController: FormDataSourceDelegate {
    func formDataSource(_ dataSource: FormDataSource, textField: UITextField, shouldChangeTo newValue: String?, in range: NSRange, for field: FormField) -> Bool {
        return true
    }
}

extension SocialTermsAndConditionsViewController: FormCollectionViewCellDelegate {
    func formCollectionViewCell(_ cell: FormCollectionViewCell, didSelectField: UITextField) {}
    func formCollectionViewCell(_ cell: FormCollectionViewCell, shouldResignTextField textField: UITextField) {}
}

private extension Selector {
    static let continueButtonTapped = #selector(SocialTermsAndConditionsViewController.continueButtonTapped)
}
