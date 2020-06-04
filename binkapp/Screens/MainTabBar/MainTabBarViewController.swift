//
//  MainTabBarViewController.swift
//  binkapp
//
//  Copyright (c) 2019 Bink. All rights reserved.
//

import UIKit

extension LayoutHelper {
    struct settingsButton {
        static let widthRatio: CGFloat = 0.13
        static let height: CGFloat = 24
    }
}

class MainTabBarViewController: UITabBarController, BarBlurring {
    let viewModel: MainTabBarViewModel
    var selectedTabBarOption = Buttons.loyaltyItem.rawValue
    var items = [UITabBarItem]()
    lazy var blurBackground = defaultBlurredBackground()
    
    init(viewModel: MainTabBarViewModel) {
        self.viewModel = viewModel
        super.init(nibName: "MainTabBarViewController", bundle: Bundle(for: MainTabBarViewController.self))
        delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        Current.wallet.launch()

        setupNotifications()
        
        self.title = ""
        populateTabBar()
    }

    // MARK: - Navigation Bar Blurring
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        prepareBarWithBlur(bar: tabBar, blurBackground: blurBackground)
    }
    
    func populateTabBar() {
        viewControllers = viewModel.childViewControllers
    }
}

extension MainTabBarViewController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController is AddingOptionsTabBarViewController {
            viewModel.toAddingOptionsScreen()
            return false
        }
        
        return true
    }
}

// MARK: - Notifications and Handlers

extension MainTabBarViewController {
    private func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleDidAddPaymentCard), name: .didAddPaymentCard, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleDidAddMembershipCard), name: .didAddMembershipCard, object: nil)
    }

    @objc private func handleDidAddPaymentCard() {
        selectedIndex = 2
    }

    @objc private func handleDidAddMembershipCard() {
        selectedIndex = 0
    }
}
