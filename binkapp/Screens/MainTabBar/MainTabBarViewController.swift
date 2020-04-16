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
        setNavigationBar()
        populateTabBar()
    }

    // MARK: - Navigation Bar Blurring
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        prepareBarWithBlur(bar: tabBar, blurBackground: blurBackground)
    }
    
    func setNavigationBar() {
        let settingsButton = UIButton(type: .custom)
        settingsButton.setImage(UIImage(named: "settings"), for: .normal)
        settingsButton.addTarget(self, action: #selector(settingsButtonTapped), for: .touchUpInside)
        settingsButton.contentMode = .right
        
        var rightInset: CGFloat = 0
        
        switch UIDevice.current.width {
            case .iPhone5Size:
                rightInset = 9
            case .iPhone6Size:
                rightInset = 9
            case .iPhonePlusSize:
                rightInset = 6
            default:
                rightInset = 7
        }
        
        settingsButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: rightInset)
        
        let barButton = UIBarButtonItem(customView: settingsButton)
        navigationItem.rightBarButtonItem = barButton
        
        navigationItem.setHidesBackButton(true, animated: true)
        self.title = ""
    }
    
    @objc func settingsButtonTapped() {
        viewModel.toSettings()
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
