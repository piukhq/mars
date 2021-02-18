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

class DebugMenuTableViewController: UITableViewController {
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
        
        tableView.register(DebugMenuTableViewCell.self, asNib: true)
        tableView.register(DebugMenuSegmentedTableViewCell.self, asNib: true)
        tableView.register(DebugMenuSegmentedTestTableViewCell.self, asNib: true)
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
        
        /// Remove after testing >>>>>>>>>>>>>>>
        if viewModel.sections.first?.rows[indexPath.row].cellType == DebugMenuRow.CellType.picker {
            let cell: DebugMenuSegmentedTestTableViewCell = tableView.dequeue(indexPath: indexPath)
            cell.type = .link
//            if indexPath.row == 10 {
//                cell = DebugMenuSegmentedTestTableViewCell(type: .link)
//            } else if indexPath.row == 11 {
//
//            } else {
//
//            }
            
            return cell
        }
        /// <<<<<<<<<<<<<<<<<<
        
        let cell: DebugMenuTableViewCell = tableView.dequeue(indexPath: indexPath)
        
        let row = viewModel.row(atIndexPath: indexPath)
        cell.configure(withDebugRow: row)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if viewModel.sections.first?.rows[indexPath.row].cellType == DebugMenuRow.CellType.picker {
            return 100 } else { /// <<<<<<<<<<<<<<<<<<< Remove after testing
                return viewModel.cellHeight
            }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = viewModel.row(atIndexPath: indexPath)
        row.action?()
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension DebugMenuTableViewController: DebugMenuFactoryDelegate {
    func debugMenuFactory(_ debugMenuFactory: DebugMenuFactory, shouldPerformActionForType type: DebugMenuRow.RowType) {
        switch type {
        case .endpoint:
            guard let navController = navigationController else { return }
            let alert = debugMenuFactory.makeEnvironmentAlertController(navigationController: navController)
            navController.present(alert, animated: true)
        case .secondaryColor:
            let viewController = DebugSecondaryPlanColorViewController()
            navigationController?.pushViewController(viewController, animated: true)
        case .lpcWebView:
            let shouldShow = Current.userDefaults.bool(forDefaultsKey: .lpcDebugWebView)
            Current.userDefaults.set(!shouldShow, forDefaultsKey: .lpcDebugWebView)
            tableView.reloadData()
        case .lpcCookies:
            let shouldUseCookies = Current.userDefaults.bool(forDefaultsKey: .lpcUseCookies)
            Current.userDefaults.set(!shouldUseCookies, forDefaultsKey: .lpcUseCookies)
            tableView.reloadData()
        case .responseCodeVisualiser:
            let shouldShow = Current.userDefaults.bool(forDefaultsKey: .responseCodeVisualiser)
            Current.userDefaults.set(!shouldShow, forDefaultsKey: .responseCodeVisualiser)
            tableView.reloadData()
        case .inAppReviewRules:
            let shouldApply = Current.userDefaults.bool(forDefaultsKey: .applyInAppReviewRules)
            Current.userDefaults.set(!shouldApply, forDefaultsKey: .applyInAppReviewRules)
            tableView.reloadData()
        default:
            return
        }
    }
}
