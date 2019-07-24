//
//  MainTabBarViewController.swift
//  binkapp
//
//  Copyright (c) 2019 Bink. All rights reserved.
//

import UIKit

protocol MainTabBarDisplayLogic: class
{
    func populateTabBar(viewModel: MainTabBar.TabBarModels.ViewModel)
}

class MainTabBarViewController: UIViewController, MainTabBarDisplayLogic
{
    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var displayedControllerView: UIView!
    
    var interactor: MainTabBarBusinessLogic?
    var router: (NSObjectProtocol & MainTabBarRoutingLogic & MainTabBarDataPassing)?
    
    var childrenViewControllers: [UIViewController] = []
    var selectedTabBarOption = 0
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?)
    {
        super.init(nibName: "MainTabBarViewController", bundle: Bundle(for: MainTabBarViewController.self))
        setup()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup()
    {
        let viewController = self
        let interactor = MainTabBarInteractor()
        let presenter = MainTabBarPresenter()
        let router = MainTabBarRouter()
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if let scene = segue.identifier {
            let selector = NSSelectorFromString("routeTo\(scene)WithSegue:")
            if let router = router, router.responds(to: selector) {
                router.perform(selector, with: segue)
            }
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        self.navigationController?.setNavigationBarHidden(true, animated: true)
        tabBar.delegate = self
        
        addButtonsToTabBar()
    }
    
    func addButtonsToTabBar()
    {
        interactor?.populateTabBar()
    }
    
    func populateTabBar(viewModel: MainTabBar.TabBarModels.ViewModel)
    {
        var items = [UITabBarItem]()
        
        items.append(viewModel.getTabBarLoyaltyButton())
        items.append(viewModel.getTabBarAddButton())
        items.append(viewModel.getTabBarPaymentButton())
        items[2].isEnabled = false
        tabBar.setItems(items, animated: true)
        
        childrenViewControllers = viewModel.childViewControllers
        
        displayedControllerView.addSubview(childrenViewControllers[MainTabBar.Buttons.loyaltyItem.getIntegerValue()].view)
        tabBar.selectedItem = items[MainTabBar.Buttons.loyaltyItem.getIntegerValue()]
    }
}

extension MainTabBarViewController: UITabBarDelegate {
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        childrenViewControllers[selectedTabBarOption].view.removeFromSuperview()
        switch item.tag {
        case MainTabBar.Buttons.loyaltyItem.getIntegerValue(): displayedControllerView.addSubview(childrenViewControllers[MainTabBar.Buttons.loyaltyItem.getIntegerValue()].view)
            selectedTabBarOption = MainTabBar.Buttons.loyaltyItem.getIntegerValue()
            break
        case MainTabBar.Buttons.addItem.getIntegerValue(): displayedControllerView.addSubview(childrenViewControllers[MainTabBar.Buttons.addItem.getIntegerValue()].view)
            selectedTabBarOption = MainTabBar.Buttons.addItem.getIntegerValue()
            break
        case MainTabBar.Buttons.paymentItem.getIntegerValue(): displayedControllerView.addSubview(childrenViewControllers[MainTabBar.Buttons.paymentItem.getIntegerValue()].view)
            selectedTabBarOption = MainTabBar.Buttons.paymentItem.getIntegerValue()
            break
        default: break
        }
    }
}

