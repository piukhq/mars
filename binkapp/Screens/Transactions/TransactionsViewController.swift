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
    
    func configureUI() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "navbarIconsBack")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(popViewController))
        
        titleLabel.text = "transaction_history_unavailable_title".localized
        titleLabel.font = .headline
        
        lastCheckedLabel.text = viewModel.getLastCheckedString()
        lastCheckedLabel.font = .bodyTextLarge
        
        descriptionLabel.text = "transaction_history_unavailable_description".localized
        descriptionLabel.font = .bodyTextLarge
    }
    
    @objc func popViewController() {
        viewModel.popViewController()
    }
}
