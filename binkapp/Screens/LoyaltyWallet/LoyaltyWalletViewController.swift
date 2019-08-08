//
//  LoyaltyWalletViewController.swift
//  binkapp
//
//  Copyright (c) 2019 Bink. All rights reserved.
//

import UIKit
import CoreGraphics

class LoyaltyWalletViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    let viewModel: LoyaltyWalletViewModel
    
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
        
        viewModel.getMembershipCards()
    }
}

extension LoyaltyWalletViewController: UITableViewDelegate, UITableViewDataSource {
    //TO DO: ADD GRADIENT COLOR TO SWIPE ACTION
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.items.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WalletLoyaltyCardTableViewCell", for: indexPath) as! WalletLoyaltyCardTableViewCell
        cell.selectionStyle = .none
        cell.layer.cornerRadius = 8
        cell.layer.masksToBounds = true
        return cell
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "barcode_swipe_title".localized, handler: { _,_,_  in })
        
        action.image = UIImage(named: "swipeBarcode")
        action.backgroundColor = UIColor(red: 99/255, green: 159/255, blue: 255/255, alpha: 1)
        let configuration = UISwipeActionsConfiguration(actions: [action])
        return configuration
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .normal, title: "delete_swipe_title".localized) { _, _, completion in
            let section = indexPath.section
            self.viewModel.showDeleteConfirmationAlert(section: section) {
                tableView.deleteSections(IndexSet(arrayLiteral: section), with: .automatic)
                tableView.reloadData()
            }
        }
        
        action.image = UIImage(named: "trashIcon")
        action.backgroundColor = UIColor.red
        let configuration = UISwipeActionsConfiguration(actions: [action])
        
        return configuration
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 12
    }
}
