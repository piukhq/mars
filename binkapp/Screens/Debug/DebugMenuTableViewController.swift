//
//  DebugMenuTableViewController.swift
//  binkapp
//
//  Created by Nick Farrant on 02/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class DebugMenuTableViewController: UITableViewController, ModalDismissable {
    
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
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Dev", style: .default, handler: { [weak self] _ in
                APIConstants.changeEnvironment(environment: .dev)
                self?.tableView.reloadData()
            }))
            alert.addAction(UIAlertAction(title: "Staging", style: .default, handler: { [weak self] _ in
                APIConstants.changeEnvironment(environment: .staging)
                self?.tableView.reloadData()
            }))
            alert.addAction(UIAlertAction(title: "Daedalus", style: .default, handler: { [weak self] _ in
                APIConstants.changeEnvironment(environment: .daedalus)
                self?.tableView.reloadData()
            }))
            alert.addAction(UIAlertAction(title: "Custom", style: .destructive, handler: { [weak self] _ in
                let customAlert = UIAlertController(title: "Base URL", message: "Please insert a valid URL.", preferredStyle: .alert)
                customAlert.addTextField { textField in
                    textField.placeholder = "api.dev.gb.com"
                }
                if let textField = customAlert.textFields?.first, let textFieldText = textField.text {
                    customAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                        APIConstants.moveToCustomURL(url: textFieldText)
                    }))
                    self?.navigationController?.present(customAlert, animated: true, completion: nil)
                }
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            navigationController?.present(alert, animated: true, completion: nil)
        case .mockBKWallet:
            Current.userDefaults.set(!Current.userDefaults.bool(forDefaultsKey: .mockBKWalletIsEnabled), forDefaultsKey: .mockBKWalletIsEnabled)
            tableView.reloadData()
        default:
            return
        }
    }
}
