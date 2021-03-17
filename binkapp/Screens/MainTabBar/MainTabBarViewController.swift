//
//  MainTabBarViewController.swift
//  binkapp
//
//  Copyright (c) 2019 Bink. All rights reserved.
//

import UIKit
import CardScan

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
        Current.themeManager.removeObserver(self)
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

extension MainTabBarViewController: BarcodeScannerViewControllerDelegate, ScanDelegate {
    func barcodeScannerViewController(_ viewController: BarcodeScannerViewController, didScanBarcode barcode: String, forMembershipPlan membershipPlan: CD_MembershipPlan, completion: (() -> Void)?) {
        let prefilledBarcodeValue = FormDataSource.PrefilledValue(commonName: .barcode, value: barcode)
        let viewController = ViewControllerFactory.makeAuthAndAddViewController(membershipPlan: membershipPlan, formPurpose: .addFromScanner, prefilledFormValues: [prefilledBarcodeValue])
        let navigationRequest = PushNavigationRequest(viewController: viewController, hidesBackButton: true)
        Current.navigate.to(navigationRequest)
    }
    
    func barcodeScannerViewControllerShouldEnterManually(_ viewController: BarcodeScannerViewController, completion: (() -> Void)?) {
        Current.navigate.close {
            let viewController = ViewControllerFactory.makeBrowseBrandsViewController()
            let navigationRequest = ModalNavigationRequest(viewController: viewController)
            Current.navigate.to(navigationRequest)
        }
    }
    
    func userDidCancel(_ scanViewController: ScanViewController) {
        Current.navigate.close()
    }
    
    func userDidScanCard(_ scanViewController: ScanViewController, creditCard: CreditCard) {
        if #available(iOS 14.0, *) {
            BinkLogger.infoPrivateHash(event: AppLoggerEvent.paymentCardScanned, value: creditCard.number)
        }
        BinkAnalytics.track(GenericAnalyticsEvent.paymentScan(success: true))
        let month = creditCard.expiryMonthInteger()
        let year = creditCard.expiryYearInteger()
        let model = PaymentCardCreateModel(fullPan: creditCard.number, nameOnCard: nil, month: month, year: year)
        let viewController = ViewControllerFactory.makeAddPaymentCardViewController(model: model, journey: .wallet)
        let navigationRequest = PushNavigationRequest(viewController: viewController, hidesBackButton: true)
        Current.navigate.to(navigationRequest)
    }
    
    func userDidSkip(_ scanViewController: ScanViewController) {
        let viewController = ViewControllerFactory.makeAddPaymentCardViewController(journey: .wallet)
        let navigationRequest = PushNavigationRequest(viewController: viewController, hidesBackButton: true)
        Current.navigate.to(navigationRequest)
    }
}
