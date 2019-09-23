//
//  PaymentWalletViewController.swift
//  binkapp
//
//  Created by Paul Tiriteu on 23/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class PaymentWalletViewController: UITableViewController {
    private let viewModel: PaymentWalletViewModel
    
    init(viewModel: PaymentWalletViewModel) {
        self.viewModel = viewModel
        super.init(style: .plain)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.delegate = self
        viewModel.getPaymentCards()
        
        tableView.registerCellForClass(PaymentCardTableViewCell.self, asNib: true)
        tableView.separatorColor = .clear
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.paymentCards.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}

extension PaymentWalletViewController: PaymentWalletViewModelDelegate {
    func paymentWalletViewModelDidLoadData(_ viewModel: PaymentWalletViewModel) {
        tableView.reloadData()
    }
}
