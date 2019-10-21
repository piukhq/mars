//
//  TransactionsViewController.swift
//  binkapp
//
//  Created by Paul Tiriteu on 12/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class TransactionsViewController: UIViewController {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var lastCheckedLabel: UILabel!
    @IBOutlet private weak var brandHeaderView: BrandHeaderView!
    @IBOutlet private weak var tableView: UITableView!
    
    private let viewModel: TransactionsViewModel
    
    init(viewModel: TransactionsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: "TransactionsViewController", bundle: Bundle(for: TransactionsViewController.self))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        tableView.dataSource = self
        tableView.register(TransactionTableViewCell.self, asNib: true)
    }
    
    private func configureUI() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "navbarIconsBack"), style: .plain, target: self, action: #selector(popViewController))
        titleLabel.font = .headline
        lastCheckedLabel.font = .bodyTextLarge
        descriptionLabel.font = .bodyTextLarge

        titleLabel.text = viewModel.title
        descriptionLabel.text = viewModel.description
        
        if !viewModel.transactions.isEmpty {
            let imageUrl = viewModel.membershipCard.membershipPlan?.firstIconImage()?.url
            brandHeaderView.configure(imageURLString: imageUrl, loyaltyPlanNameCard: (viewModel.membershipCard.membershipPlan?.account?.planNameCard ?? nil), delegate: self)
        } else {
            lastCheckedLabel.text = viewModel.lastCheckedString ?? ""
        }

        lastCheckedLabel.isHidden = !viewModel.transactions.isEmpty
        brandHeaderView.isHidden = viewModel.transactions.isEmpty
        tableView.isHidden = viewModel.transactions.isEmpty
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1))
    }
    
    @objc private func popViewController() {
        viewModel.popViewController()
    }
}

extension TransactionsViewController: LoyaltyButtonDelegate {
    func brandHeaderViewWasTapped(_ brandHeaderView: BrandHeaderView) {
        viewModel.displayLoyaltySchemePopup()
    }
}

extension TransactionsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.transactions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: TransactionTableViewCell = tableView.dequeue(indexPath: indexPath)
        
        let transaction = viewModel.transactions[indexPath.row]
        
        let value = transaction.formattedAmounts?.first?.value?.intValue ?? 0
        
        let suffix = transaction.formattedAmounts?.first?.suffix != "" ? transaction.formattedAmounts?.first?.currency : nil
        
        cell.configure(transactionValue: value, timestamp: transaction.timestamp?.doubleValue ?? 0.0, prefix: transaction.formattedAmounts?.first?.prefix, suffix: suffix)
        
        return cell
    }
}
