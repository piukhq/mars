//
//  FeatureFlagsTableViewController.swift
//  binkapp
//
//  Created by Sean Williams on 15/02/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import UIKit

class FeatureFlagsViewModel {
    let features = Current.featureManager.features
    
    var title: String {
        return "Feature Flags"
    }
    
    var cellHeight: CGFloat {
        return 60
    }
}

protocol FeatureFlagsViewControllerDelegate: AnyObject {
    func featureFlagsViewControllerDidDismiss(_ featureFlagsViewController: FeatureFlagsTableViewController)
}

class FeatureFlagsTableViewController: BinkTableViewController {
    // MARK: - Properties

    private let viewModel: FeatureFlagsViewModel
    private weak var delegate: FeatureFlagsViewControllerDelegate?
    
    
    // MARK: - View Lifecycle

    init(viewModel: FeatureFlagsViewModel, delegate: FeatureFlagsViewControllerDelegate?) {
        self.viewModel = viewModel
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = viewModel.title
        tableView.register(FeatureFlagsTableViewCell.self, asNib: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        delegate?.featureFlagsViewControllerDidDismiss(self)
    }
    
    override func configureForCurrentTheme() {
        super.configureForCurrentTheme()
        view.backgroundColor = Current.themeManager.color(for: .viewBackground)
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.features?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: FeatureFlagsTableViewCell = tableView.dequeue(indexPath: indexPath)
        let feature = viewModel.features?[indexPath.row]
        cell.configure(feature, delegate: self)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return viewModel.cellHeight
    }
    
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}

extension FeatureFlagsTableViewController: FeatureFlagCellDelegate {
    func featureWasToggled(_ feature: Feature?) {
        switch feature?.type {
        case .themes:
            tableView.reloadData()
        default:
            break
        }
    }
}
