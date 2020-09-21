//
//  MainTabBarViewController.swift
//  binkapp
//
//  Copyright (c) 2019 Bink. All rights reserved.
//

import UIKit
import CardScan

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
        
        self.title = "" // TODO: Why? Remove.
        populateTabBar()
    }

    // MARK: - Navigation Bar Blurring
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        prepareBarWithBlur(bar: tabBar, blurBackground: blurBackground)
    }
    
    func populateTabBar() {
        viewControllers = viewModel.viewControllers
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
    // TODO: Can we remove these now?
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
        BinkAnalytics.track(GenericAnalyticsEvent.paymentScan(success: true))
        let month = Int(creditCard.expiryMonth ?? "")
        let year = Int(creditCard.expiryYear ?? "")
        let model = PaymentCardCreateModel(fullPan: creditCard.number, nameOnCard: nil, month: month, year: year)
        let viewController = ViewControllerFactory.makeAddPaymentCardViewController(model: model)
        let navigationRequest = PushNavigationRequest(viewController: viewController, hidesBackButton: true)
        Current.navigate.to(navigationRequest)
    }
    
    func userDidSkip(_ scanViewController: ScanViewController) {
        let viewController = ViewControllerFactory.makeAddPaymentCardViewController()
        let navigationRequest = PushNavigationRequest(viewController: viewController, hidesBackButton: true)
        Current.navigate.to(navigationRequest)
    }
}
