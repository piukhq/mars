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


protocol SettingsViewControllerDelegate: AnyObject {
    func settingsViewControllerDidDismiss(_ settingsViewController: SettingsViewController)
}

class SettingsViewController: BinkViewController {
    // MARK: - Helpers
    
    private enum Constants {
        static let rowHeight: CGFloat = 88
        static let headerHeight: CGFloat = 50
        static let privacyPolicyUrl = "https://bink.com/privacy-policy/"
        static let termsAndConditionsUrl = "https://bink.com/terms-and-conditions/"
    }
    
    // MARK: - Properties
    
    private let viewModel: SettingsViewModel
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(SettingsTableViewCell.self)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = Constants.rowHeight
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        view.addSubview(tableView)
        return tableView
    }()

    private let zendeskTickets = ZendeskTickets()
    private weak var delegate: SettingsViewControllerDelegate?

    /// Zendesk view controllers malform our navigation bar. This flag tells our view controller to reconfigure for the current theme next time it comes into view.
    private var navigationBarRequiresThemeUpdate = false
    
    // MARK: - View Lifecycle
    
    init(viewModel: SettingsViewModel, delegate: SettingsViewControllerDelegate?) {
        self.viewModel = viewModel
        self.delegate = delegate
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setToolbarHidden(true, animated: true)

        if let nav = navigationController as? PortraitNavigationController, navigationBarRequiresThemeUpdate {
            nav.configureForCurrentTheme()
            navigationBarRequiresThemeUpdate = false
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setScreenName(trackedScreen: .settings)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        delegate?.settingsViewControllerDidDismiss(self)
    }

    override func configureForCurrentTheme() {
        super.configureForCurrentTheme()
        tableView.reloadData()
        tableView.indicatorStyle = Current.themeManager.scrollViewIndicatorStyle(for: traitCollection)
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
        let title: String = L10n.settingsRowSecurityTitle
        let description: String = L10n.securityAndPrivacyDescription
        let configuration = ReusableModalConfiguration(title: title, text: ReusableModalConfiguration.makeAttributedString(title: title, description: description))
        viewModel.pushReusableModal(configurationModel: configuration)
    }
    
    private func toHowItWorksVC() {
        let title: String = L10n.howItWorksTitle
        let description: String = L10n.howItWorksDescription
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
                navigationBarRequiresThemeUpdate = true
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
                    zendeskTickets.launch()
                }
            case let .pushToViewController(viewController: viewControllerType):
                switch viewControllerType {
                case is SettingsViewController.Type:
                    let vc = SettingsViewController(viewModel: viewModel, delegate: nil)
                    present(vc, animated: true)
                case is DebugMenuTableViewController.Type:
                    let viewController = ViewControllerFactory.makeDebugViewController()
                    let navigationRequest = PushNavigationRequest(viewController: viewController)
                    Current.navigate.to(navigationRequest)
                case is PreferencesViewController.Type:
                    let viewController = PreferencesViewController(viewModel: PreferencesViewModel())
                    let navigationRequest = PushNavigationRequest(viewController: viewController)
                    Current.navigate.to(navigationRequest)
                case is WhoWeAreViewController.Type:
                    let viewController = WhoWeAreViewController()
                    let navigationRequest = PushNavigationRequest(viewController: viewController)
                    Current.navigate.to(navigationRequest)
                case is FeatureFlagsTableViewController.Type:
                    let viewController = FeatureFlagsTableViewController(viewModel: FeatureFlagsViewModel(), delegate: self)
                    let navigationRequest = PushNavigationRequest(viewController: viewController)
                    Current.navigate.to(navigationRequest)
                default:
                    if #available(iOS 14.0, *) {
                        BinkLogger.error(AppLoggerError.unsupportedViewController)
                    }
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
                let alert = BinkAlertController(title: "Log out", message: "Are you sure you want to log out?", preferredStyle: .alert)
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

extension SettingsViewController: FeatureFlagsViewControllerDelegate {
    func featureFlagsViewControllerDidDismiss(_ featureFlagsViewController: FeatureFlagsTableViewController) {
        tableView.reloadData()
    }
}
