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
        
        let closeBarButton = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(close))
        navigationItem.rightBarButtonItem = closeBarButton
        
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
        case .email:
            let alert = UIAlertController(title: "Edit Email Address", message: "This will overwrite the current logged in email address and reboot the app.", preferredStyle: .alert)
            alert.addTextField { textField in
                textField.placeholder = "New email address"
                textField.text = Current.userDefaults.string(forKey: "userEmail")
            }

            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let okAction = UIAlertAction(title: "Ok", style: .default) { [weak self] _ in
                guard let textField = alert.textFields?.first else {
                    return
                }
                guard let newEmail = textField.text else {
                    return
                }

                Current.userDefaults.set(newEmail, forKey: "userEmail")
            
                self?.clearMembershipCards {
                    exit(0)
                }
                
            }
            alert.addAction(cancelAction)
            alert.addAction(okAction)
            navigationController?.present(alert, animated: true, completion: nil)
        default:
            return
        }
    }
    
    private func clearMembershipCards(completion: @escaping () -> Void) {
        Current.database.performBackgroundTask { context in
            context.deleteAll(CD_MembershipCard.self)
            try? context.save()
            DispatchQueue.main.async {
                completion()
            }
        }
    }
}
