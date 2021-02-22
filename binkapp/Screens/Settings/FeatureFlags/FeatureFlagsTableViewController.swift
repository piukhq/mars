//
//  FeatureFlagsTableViewController.swift
//  binkapp
//
//  Created by Sean Williams on 15/02/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import UIKit

class FeatureFlagsTableViewController: UITableViewController {
    private let viewModel: FeatureFlagsViewModel
    
    init(viewModel: FeatureFlagsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(FeatureFlagsTableViewCell.self, asNib: true)
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.features?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: FeatureFlagsTableViewCell = tableView.dequeue(indexPath: indexPath)
        let feature = viewModel.features?[indexPath.row]
        cell.configure(feature)
        return cell
    }
}
