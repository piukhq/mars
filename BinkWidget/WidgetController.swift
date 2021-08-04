//
//  WidgetController.swift
//  binkapp
//
//  Created by Sean Williams on 30/06/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import UIKit
import WidgetKit

class WidgetController {
    private var isPerformingNavigation = false
    private var urlPath = ""
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleWalletReload), name: .didLoadLocalWallet, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func handleWalletReload() {
        if isPerformingNavigation {
            navigateToQuickLaunchWidgetDestination(urlPath: urlPath)
        }
    }
    
    func reloadWidget(type: WidgetType) {
        if #available(iOS 14.0, *) {
            switch type {
            case .quickLaunch:
                WidgetCenter.shared.reloadTimelines(ofKind: WidgetType.quickLaunch.identifier)
            }
        }
    }
    
    func handleURLForWidgetType(type: WidgetType, urlPath: String) {
        isPerformingNavigation = true
        self.urlPath = urlPath
        
        switch type {
        case .quickLaunch:
            Current.navigate.closeShieldView {
                guard let topViewController = UIViewController.topMostViewController() else { return }
                if topViewController.isModal {
                    let nav = topViewController as? PortraitNavigationController
                    let rootViewController = nav?.viewControllers.last
                    if rootViewController?.isKind(of: BrowseBrandsViewController.self) == true && urlPath == WidgetUrlPath.addCard.rawValue { return }
                    
                    Current.navigate.close(animated: true) {
                        self.navigateToQuickLaunchWidgetDestination(urlPath: urlPath)
                    }
                } else {
                    self.navigateToQuickLaunchWidgetDestination(urlPath: urlPath)
                }
            }
        }
    }
    
    private func navigateToQuickLaunchWidgetDestination(urlPath: String) {
        guard let membershipCard = Current.wallet.membershipCards?.first(where: { $0.id == urlPath }) else {
            navigateToBrowseBrands(urlPath: urlPath)
            return
        }
        
        guard !currentViewControllerMatchesDestination(urlPath: urlPath) else { return }
        let lcdViewController = ViewControllerFactory.makeLoyaltyCardDetailViewController(membershipCard: membershipCard, animateContent: false)
        let lcdNavigationRequest = PushNavigationRequest(viewController: lcdViewController, animated: true)
        let navigationRequest = TabBarNavigationRequest(tab: .loyalty, popToRoot: true, backgroundPushNavigationRequest: lcdNavigationRequest) {
            self.navigateToBrowseBrands(urlPath: urlPath)
        }
        Current.navigate.to(navigationRequest)
        isPerformingNavigation = false
    }
    
    private func navigateToBrowseBrands(urlPath: String) {
        if urlPath == WidgetUrlPath.addCard.rawValue {
            let viewController = ViewControllerFactory.makeBrowseBrandsViewController()
            let navigationRequest = ModalNavigationRequest(viewController: viewController)
            Current.navigate.to(navigationRequest)
            isPerformingNavigation = false
        }
    }
    
    private func currentViewControllerMatchesDestination(urlPath: String) -> Bool {
        guard let topViewController = UIViewController.topMostViewController() else { return false }
        let mainTabBar = topViewController as? MainTabBarViewController
        let nav = mainTabBar?.viewControllers?.first as? PortraitNavigationController
        let currentViewController = nav?.viewControllers.last
        if currentViewController?.isKind(of: LoyaltyCardFullDetailsViewController.self) == true && mainTabBar?.selectedIndex == 0 {
            let lcd = currentViewController as? LoyaltyCardFullDetailsViewController
            if lcd?.viewModel.membershipCard.id == urlPath { return true }
        }
        return false
    }
    
    func writeContentsToDisk(membershipCards: [CD_MembershipCard]?) {
        guard let walletCards = membershipCards else { return }
        let imageRequestGroup = DispatchGroup()
        var widgetCards: [MembershipCardWidget] = []
        
        for (i, membershipCard) in walletCards.enumerated() {
            guard let plan = membershipCard.membershipPlan, i < 4 else { break }
            imageRequestGroup.enter()
            
            ImageService.getImage(forPathType: .membershipPlanIcon(plan: plan), traitCollection: nil) { retrievedImage in
                let membershipCardWidget = MembershipCardWidget(id: membershipCard.id, imageData: retrievedImage?.pngData(), backgroundColor: membershipCard.membershipPlan?.card?.colour)
                widgetCards.append(membershipCardWidget)
                imageRequestGroup.leave()
            }
        }
        
        imageRequestGroup.notify(queue: .main) {
            if widgetCards.count < 4 {
                let addCard = MembershipCardWidget(id: WidgetUrlPath.addCard.rawValue, imageData: nil, backgroundColor: nil)
                let spacerZero = MembershipCardWidget(id: WidgetUrlPath.spacerZero.rawValue, imageData: nil, backgroundColor: nil)
                let spacerOne = MembershipCardWidget(id: WidgetUrlPath.spacerOne.rawValue, imageData: nil, backgroundColor: nil)
                var spacerCards: [MembershipCardWidget] = []

                if widgetCards.count == 1 {
                    spacerCards.append(spacerZero)
                }

                if widgetCards.isEmpty {
                    spacerCards.append(spacerZero)
                    spacerCards.append(spacerOne)
                }
                
                widgetCards.append(addCard)
                widgetCards.append(contentsOf: spacerCards)
            }
            
            let widgetContent = WidgetContent(walletCards: widgetCards)
            guard let archiveURL = FileManager.sharedContainerURL()?.appendingPathComponent("contents.json") else { return }
            
            let encoder = JSONEncoder()
            if let dataToSave = try? encoder.encode(widgetContent) {
                do {
                    try dataToSave.write(to: archiveURL)
                    self.reloadWidget(type: .quickLaunch)
                } catch {
                    if #available(iOS 14.0, *) {
                        BinkLogger.error(AppLoggerError.encodeWidgetContentsToDiskFailure, value: error.localizedDescription)
                    }
                    return
                }
            }
        }
    }
    
    func trackInstalledWidgets() {
        if #available(iOS 14.0, *) {
            WidgetCenter.shared.getCurrentConfigurations { info in
                switch info {
                case .success(let widgetInfo):
                    BinkAnalytics.track(WidgetAnalyticsEvent.installedWidgets(widgetInfo))
                default:
                    break
                }
            }
        }
    }
}
