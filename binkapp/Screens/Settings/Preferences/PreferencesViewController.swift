//
//  PreferencesViewController.swift
//  binkapp
//
//  Created by Paul Tiriteu on 20/11/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import KeychainAccess
import UIKit

class PreferencesViewController: BinkViewController {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet private weak var clearCredentialsButton: UIButton!
    @IBOutlet private weak var errorLabel: UILabel!
    
    private let viewModel: PreferencesViewModel
    private var checkboxes: [CheckboxView] = []
    private var modifiedPreferences: [PreferencesModel] = []
    
    init(viewModel: PreferencesViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setScreenName(trackedScreen: .preferences)
    }
    
    private func configureUI() {
        navigationItem.leftBarButtonItem?.title = nil
        
        titleLabel.text = L10n.settingsRowPreferencesTitle
        titleLabel.font = UIFont.headline
        
        errorLabel.font = UIFont.bodyTextSmall
        errorLabel.textColor = .red
        
        let clearCredentialsAttributedString = NSAttributedString(string: L10n.preferencesClearCredentials, attributes: [.underlineStyle: NSUnderlineStyle.single.rawValue, .font: UIFont.linkUnderlined, .foregroundColor: UIColor.blueAccent])
        let clearCredentialsAttributedStringHighlighted = NSAttributedString(string: L10n.preferencesClearCredentials, attributes: [.underlineStyle: NSUnderlineStyle.single.rawValue, .font: UIFont.linkUnderlined, .foregroundColor: UIColor.blueAccent.withAlphaComponent(0.5)])

        clearCredentialsButton.setAttributedTitle(clearCredentialsAttributedString, for: .normal)
        clearCredentialsButton.setAttributedTitle(clearCredentialsAttributedStringHighlighted, for: .highlighted)
        
        let attributedString = NSMutableAttributedString(string: L10n.preferencesScreenDescription, attributes: [.font: UIFont.bodyTextLarge])
        let base = NSString(string: attributedString.string)
        let rewardsRange = base.range(of: L10n.preferencesPromptHighlightRewards)
        let offersRange = base.range(of: L10n.preferencesPromptHighlightOffers)
        let updatesRange = base.range(of: L10n.preferencesPromptHighlightUpdates)
        
        let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.subtitle]
        
        attributedString.addAttributes(attributes, range: rewardsRange)
        attributedString.addAttributes(attributes, range: offersRange)
        attributedString.addAttributes(attributes, range: updatesRange)
        
        descriptionLabel.attributedText = attributedString
        
        viewModel.getPreferences(onSuccess: { [weak self] (preferences) in
            self?.createCheckboxes(preferences: preferences)
        }) { [weak self] in
            self?.errorLabel.text = L10n.preferencesRetrieveFail
            self?.errorLabel.isHidden = false
        }
    }
    
    private func createCheckboxes(preferences: [PreferencesModel]) {
        preferences.forEach {
            let checked: Bool = $0.value == "1"
            let checkboxView = CheckboxView(checked: checked)
            let attributedString = $0.slug == "marketing-bink" ?
                NSMutableAttributedString(string: L10n.preferencesMarketingCheckbox, attributes: [.font: UIFont.bodyTextSmall]) :
                NSMutableAttributedString(string: $0.label ?? "", attributes: [.font: UIFont.bodyTextSmall])
            checkboxView.configure(title: attributedString, columnName: $0.slug ?? "", columnKind: .add, delegate: self)
            
            stackView.addArrangedSubview(checkboxView)
            checkboxes.append(checkboxView)
        }
    }
    
    func clearStoredCredentials() {
        let keychain = Keychain(service: APIConstants.bundleID)
        try? keychain.remove("autofill_values")
    }
    
    @IBAction func clearCredentialsButtonTapped(_ sender: Any) {
        clearStoredCredentials()
    }
}

extension PreferencesViewController: CheckboxViewDelegate {
    func checkboxView(_ checkboxView: CheckboxView, didCompleteWithColumn column: String, value: String, fieldType: FormField.ColumnKind) {
        guard Current.apiClient.networkIsReachable else {
            viewModel.presentNoConnectivityPopup()
            checkboxView.reset()
            return
        }
        guard let columnName = checkboxView.columnName else { return }
        
        let checkboxState = value == "true" ? "1" : "0"
        let dictionary = [columnName: checkboxState]
        
        if column == "Remember my details" && value == "false" {
            let alert = ViewControllerFactory.makeOkCancelAlertViewController(title: "Clear stored credentials", message: "Would you like to also remove stored credentials from this device?", cancelButton: true) { [weak self] in
                self?.clearStoredCredentials()
            }
            let navigationRequest = AlertNavigationRequest(alertController: alert)
            Current.navigate.to(navigationRequest)
        }

        viewModel.putPreferences(preferences: dictionary, onSuccess: { [weak self] in
            self?.errorLabel.isHidden = true
            if let _ = dictionary["remember-my-details"] {
                Current.userDefaults.set(Bool(value), forDefaultsKey: .rememberMyDetails)
            }
        }) { [weak self] _ in
            checkboxView.reset()
            self?.errorLabel.text = L10n.preferencesUpdateFail
            self?.errorLabel.isHidden = false
        }
    }
}
