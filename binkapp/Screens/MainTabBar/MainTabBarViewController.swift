//
//  MainTabBarViewController.swift
//  binkapp
//
//  Copyright (c) 2019 Bink. All rights reserved.
//

import UIKit

extension LayoutHelper {
    enum SettingsButton {
        static let widthRatio: CGFloat = 0.13
        static let height: CGFloat = 24
    }
}

class MainTabBarViewController: UITabBarController {
    let viewModel: MainTabBarViewModel
    var selectedTabBarOption = Buttons.loyaltyItem.rawValue
    var items: [UITabBarItem] = []
    
    init(viewModel: MainTabBarViewModel) {
        self.viewModel = viewModel
        super.init(nibName: "MainTabBarViewController", bundle: Bundle(for: MainTabBarViewController.self))
        delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        Current.wallet.launch()
        populateTabBar()

        configureForCurrentTheme()
        Current.themeManager.addObserver(self, handler: #selector(configureForCurrentTheme))
    }
    
    func populateTabBar() {
        viewControllers = viewModel.viewControllers
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        configureForCurrentTheme()
    }

    @objc func configureForCurrentTheme() {
        tabBar.standardAppearance = Current.themeManager.tabBarAppearance(for: traitCollection)
        tabBar.scrollEdgeAppearance = Current.themeManager.tabBarAppearance(for: traitCollection)
        tabBar.tintColor = Current.themeManager.color(for: .text)
        tabBar.setNeedsLayout()
    }
}

extension MainTabBarViewController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController is BrowseBrandsViewController {
            viewModel.toBrowseBrandsScreen()
            return false
        }
        
        return true
    }
}

extension MainTabBarViewController: BinkScannerViewControllerDelegate {
    func binkScannerViewController(_ viewController: BinkScannerViewController, didScanBarcode barcode: String, forMembershipPlan membershipPlan: CD_MembershipPlan?, completion: (() -> Void)?) {
        guard let membershipPlan = membershipPlan else { return }
        let prefilledBarcodeValue = FormDataSource.PrefilledValue(commonName: .barcode, value: barcode)
        let viewController = ViewControllerFactory.makeAuthAndAddViewController(membershipPlan: membershipPlan, formPurpose: .addFromScanner, prefilledFormValues: [prefilledBarcodeValue])
        let navigationRequest = PushNavigationRequest(viewController: viewController, hidesBackButton: true)
        Current.navigate.to(navigationRequest)
    }
    
    func binkScannerViewControllerShouldEnterManually(_ viewController: BinkScannerViewController, completion: (() -> Void)?) {
        if viewController.viewModel.type == .payment {
            if let vc = viewController.navigationController?.presentingViewController {
                if vc.isKind(of: PortraitNavigationController.self) {
                    completion?()
                    return
                }
            }

            let addpaymentCardViewController = ViewControllerFactory.makeAddPaymentCardViewController(journey: .wallet)
            let navigationRequest = PushNavigationRequest(viewController: addpaymentCardViewController, hidesBackButton: true)
            Current.navigate.to(navigationRequest)
        } else {
            Current.navigate.close {
                let viewController = ViewControllerFactory.makeBrowseBrandsViewController()
                let navigationRequest = ModalNavigationRequest(viewController: viewController)
                Current.navigate.to(navigationRequest)
            }
        }
    }
    
    func binkScannerViewController(_ viewController: BinkScannerViewController, didScan paymentCard: PaymentCardCreateModel) {
        let viewController = ViewControllerFactory.makeAddPaymentCardViewController(model: paymentCard, journey: .wallet)
        let navigationRequest = PushNavigationRequest(viewController: viewController, hidesBackButton: true)
        Current.navigate.to(navigationRequest)
    }
}
