//
//  DebugMenuTableViewController.swift
//  binkapp
//
//  Created by Nick Farrant on 02/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

import ZendeskCoreSDK
import SupportSDK

class DebugMenuTableViewController: UITableViewController, ModalDismissable {
    private var webScrapingUtility: WebScrapingUtility?
    
    private let viewModel: DebugMenuViewModel
    
    init(viewModel: DebugMenuViewModel) {
        self.viewModel = viewModel
        super.init(style: .grouped)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = viewModel.title
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "close"), style: .plain, target: self, action: #selector(close))
        
        tableView.register(DebugMenuTableViewCell.self, asNib: true)
        tableView.register(DebugMenuSegmentedTableViewCell.self, asNib: true)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.sectionsCount
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.titleForSection(atIndex: section)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.rowsCount(forSectionAtIndex: section)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if viewModel.sections.first?.rows[indexPath.row].cellType == DebugMenuRow.CellType.segmentedControl {
            let cell: DebugMenuSegmentedTableViewCell = tableView.dequeue(indexPath: indexPath)
            return cell
        }
        
        let cell: DebugMenuTableViewCell = tableView.dequeue(indexPath: indexPath)
        
        let row = viewModel.row(atIndexPath: indexPath)
        cell.configure(withDebugRow: row)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return viewModel.cellHeight
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = viewModel.row(atIndexPath: indexPath)
        row.action?()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - ModalDismissable
    
    @objc func close() {
        dismiss(animated: true, completion: nil)
    }
}

extension DebugMenuTableViewController: DebugMenuFactoryDelegate {
    func debugMenuFactory(_ debugMenuFactory: DebugMenuFactory, shouldPerformActionForType type: DebugMenuRow.RowType) {
        switch type {
        case .endpoint:
            guard let navController = navigationController else { return }
            let alert = debugMenuFactory.makeEnvironmentAlertController(navigationController: navController)
            navController.present(alert, animated: true, completion: nil)
        case .secondaryColor:
            let viewController = DebugSecondaryPlanColorViewController()
            navigationController?.pushViewController(viewController, animated: true)
        case .webScraping:
            webScrapingUtility = WebScrapingUtility(containerViewController: self, agent: TescoScrapingAgent(), delegate: self)
            do {
                try webScrapingUtility?.start()
            } catch let error {
                let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                let closeAction = UIAlertAction(title: "Close", style: .default, handler: nil)
                alert.addAction(closeAction)
                present(alert, animated: true, completion: nil)
            }
        default:
            return
        }
    }
}

extension DebugMenuTableViewController: WebScrapingUtilityDelegate {
    func webScrapingUtility(_ utility: WebScrapingUtility, didCompleteWithValue value: String) {
        let alert = UIAlertController(title: "Success", message: "You have \(value) points", preferredStyle: .alert)
        let closeAction = UIAlertAction(title: "Close", style: .default, handler: nil)
        alert.addAction(closeAction)
        present(alert, animated: true, completion: nil)
    }
    
    func webScrapingUtility(_ utility: WebScrapingUtility, didCompleteWithError error: WebScrapingUtilityError) {
        print(error)
    }
    
    func webScrapingUtilityDidPromptForCredentials(_ utility: WebScrapingUtility, agent: WebScrapable) {
//        guard let credentials = try? Current.pointsScrapingManager.retrieveCredentials(forMemebershipPlanId: 207) else {
//            return
//        }
//        
//        do {
//            try webScrapingUtility?.login(agent: agent, credentials: credentials)
//        } catch let error {
//            // TODO: Handle error
//            print(error)
//        }
        
//        let alert = UIAlertController(title: "Login required", message: "Please enter your \(agent.loyaltySchemeName) credentials", preferredStyle: .alert)
//        alert.addTextField { textField in
//            textField.placeholder = "Username"
//        }
//        alert.addTextField { textField in
//            textField.placeholder = "Password"
//            textField.isSecureTextEntry = true
//        }
//        let cancelAction = UIAlertAction(title: "cancel".localized, style: .cancel, handler: nil)
//        let okAction = UIAlertAction(title: "ok".localized, style: .default) { [weak self] action in
//            let username = alert.textFields?[0].text
//            let password = alert.textFields?[1].text
//            let credentials = WebScrapingCredentials(username: username ?? "", password: password ?? "")
//
//            do {
//                try self?.webScrapingUtility?.login(agent: agent, credentials: credentials)
//            } catch let error {
//                let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
//                let closeAction = UIAlertAction(title: "Close", style: .default, handler: nil)
//                alert.addAction(closeAction)
//                self?.present(alert, animated: true, completion: nil)
//            }
//        }
//        alert.addAction(cancelAction)
//        alert.addAction(okAction)
//        present(alert, animated: true, completion: nil)
    }
}
