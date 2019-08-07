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
    var selectedTabBarOption = Buttons.loyaltyItem.getIntegerValue()
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
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationItem.setHidesBackButton(true, animated: true)
        self.navigationItem.rightBarButtonItem = navigationController?.navigationItem.rightBarButtonItem
        
        tabBar.delegate = self
        populateTabBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setFirstDisplayedController()
    }
    
    func populateTabBar() {
        items.append(viewModel.getTabBarLoyaltyButton())
        items.append(viewModel.getTabBarAddButton())
        items.append(viewModel.getTabBarPaymentButton())
        items[Buttons.paymentItem.getIntegerValue()].isEnabled = false
        tabBar.setItems(items, animated: true)
    }
    
    func setFirstDisplayedController() {
        let view = viewModel.childViewControllers[Buttons.loyaltyItem.getIntegerValue()].view
        view?.frame = displayedControllerView.frame
        displayedControllerView.addSubview(view!)
        tabBar.selectedItem = items[Buttons.loyaltyItem.getIntegerValue()]
    }
}

extension MainTabBarViewController: UITabBarDelegate {
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        viewModel.childViewControllers[selectedTabBarOption].view.removeFromSuperview()
        switch item.tag {
        case Buttons.loyaltyItem.getIntegerValue():
            let view = viewModel.childViewControllers[Buttons.loyaltyItem.getIntegerValue()].view
            view?.frame = displayedControllerView.frame
            displayedControllerView.addSubview(view!)
            selectedTabBarOption = Buttons.loyaltyItem.getIntegerValue()
            break
        case Buttons.addItem.getIntegerValue():
//            let view = viewModel.childViewControllers[Buttons.addItem.getIntegerValue()].view
//            view?.frame = displayedControllerView.frame
//            displayedControllerView.addSubview(view!)
//            selectedTabBarOption = Buttons.addItem.getIntegerValue()
            viewModel.toAddingOptionsScreen()
            break
        case Buttons.paymentItem.getIntegerValue():
            let view = viewModel.childViewControllers[Buttons.paymentItem.getIntegerValue()].view
            view?.frame = displayedControllerView.frame
            displayedControllerView.addSubview(view!)
            selectedTabBarOption = Buttons.paymentItem.getIntegerValue()
            break
        default: break
        }
    }
}

