//
//  LoyaltyWalletViewController.swift
//  binkapp
//
//  Copyright (c) 2019 Bink. All rights reserved.
//

import UIKit
import CoreGraphics

class LoyaltyWalletViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    private let viewModel: LoyaltyWalletViewModel
    private let refreshControl = UIRefreshControl()
    
    init(viewModel: LoyaltyWalletViewModel) {
        self.viewModel = viewModel
        super.init(nibName: "LoyaltyWalletViewController", bundle: Bundle(for: LoyaltyWalletViewController.self))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "WalletLoyaltyCardTableViewCell", bundle: Bundle(for: WalletLoyaltyCardTableViewCell.self)), forCellReuseIdentifier: "WalletLoyaltyCardTableViewCell")
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadMembershipCards), name: .didDeleteMemebershipCard, object: nil)
        
        refreshControl.addTarget(self, action: #selector(loadMembershipCards), for: .valueChanged)
        tableView.addSubview(refreshControl)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        refreshControl.endRefreshing()
        tableView.contentOffset = .zero
        super.viewWillDisappear(true)
    }

    @objc private func loadMembershipCards() {
        viewModel.getMembershipCards(forceRefresh: true) { [weak self] in
            DispatchQueue.main.async {
                self?.refreshControl.endRefreshing()
                self?.tableView.reloadData()
            }
        }
    }
}

extension LoyaltyWalletViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.membershipCardsCount
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithClass(WalletLoyaltyCardTableViewCell.self, forIndexPath: indexPath)

        // this seems to return a fault object, with nil properties
        guard let membershipCard = viewModel.membershipCard(forIndexPath: indexPath) else {
            return cell
        }

        // configure cell

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 12
    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let card = viewModel.membershipCard(forIndexPathSection: indexPath.section)
//        if let membershipPlan = viewModel.membershipPlanForCard(card: card) {
//            viewModel.toFullDetailsCardScreen(membershipCard: card, membershipPlan: membershipPlan)
//        }
//    }
}
