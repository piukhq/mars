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
    var selectedTabBarOption = 0
    
    init(viewModel: MainTabBarViewModel) {
        self.viewModel = viewModel
        super.init(nibName: "MainTabBarViewController", bundle: Bundle(for: MainTabBarViewController.self))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        tabBar.delegate = self
        populateTabBar()
    }
    
    func populateTabBar() {
        var items = [UITabBarItem]()
        
        items.append(viewModel.getTabBarLoyaltyButton())
        items.append(viewModel.getTabBarAddButton())
        items.append(viewModel.getTabBarPaymentButton())
        items[2].isEnabled = false
        tabBar.setItems(items, animated: true)
    
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
            let view = viewModel.childViewControllers[Buttons.addItem.getIntegerValue()].view
            view?.frame = displayedControllerView.frame
            displayedControllerView.addSubview(view!)
            selectedTabBarOption = Buttons.addItem.getIntegerValue()
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

