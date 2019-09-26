//
//  MainTabBarViewController.swift
//  binkapp
//
//  Copyright (c) 2019 Bink. All rights reserved.
//

import UIKit

class MainTabBarViewController: UIViewController {
    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var displayedControllerView: UIView!
    
    let viewModel: MainTabBarViewModel
    var selectedTabBarOption = Buttons.loyaltyItem.rawValue
    var items = [UITabBarItem]()
    
    init(viewModel: MainTabBarViewModel) {
        self.viewModel = viewModel
        super.init(nibName: "MainTabBarViewController", bundle: Bundle(for: MainTabBarViewController.self))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = ""
        setNavigationBar()
        
        tabBar.delegate = self
        populateTabBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setFirstDisplayedController()
    }
    
    func setNavigationBar() {
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.shadowImage = UIImage()

        let settingsButton = UIBarButtonItem(image: UIImage(named: "settings")?.withRenderingMode(.alwaysOriginal), style: .done, target: self, action: #selector(settingsButtonTapped))
        navigationItem.rightBarButtonItem = settingsButton

        navigationItem.setHidesBackButton(true, animated: true)
        self.title = ""
    }
    
    @objc func settingsButtonTapped() {
        #if DEBUG
        viewModel.toDebugMenu()
        #else
        viewModel.toSettingsScreen()
        #endif
    }
    
    func populateTabBar() {
        items.append(viewModel.getTabBarLoyaltyButton())
        items.append(viewModel.getTabBarAddButton())
        items.append(viewModel.getTabBarPaymentButton())
        tabBar.setItems(items, animated: true)
    }
    
    func setFirstDisplayedController() {
        let view = viewModel.childViewControllers[Buttons.loyaltyItem.rawValue].view
        view?.frame = displayedControllerView.bounds
        displayedControllerView.addSubview(view!)
        tabBar.selectedItem = items[Buttons.loyaltyItem.rawValue]
    }
}

extension MainTabBarViewController: UITabBarDelegate {
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        viewModel.childViewControllers[selectedTabBarOption].view.removeFromSuperview()
        switch item.tag {
        case Buttons.loyaltyItem.rawValue:
            let view = viewModel.childViewControllers[Buttons.loyaltyItem.rawValue].view
            view?.frame = displayedControllerView.bounds
            displayedControllerView.addSubview(view!)
            selectedTabBarOption = Buttons.loyaltyItem.rawValue
            break
        case Buttons.addItem.rawValue:
            viewModel.toAddingOptionsScreen()
            break
        case Buttons.paymentItem.rawValue:
            let view = viewModel.childViewControllers[Buttons.paymentItem.rawValue].view
            view?.frame = displayedControllerView.bounds
            displayedControllerView.addSubview(view!)
            selectedTabBarOption = Buttons.paymentItem.rawValue
            break
        default: break
        }
    }
}

