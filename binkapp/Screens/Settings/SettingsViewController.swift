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
        static let supportEmail = "support@bink.com"
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
        let closeButton = UIBarButtonItem(image: UIImage(named: "close"), style: .plain, target: self, action: #selector(close))
        navigationItem.rightBarButtonItem = closeButton
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
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
        ])
    }
    
    private func toSecurityAndPrivacyVC() {
        let title: String = "settings_row_security_title".localized
        let description: String = "security_and_privacy_description".localized
        let backButton = UIBarButtonItem(image: UIImage(named: "navbarIconsBack"), style: .plain, target: self, action: #selector(popViewController))
        let configuration = ReusableModalConfiguration(title: title, text: ReusableModalConfiguration.makeAttributedString(title: title, description: description), tabBarBackButton: backButton)
        viewModel.pushReusableModal(configurationModel: configuration, navController: navigationController)
    }
    
    private func toHowItWorksVC() {
        let title: String = "how_it_works_title".localized
        let description: String = "how_it_works_description".localized
        let backButton = UIBarButtonItem(image: UIImage(named: "navbarIconsBack"), style: .plain, target: self, action: #selector(popViewController))
        let configuration = ReusableModalConfiguration(title: title, text: ReusableModalConfiguration.makeAttributedString(title: title, description: description), tabBarBackButton: backButton)
        viewModel.pushReusableModal(configurationModel: configuration, navController: navigationController)
    }
    
    // MARK: - Action
    @objc func popViewController() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func close() {
        dismiss(animated: true)
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
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let rowData = viewModel.row(atIndexPath: indexPath) {
            switch rowData.action {
            case let .customAction(action):
                action()
                break
            case let .launchSupport(service):
                switch service {
                case .faq:
                    let viewController = ZDKHelpCenterUi.buildHelpCenterOverviewUi()
                    navigationController?.pushViewController(viewController, animated: true)
                case .contactUs:
                    let viewController = RequestUi.buildRequestList()
                    navigationController?.pushViewController(viewController, animated: true)
                }
            case let .pushToViewController(viewController: viewControllerType):
                switch viewControllerType {
                case is SettingsViewController.Type:
                    let vc = SettingsViewController(viewModel: viewModel)
                    present(vc, animated: true)
                    break
                case is DebugMenuTableViewController.Type:
                    let debugMenuFactory = DebugMenuFactory()
                    let debugMenuViewModel = DebugMenuViewModel(debugMenuFactory: debugMenuFactory)
                    let debugMenuViewController = DebugMenuTableViewController(viewModel: debugMenuViewModel)
                    debugMenuFactory.delegate = debugMenuViewController
                    navigationController?.pushViewController(debugMenuViewController, animated: true)
                    break
                case is PreferencesViewController.Type:
                    let repository = PreferencesRepository(apiClient: viewModel.router.apiClient)
                    let viewModel = PreferencesViewModel(repository: repository, router: self.viewModel.router)
                    let viewController = PreferencesViewController(viewModel: viewModel)
                    navigationController?.pushViewController(viewController, animated: true)
                default:
                    print("Unsupported VC for presentation")
                    break
                }
            case .pushToReusable(let screen):
                switch screen {
                case .securityAndPrivacy:
                    toSecurityAndPrivacyVC()
                    break
                case .howItWorks:
                    toHowItWorksVC()
                    break
                }
            case .logout:
                let alert = UIAlertController(title: "Log out", message: "Are you sure you want to log out?", preferredStyle: .alert)
                alert.addAction(
                    UIAlertAction(title: "Log out", style: .default, handler: { _ in
                        NotificationCenter.default.post(name: .shouldLogout, object: nil)
                    })
                )
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                present(alert, animated: true)
            }
        }
    }
}

// MARK: - Mail Compose

extension SettingsViewController: MFMailComposeViewControllerDelegate {
    private func sendEmail() {
        if MFMailComposeViewController.canSendMail() {
            let binkId = Current.userManager.currentEmailAddress ?? ""
            let shortVersionNumber = Bundle.shortVersionNumber ?? ""
            let buildNumber = Bundle.bundleVersion ?? ""
            let appVersion = String(format: "support_mail_app_version".localized, shortVersionNumber, buildNumber)
            let osVersion = UIDevice.current.systemVersion
            let mailBody = String.init(format: "support_mail_body".localized, binkId, appVersion, osVersion)
            let mailViewController = MFMailComposeViewController()
            mailViewController.mailComposeDelegate = self
            mailViewController.setToRecipients([Constants.supportEmail])
            mailViewController.setSubject("support_mail_subject".localized)
            mailViewController.setMessageBody(mailBody, isHTML: false)
            
            present(mailViewController, animated: true)
        } else {
            MainScreenRouter.openExternalURL(with: "mailto:\(Constants.supportEmail)")
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}
