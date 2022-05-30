//
//  DebugMenuTableViewController.swift
//  binkapp
//
//  Created by Nick Farrant on 02/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class DebugMenuTableViewController: BinkTableViewController {
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
        tableView.register(DebugMenuPickerTableViewCell.self, asNib: true)
    }
    
    override func configureForCurrentTheme() {
        view.backgroundColor = Current.themeManager.color(for: .viewBackground)
        tableView.reloadData()
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
        let row = viewModel.row(atIndexPath: indexPath)
        
        switch viewModel.sections.first?.rows[indexPath.row].cellType {
        case .segmentedControl:
            let cell: DebugMenuSegmentedTableViewCell = tableView.dequeue(indexPath: indexPath)
            return cell
        case .picker:
            let cell: DebugMenuPickerTableViewCell = tableView.dequeue(indexPath: indexPath)
            cell.configure(debugRow: row)
            return cell
        default:
            break
        }
        
        let cell: DebugMenuTableViewCell = tableView.dequeue(indexPath: indexPath)
        cell.configure(withDebugRow: row)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return viewModel.cellHeight(atIndex: indexPath.row)
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
        case .lpcDebugMode:
            let toggled = !Current.userDefaults.bool(forDefaultsKey: .lpcDebugMode)
            Current.userDefaults.set(toggled, forDefaultsKey: .lpcDebugMode)
            tableView.reloadData()
        case .responseCodeVisualiser:
            let shouldShow = Current.userDefaults.bool(forDefaultsKey: .responseCodeVisualiser)
            Current.userDefaults.set(!shouldShow, forDefaultsKey: .responseCodeVisualiser)
            tableView.reloadData()
        case .inAppReviewRules:
            let shouldApply = Current.userDefaults.bool(forDefaultsKey: .applyInAppReviewRules)
            Current.userDefaults.set(!shouldApply, forDefaultsKey: .applyInAppReviewRules)
            tableView.reloadData()
        case .customBundleClientLogin:
            let customRules = Current.userDefaults.bool(forDefaultsKey: .allowCustomBundleClientOnLogin)
            Current.userDefaults.set(!customRules, forDefaultsKey: .allowCustomBundleClientOnLogin)
            tableView.reloadData()
        default:
            return
        }
    }
}
