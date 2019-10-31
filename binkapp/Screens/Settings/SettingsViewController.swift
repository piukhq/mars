//
//  SettingsViewController.swift
//  binkapp
//
//  Created by Max Woodhams on 10/10/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit
import MessageUI

class SettingsViewController: UIViewController {
    
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
    
    private func configureLayout() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
        ])
    }
    
    func getAttributedString(title: String, description: String) -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString()
        let attributedTitle = NSAttributedString(string: title + "\n", attributes: [NSAttributedString.Key.font : UIFont.headline])
        let attributedBody = NSAttributedString(string: description, attributes: [NSAttributedString.Key.font : UIFont.bodyTextLarge])
        attributedString.append(attributedTitle)
        attributedString.append(attributedBody)
        
        return attributedString
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
                //TODO: Add sendEmail call with correct content.
            case .notImplemented, .contactUsAction:
                UIAlertController.presentFeatureNotImplementedAlert(on: self)
                break
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
                default:
                    print("Unsupported VC for presentation")
                    break
                }
            case .pushToReusable(let screen):
                switch screen {
                case .securityAndPrivacy:
                    let title: String = "settings_row_security_title".localized
                    let description: String = "security_and_privacy_description".localized
                    let backButton = UIBarButtonItem(image: UIImage(named: "navbarIconsBack"), style: .plain, target: self, action: #selector(popViewController))
                    let configuration = ReusableModalConfiguration(title: title, text: getAttributedString(title: title, description: description), tabBarBackButton: backButton)
                    viewModel.pushReusableModal(configurationModel: configuration, navController: navigationController)
                    break
                case .howItWorks: break
                }
            }
        }
    }
}

// MARK: - Mail Compose

extension SettingsViewController: MFMailComposeViewControllerDelegate {
    private func sendEmail() {
        if MFMailComposeViewController.canSendMail() {
            let mailViewController = MFMailComposeViewController()
            mailViewController.mailComposeDelegate = self
            mailViewController.setToRecipients([Constants.supportEmail])
            mailViewController.setMessageBody("lorem_ipsum".localized, isHTML: false)
            
            present(mailViewController, animated: true)
        } else {
            MainScreenRouter.openExternalURL(with: "mailto:\(Constants.supportEmail)")
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}
