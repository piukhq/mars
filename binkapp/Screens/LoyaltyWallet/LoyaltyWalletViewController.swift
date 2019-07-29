//
//  LoyaltyWalletViewController.swift
//  binkapp
//
//  Copyright (c) 2019 Bink. All rights reserved.
//

import UIKit

class LoyaltyWalletViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var items = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    
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
        tableView.register(UINib(nibName: "CardTableViewCell", bundle: Bundle(for: CardTableViewCell.self)), forCellReuseIdentifier: "CardTableViewCell")
    }
}

extension LoyaltyWalletViewController: UITableViewDelegate, UITableViewDataSource {
    //TO DO: ADD GRADIENT COLOR TO SWIPE ACTION
    
    // TRIED A THIRD PARTY LIBRARY AND GONNA LEAVE THIS CODE HERE FOR FUTURE IMLPEMENTATION
//    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
//        if orientation == .right {
//            let deleteAction = SwipeAction(style: .default, title: "Delete") { action, indexPath in
//                // handle action by updating model with deletion
//                print(action)
//            }
//
//            // customize the action appearance
//            deleteAction.image = UIImage(named: "icons8FilledTrash")
//            return [deleteAction]
//        } else if orientation == .left {
//            let barCodeAction = SwipeAction(style: .default, title: "Barcode") { action, indexPath in
//                print("barcode")
//            }
//
//            barCodeAction.image = UIImage(named: "icons8Barcode")
//            return [barCodeAction]
//        } else { return nil }
//    }
    
//    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
//        var options = SwipeOptions()
//        options.expansionStyle = .destructive
//        options.transitionStyle = .border
//        return options
//    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CardTableViewCell", for: indexPath) as! CardTableViewCell
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: nil, handler: { _,_,_  in })
        action.image = UIImage(named: "iconSwipeBarcode")
        action.backgroundColor = UIColor(red: 99/255, green: 159/255, blue: 255/255, alpha: 1)
        let configuration = UISwipeActionsConfiguration(actions: [action])
        return configuration
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: nil, handler: { _,_,_  in })
        action.image = UIImage(named: "iconSwipeDelete")
        let configuration = UISwipeActionsConfiguration(actions: [action])
        return configuration
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 12
    }
}
