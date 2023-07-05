//
//  WidgetController.swift
//  binkapp
//
//  Created by Sean Williams on 30/06/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import UIKit
import WidgetKit
import ZXingObjC

class WidgetController {
    private var isPerformingNavigation = false
    private var urlPath = ""
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleWalletReload), name: .didLoadLocalWallet, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func barcodeType(membershipCard: CD_MembershipCard) -> BarcodeType {
        guard let barcodeType = membershipCard.card?.barcodeType?.intValue else {
            return .code128
        }
        return BarcodeType(rawValue: barcodeType) ?? .code128
    }

    @objc private func handleWalletReload() {
        if isPerformingNavigation {
            navigateToQuickLaunchWidgetDestination(urlPath: urlPath)
        }
    }
    
    func reloadWidget(type: WidgetType) {
        switch type {
        case .quickLaunch:
            WidgetCenter.shared.reloadTimelines(ofKind: type.identifier)
        case .barcodeLaunch:
            WidgetCenter.shared.reloadTimelines(ofKind: type.identifier)
        }
    }
    
    func handleURLForWidgetType(type: WidgetType, url: URL) {
        isPerformingNavigation = true
        guard let urlPath = url.host?.removingPercentEncoding else { return }
        self.urlPath = urlPath
        
        let widgetType = WidgetType(rawValue: url.scheme ?? "")
        BinkAnalytics.track(WidgetAnalyticsEvent.widgetLaunch(urlPath: urlPath, widgetType: widgetType))
     
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
        case .barcodeLaunch:
            Current.navigate.closeShieldView {
                guard let topViewController = UIViewController.topMostViewController() else { return }
                if topViewController.isModal {
                    Current.navigate.close(animated: true) {
                        guard let membershipCard = Current.wallet.membershipCards?.first else { return }
                        let viewController = ViewControllerFactory.makeBarcodeViewController(membershipCard: membershipCard)
                        let navigationRequest = ModalNavigationRequest(viewController: viewController)
                        Current.navigate.to(navigationRequest)
                        self.isPerformingNavigation = false
                    }
                } else {
                    guard let membershipCard = Current.wallet.membershipCards?.first else { return }
                    
                    if urlPath == WidgetUrlPath.addCard.rawValue {
                        self.navigateToBrowseBrands(urlPath: urlPath)
                        return
                    }
                    
                    let viewController = ViewControllerFactory.makeBarcodeViewController(membershipCard: membershipCard)
                    let navigationRequest = ModalNavigationRequest(viewController: viewController)
                    Current.navigate.to(navigationRequest)
                    self.isPerformingNavigation = false
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
        MixpanelUtility.track(.lcdViewed(brandName: membershipCard.membershipPlan?.account?.companyName ?? "Unknown", route: .quickLaunchWidget))
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
    
    func barcodeImage(membershipCard: CD_MembershipCard, withSize size: CGSize, drawInContainer: Bool = true, alwaysShowBarCode: Bool = false) -> UIImage? {
        guard let barcodeString = alwaysShowBarCode ? (membershipCard.card?.barcode ?? membershipCard.card?.membershipId) : membershipCard.card?.barcode else { return nil }

        let writer = ZXMultiFormatWriter()
        let encodeHints = ZXEncodeHints()
        encodeHints.margin = 0


        let width = barcodeType(membershipCard: membershipCard) == .code39 ? barcodeType(membershipCard: membershipCard).preferredWidth(for: barcodeString.count, targetWidth: size.width) : size.width
        let height = size.height
        var image: UIImage?

        let exception = tryBlock { [weak self] in
            guard let self = self else { return }

            let result = try? writer.encode(barcodeString, format: barcodeType(membershipCard: membershipCard).zxingType, width: Int32(width), height: Int32(height), hints: encodeHints)

            guard let cgImage = ZXImage(matrix: result).cgimage else { return }

            // If the resulting image is larger than the destination, draw the CGImage in a fixed container
            if CGFloat(cgImage.width) > size.width && drawInContainer {
                let renderer = UIGraphicsImageRenderer(size: size)
                let img = renderer.image { ctx in
                    ctx.cgContext.draw(cgImage, in: CGRect(origin: .zero, size: size))
                }

                image = img
            } else {
                image = UIImage(cgImage: cgImage)
            }
        }

        return exception == nil ? image : nil
    }

    func writeContentsToDisk(membershipCards: [CD_MembershipCard]?) {
        guard let walletCards = membershipCards else { return }
        let imageRequestGroup = DispatchGroup()
        var widgetCards: [MembershipCardWidget] = []
        
        for (i, membershipCard) in walletCards.enumerated() {
            guard let plan = membershipCard.membershipPlan, i < 4 else { break }
            imageRequestGroup.enter()
            
            ImageService.getImage(forPathType: .membershipPlanIcon(plan: plan)) { retrievedImage in
                let membershipCardWidget = MembershipCardWidget(id: membershipCard.id, imageData: retrievedImage?.pngData(), barCodeImage: self.barcodeImage(membershipCard: membershipCard, withSize: CGSize(width: UIScreen.main.bounds.width, height: 120), alwaysShowBarCode: true)?.pngData(), backgroundColor: membershipCard.membershipPlan?.card?.colour, planName: membershipCard.membershipPlan?.account?.planName)
                widgetCards.append(membershipCardWidget)
                imageRequestGroup.leave()
            }
        }
        
        imageRequestGroup.notify(queue: .main) {
            if widgetCards.count < 4 {
                let addCard = MembershipCardWidget(id: WidgetUrlPath.addCard.rawValue, imageData: nil, barCodeImage: nil, backgroundColor: "#f80000", planName: nil)
                let spacerZero = MembershipCardWidget(id: WidgetUrlPath.spacerZero.rawValue, imageData: nil, barCodeImage: nil, backgroundColor: "#f80000", planName: nil)
                let spacerOne = MembershipCardWidget(id: WidgetUrlPath.spacerOne.rawValue, imageData: nil, barCodeImage: nil, backgroundColor: "#f80000", planName: nil)
                var spacerCards: [MembershipCardWidget] = []

                if widgetCards.count == 1 {
                    spacerCards.append(spacerZero)
                }

                if widgetCards.isEmpty {
                    spacerCards.append(addCard)
                    spacerCards.append(addCard)
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
                    self.reloadWidget(type: .barcodeLaunch)
                } catch {
                    BinkLogger.error(AppLoggerError.encodeWidgetContentsToDiskFailure, value: error.localizedDescription)
                    return
                }
            }
        }
    }
}
