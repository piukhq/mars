//
//  LoyaltyWalletViewController.swift
//  binkapp
//
//  Copyright (c) 2019 Bink. All rights reserved.
//

import UIKit
import Keys

protocol LoyaltyWalletDisplayLogic: class {
    func displaySomething(viewModel: LoyaltyWallet.Something.ViewModel)
}

class LoyaltyWalletViewController: UIViewController, LoyaltyWalletDisplayLogic {
    @IBOutlet weak var tableView: UITableView!
    
    var interactor: LoyaltyWalletBusinessLogic?
    var router: (NSObjectProtocol & LoyaltyWalletRoutingLogic & LoyaltyWalletDataPassing)?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        let viewController = self
        let interactor = LoyaltyWalletInteractor()
        let presenter = LoyaltyWalletPresenter()
        let router = LoyaltyWalletRouter()
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let scene = segue.identifier {
            let selector = NSSelectorFromString("routeTo\(scene)WithSegue:")
            if let router = router, router.responds(to: selector) {
                router.perform(selector, with: segue)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "CardTableViewCell", bundle: Bundle(for: CardTableViewCell.self)), forCellReuseIdentifier: "CardTableViewCell")
        
        doSomething()
    }
    
    func doSomething() {
        let request = LoyaltyWallet.Something.Request()
        interactor?.doSomething(request: request)
    }
    
    func displaySomething(viewModel: LoyaltyWallet.Something.ViewModel) {
        
    }
}

extension LoyaltyWalletViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CardTableViewCell", for: indexPath) as? CardTableViewCell else { return UITableViewCell() }
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "Delete", handler: { _,_,_  in })
        let configuration = UISwipeActionsConfiguration(actions: [action])
        return configuration
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "Delete", handler: { _,_,_  in })
        let configuration = UISwipeActionsConfiguration(actions: [action])
        return configuration
    }
}
