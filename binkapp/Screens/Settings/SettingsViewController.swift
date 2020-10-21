//
//  SettingsViewController.swift
//  binkapp
//
//  Created by Max Woodhams on 10/10/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit
import MessageUI
import ZendeskCoreSDK
import SupportSDK

class SettingsViewController: BinkTrackableViewController, BarBlurring {
    
    // MARK: - Helpers
    
    private struct Constants {
        static let rowHeight: CGFloat = 88
        static let headerHeight: CGFloat = 50
        static let privacyPolicyUrl = "https://bink.com/privacy-policy/"
        static let termsAndConditionsUrl = "https://bink.com/terms-and-conditions/"
    }
    
    // MARK: - Properties

    private var zendeskPromptFirstNameTextField: UITextField!
    private var zendeskPromptLastNameTextField: UITextField!
    private var zendeskPromptOKAction: UIAlertAction!
    
    private let viewModel: SettingsViewModel
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(SettingsTableViewCell.self)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = Constants.rowHeight
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        view.addSubview(tableView)
        return tableView
    }()

    internal lazy var blurBackground = defaultBlurredBackground()
    
    // MARK: - View Lifecycle
    
    init(viewModel: SettingsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureLayout()
        title = viewModel.title
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setScreenName(trackedScreen: .settings)
    }

    // MARK: - Navigation Bar Blurring

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        guard let bar = navigationController?.navigationBar else { return }
        prepareBarWithBlur(bar: bar, blurBackground: blurBackground)
    }
    
    private func configureLayout() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
        
        let footerView = SettingsTableViewFooter(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: SettingsTableViewFooter.height))
        tableView.tableFooterView = footerView
    }
    
    private func toSecurityAndPrivacyVC() {
        let title: String = "settings_row_security_title".localized
        let description: String = "security_and_privacy_description".localized
        let configuration = ReusableModalConfiguration(title: title, text: ReusableModalConfiguration.makeAttributedString(title: title, description: description))
        viewModel.pushReusableModal(configurationModel: configuration)
    }
    
    private func toHowItWorksVC() {
        let title: String = "how_it_works_title".localized
        let description: String = "how_it_works_description".localized
        let configuration = ReusableModalConfiguration(title: title, text: ReusableModalConfiguration.makeAttributedString(title: title, description: description))
        viewModel.pushReusableModal(configurationModel: configuration)
    }
    
    private func presentWebView(url: String) {
        viewModel.openWebView(url: url)
    }
}

extension SettingsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.sectionsCount
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.rowsCount(forSectionAtIndex: section)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return SettingsTableViewHeader(title: viewModel.titleForSection(atIndex: section))
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Constants.headerHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: SettingsTableViewCell = tableView.dequeue(indexPath: indexPath)
        
        if let rowData = viewModel.row(atIndexPath: indexPath) {
            let rowCountForSection = viewModel.rowsCount(forSectionAtIndex: indexPath.section)
            cell.setup(with: rowData, showSeparator: (indexPath.row + 1) < rowCountForSection)
        }
        
        return cell
    }
}

// MARK: - TableView

extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell: SettingsTableViewCell? = tableView.cellForRow(at: indexPath) as? SettingsTableViewCell
        cell?.removeActionRequired()
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let rowData = viewModel.row(atIndexPath: indexPath) {
            switch rowData.action {
            case let .customAction(action):
                action()
            case let .launchSupport(service):
                switch service {
                case .faq:
                    let helpCenterConfig = HelpCenterUiConfiguration()
                    helpCenterConfig.showContactOptions = false
                    let articleConfig = ArticleUiConfiguration()
                    articleConfig.showContactOptions = false
                    let viewController = ZDKHelpCenterUi.buildHelpCenterOverviewUi(withConfigs: [helpCenterConfig, articleConfig])
                    let navigationRequest = PushNavigationRequest(viewController: viewController)
                    Current.navigate.to(navigationRequest)
                case .contactUs:
                    let launchContactUs = {
                        // TODO: Move all to viewmodel
                        let viewController = RequestUi.buildRequestList()
                        let navigationRequest = PushNavigationRequest(viewController: viewController)
                        Current.navigate.to(navigationRequest)
                    }

                    /// We are getting the textfields and action item back from the alert controller in closures so that we can reference them in the UITextFieldDelegate
                    if ZendeskService.shouldPromptForIdentity {
                        let alert = UIAlertController.makeZendeskIdentityAlertController(firstNameTextField: { [weak self] textField in
                            self?.zendeskPromptFirstNameTextField = textField
                        }, lastNameTextField: { [weak self] textField in
                            self?.zendeskPromptLastNameTextField = textField
                        }, okActionObject: { [weak self] actionObject in
                            self?.zendeskPromptOKAction = actionObject
                        }, okActionHandler: {
                            launchContactUs()
                        }, textFieldDelegate: self)
                        let navigationRequest = AlertNavigationRequest(alertController: alert)
                        Current.navigate.to(navigationRequest)
                    } else {
                        launchContactUs()
                    }
                }
            case let .pushToViewController(viewController: viewControllerType):
                switch viewControllerType {
                case is SettingsViewController.Type:
                    let vc = SettingsViewController(viewModel: viewModel)
                    present(vc, animated: true)
                case is DebugMenuTableViewController.Type:
                    let debugMenuFactory = DebugMenuFactory()
                    let debugMenuViewModel = DebugMenuViewModel(debugMenuFactory: debugMenuFactory)
                    let debugMenuViewController = DebugMenuTableViewController(viewModel: debugMenuViewModel)
                    debugMenuFactory.delegate = debugMenuViewController
                    let navigationRequest = PushNavigationRequest(viewController: debugMenuViewController)
                    Current.navigate.to(navigationRequest)
                case is PreferencesViewController.Type:
                    let viewController = PreferencesViewController(viewModel: PreferencesViewModel())
                    let navigationRequest = PushNavigationRequest(viewController: viewController)
                    Current.navigate.to(navigationRequest)
                case is WhoWeAreViewController.Type:
                    let viewController = WhoWeAreViewController()
                    let navigationRequest = PushNavigationRequest(viewController: viewController)
                    Current.navigate.to(navigationRequest)
                default:
                    print("Unsupported VC for presentation")
                }
            case .pushToReusable(let screen):
                switch screen {
                case .securityAndPrivacy:
                    toSecurityAndPrivacyVC()
                case .howItWorks:
                    toHowItWorksVC()
                case .privacyPolicy:
                    presentWebView(url: Constants.privacyPolicyUrl)
                case .termsAndConditions:
                    presentWebView(url: Constants.termsAndConditionsUrl)
                }
            case .logout:
                let alert = UIAlertController(title: "Log out", message: "Are you sure you want to log out?", preferredStyle: .alert)
                alert.addAction(
                    UIAlertAction(title: "Log out", style: .default, handler: { _ in
                        NotificationCenter.default.post(name: .shouldLogout, object: nil)
                    })
                )
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                let navigationRequest = AlertNavigationRequest(alertController: alert)
                Current.navigate.to(navigationRequest)
            }
        }
    }
}

