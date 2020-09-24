//
//  TransactionsViewController.swift
//  binkapp
//
//  Created by Paul Tiriteu on 12/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class TransactionsViewController: BinkTrackableViewController {
    private struct Constants {
        static let horizontalInset: CGFloat = 25.0
        static let bottomInset: CGFloat = 25.0
    }
    
    lazy var titleLabel: UILabel = {
        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.font = UIFont.headline
        title.text = viewModel.title
        return title
    }()
    
    lazy var descriptionLabel: UILabel = {
        let description = UILabel()
        description.translatesAutoresizingMaskIntoConstraints = false
        description.font = UIFont.bodyTextLarge
        description.text = viewModel.description
        description.numberOfLines = 0
        return description
    }()
    
    lazy var brandHeaderView: BrandHeaderView = {
        let brandHeader = BrandHeaderView()
        brandHeader.configure(plan: viewModel.membershipCard.membershipPlan, delegate: self)
        return brandHeader
    }()
    
    lazy var stackScrollView: StackScrollView = {
        let stackView = StackScrollView(axis: .vertical, arrangedSubviews: [titleLabel, descriptionLabel], adjustForKeyboard: true)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = .white
        stackView.margin = UIEdgeInsets(top: 0, left: Constants.horizontalInset, bottom: 0, right: Constants.horizontalInset)
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: Constants.bottomInset, right: 0)
        view.addSubview(stackView)
        return stackView
    }()
    
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
    }
    
    private func configureUI() {
        NSLayoutConstraint.activate([
            stackScrollView.topAnchor.constraint(equalTo: view.topAnchor),
            stackScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stackScrollView.leftAnchor.constraint(equalTo: view.leftAnchor),
            stackScrollView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
        stackScrollView.add(arrangedSubviews: [brandHeaderView, titleLabel, descriptionLabel])
        stackScrollView.customPadding(25, after: brandHeaderView)
        
        viewModel.transactions.forEach { transaction in
            let transactionView = TransactionView()
            transactionView.configure(with: transaction)
            stackScrollView.add(arrangedSubview: transactionView)
        }
        
        guard let lastTransactionView = stackScrollView.arrangedSubviews.last as? TransactionView else {
            return
        }
        lastTransactionView.hideSeparatorView()
    }
}

extension TransactionsViewController: LoyaltyButtonDelegate {
    func brandHeaderViewWasTapped(_ brandHeaderView: BrandHeaderView) {
        viewModel.brandHeaderWasTapped()
    }
}
