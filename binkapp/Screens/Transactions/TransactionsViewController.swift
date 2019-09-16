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
        tableView.registerCellForClass(TransactionTableViewCell.self, asNib: true)
    }
    
    private func configureUI() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "navbarIconsBack")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(popViewController))
        titleLabel.font = .headline
        lastCheckedLabel.font = .bodyTextLarge
        descriptionLabel.font = .bodyTextLarge

        guard let transactions = viewModel.membershipCard.membershipTransactions else { return }
        
        if !transactions.isEmpty {
            titleLabel.text = "points_history_title".localized
            descriptionLabel.text = "recent_transaction_history_subtitle".localized
            let imageUrl = viewModel.membershipPlan.images?.first(where: { $0.type == ImageType.icon.rawValue })?.url
            brandHeaderView.configure(imageURLString: imageUrl, loyaltyPlanNameCard: (viewModel.membershipPlan.account?.planNameCard ?? nil), delegate: self)
        } else {
            titleLabel.text = "transaction_history_unavailable_title".localized
            lastCheckedLabel.text = viewModel.getLastCheckedString() ?? ""
            descriptionLabel.text = "transaction_history_unavailable_description".localized
        }

        lastCheckedLabel.isHidden = !transactions.isEmpty
        brandHeaderView.isHidden = transactions.isEmpty
        tableView.isHidden = transactions.isEmpty
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1))
    }
    
    @objc private func popViewController() {
        viewModel.popViewController()
    }
}

extension TransactionsViewController: LoyaltyButtonDelegate {
    func brandHeaderViewDidTap(_ brandHeaderView: BrandHeaderView) {
        viewModel.displayLoyaltySchemePopup()
    }
}

extension TransactionsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.transactions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithClass(TransactionTableViewCell.self, forIndexPath: indexPath)
        
        let transaction = viewModel.transactions[indexPath.row]
        let value = Int(transaction.amounts?.first?.value ?? 0)
        cell.configure(transactionValue: value, timestamp: transaction.timestamp ?? 0, prefix: transaction.amounts?.first?.prefix, suffix: transaction.amounts?.first?.suffix)
        
        return cell
    }
}
