//
//  LoyaltyWalletViewController.swift
//  binkapp
//
//  Copyright (c) 2019 Bink. All rights reserved.
//

import UIKit
import CoreGraphics

class LoyaltyWalletViewController: UIViewController{
    @IBOutlet private weak var tableView: UITableView!
    private let viewModel: LoyaltyWalletViewModel
    
    init(viewModel: LoyaltyWalletViewModel) {
        self.viewModel = viewModel
        super.init(nibName: "LoyaltyWalletViewController", bundle: Bundle(for: LoyaltyWalletViewController.self))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "WalletLoyaltyCardTableViewCell", bundle: Bundle(for: WalletLoyaltyCardTableViewCell.self)), forCellReuseIdentifier: "WalletLoyaltyCardTableViewCell")
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshScreen(notification:)), name: .didDeleteMemebershipCard, object: nil)
    }
}

// MARK: - Private methods
private extension LoyaltyWalletViewController {
    @objc func refreshScreen(notification: Notification) {
        viewModel.refreshScreen()
    }
}

// MARK: - Table view delegate and data source

extension LoyaltyWalletViewController: UITableViewDelegate, UITableViewDataSource {
    //TO DO: ADD GRADIENT COLOR TO SWIPE ACTION
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.membershipCardsCount
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        let membershipPlan = viewModel.getMembershipCards()[section].membershipPlan

        let cell = tableView.dequeueReusableCell(withIdentifier: "WalletLoyaltyCardTableViewCell", for: indexPath) as! WalletLoyaltyCardTableViewCell
        if let cardPlan = viewModel.getMembershipPlans().first(where: {($0.id == membershipPlan)}) {
            cell.configureUIWithMembershipCard(card: viewModel.getMembershipCards()[section], andMemebershipPlan: cardPlan)
        }
        
        cell.layer.cornerRadius = 8
        cell.separatorInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        cell.layer.shadowOffset = CGSize(width: 0, height: 5)
        cell.layer.shadowRadius = 5
        cell.layer.shadowColor = UIColor.red.cgColor
        cell.layer.shadowOpacity = 0.9
        cell.layer.masksToBounds = true
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "barcode_swipe_title".localized, handler: { [weak self] _,_,_  in
            guard let wself = self else { return }
            wself.viewModel.toBarcodeViewController(section: indexPath.section)
            wself.tableView.reloadData()
        })
        
        action.image = UIImage(named: "swipeBarcode")
        action.backgroundColor = UIColor(red: 99/255, green: 159/255, blue: 255/255, alpha: 1)
        let configuration = UISwipeActionsConfiguration(actions: [action])
        return configuration
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .normal, title: "delete_swipe_title".localized) { _, _, completion in
            self.viewModel.showDeleteConfirmationAlert(index: indexPath.row, yesCompletion: {
                tableView.deleteRows(at: [indexPath], with: .automatic)
                tableView.reloadData()
            }, noCompletion: {
                tableView.setEditing(false, animated: true)
            })
        }
        
        action.image = UIImage(named: "trashIcon")
        action.backgroundColor = UIColor.red
        let configuration = UISwipeActionsConfiguration(actions: [action])
        
        return configuration
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 12
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.toFullDetailsCardScreen(membershipCard: viewModel.getMembershipCards()[indexPath.section], membershipPlan: viewModel.getMembershipPlans()[indexPath.section])
    }
}

// MARK: - View model delegate

extension LoyaltyWalletViewController: LoyaltyWalletViewModelDelegate {
    func didFetchMembershipPlans() {
        tableView.reloadData()
    }
    
    func didFetchCards() {
        tableView.reloadData()
    }
}