extension SettingsViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        /// If both textfields are empty, disable ok action as at least one textfield will be empty after updating
        let firstNameText = zendeskPromptFirstNameTextField.text ?? ""
        let lastNameText = zendeskPromptLastNameTextField.text ?? ""
        if firstNameText.isEmpty && lastNameText.isEmpty {
            zendeskPromptOKAction.isEnabled = false
        }
        /// If both textfields are NOT empty, and the replacement string is NOT empty, we know that both textfields must have values after updating
        if !firstNameText.isEmpty && !lastNameText.isEmpty && !string.isEmpty {
            zendeskPromptOKAction.isEnabled = true
        }

        /// If the textfield being updated is firstName, and it has no current value, and the replacement string has a value, and lastName has a value then we know that both textfields will have values after updating
        if textField == zendeskPromptFirstNameTextField && firstNameText.isEmpty && !string.isEmpty && !lastNameText.isEmpty {
            zendeskPromptOKAction.isEnabled = true
        }

        /// If the textfield being updated is lastName, and it has no current value, and the replacement string has a value, and firstName has a value then we know that both textfields will have values after updating
        if textField == zendeskPromptLastNameTextField && lastNameText.isEmpty && !string.isEmpty && !firstNameText.isEmpty {
            zendeskPromptOKAction.isEnabled = true
        }

        /// If the textfield being updated is firstName, and it's current value is only one character, and the replacement string has no value then we know the textfield will have no value after updating
        if textField == zendeskPromptFirstNameTextField && firstNameText.count == 1 && string.isEmpty {
            zendeskPromptOKAction.isEnabled = false
        }

        /// If the textfield being updated is lastName, and it's current value is only one character, and the replacement string has no value then we know the textfield will have no value after updating
        if textField == zendeskPromptLastNameTextField && lastNameText.count == 1 && string.isEmpty {
            zendeskPromptOKAction.isEnabled = false
        }

        return true
    }
}

extension UIAlertController {
    static func makeZendeskIdentityAlertController(firstNameTextField: @escaping (UITextField) -> Void, lastNameTextField: @escaping (UITextField) -> Void, okActionObject: (UIAlertAction) -> Void, okActionHandler: @escaping () -> Void, textFieldDelegate: UITextFieldDelegate?) -> UIAlertController {
        let alert = UIAlertController(title: nil, message: "zendesk_identity_prompt_message".localized, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "zendesk_identity_prompt_first_name".localized
            textField.autocapitalizationType = .words
            textField.delegate = textFieldDelegate
            firstNameTextField(textField)
        }
        alert.addTextField { textField in
            textField.placeholder = "zendesk_identity_prompt_last_name".localized
            textField.autocapitalizationType = .words
            textField.delegate = textFieldDelegate
            lastNameTextField(textField)
        }
        let cancelAction = UIAlertAction(title: "cancel".localized, style: .cancel, handler: nil)
        let okAction = UIAlertAction(title: "ok".localized, style: .default) { _ in
            let firstName = alert.textFields?[0].text
            let lastName = alert.textFields?[1].text
            let request = BinkNetworkRequest(endpoint: .me, method: .put, headers: nil, isUserDriven: false)
            let params = UserProfileUpdateRequest(firstName: firstName, lastName: lastName)
            Current.apiClient.performRequestWithBody(request, body: params, expecting: UserProfileResponse.self) { (result, _) in
                guard let response = try? result.get() else { return }
                /// Don't update Zendesk identity, as we do this with the textField input values, and do not need to set it twice.
                Current.userManager.setProfile(withResponse: response, updateZendeskIdentity: false)
            }

            /// Use raw input to move forward with new zendesk identity
            ZendeskService.setIdentity(firstName: firstName, lastName: lastName)
            okActionHandler()
        }
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        okActionObject(okAction)
        return alert
    }
}
