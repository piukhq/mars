//
//  NewFeatureViewModel.swift
//  binkapp
//
//  Created by Sean Williams on 03/03/2023.
//  Copyright © 2023 Bink. All rights reserved.
//

import FirebaseStorage
import SwiftUI

enum Screen: Int {
    case loyaltyWallet
    case paymentWallet
    case browseBrands
    case settings
    case lcd
    case barcodeView
}

class NewFeatureViewModel: ObservableObject {
    @Published var uiImage: UIImage?
    
    var feature: NewFeatureModel

    init(feature: NewFeatureModel) {
        self.feature = feature
        fetchImageFromStorage()
    }
    var backgroundColor: Color {
        return .teal
    }
    
    var textColor: Color {
        return .white
    }
    
    var descriptionTexts: [String]? {
        return feature.description
    }
    
    var hasDeeplink: Bool {
        return feature.screen != nil
    }
    
    var deeplinkScreen: Screen? {
        if let screen = feature.screen {
            return Screen(rawValue: screen)
        } else {
            return nil
        }
    }
    
    private func fetchImageFromStorage() {
        guard let id = feature.id else { return }
        let storage = Storage.storage()
        let path = "new-features/\(id).jpeg"
        let pathReference = storage.reference(withPath: path)
        
        if let cachedImage = Cache.sharedImageCache.object(forKey: path.toNSString()) {
            self.uiImage = cachedImage
            return
        }

        pathReference.getData(maxSize: 1 * 1024 * 1024) { data, _ in
            guard let data = data, let uiImage = UIImage(data: data) else { return }
            
            Cache.sharedImageCache.setObject(uiImage, forKey: path.toNSString())
            DispatchQueue.main.async {
                self.uiImage = uiImage
            }
        }
    }
    
    func navigate(to screen: Screen?) {
        guard let screen = screen else { return }
        Current.navigate.close(animated: true) {
            switch screen {
            case .loyaltyWallet:
                break
            case .paymentWallet:
                let navigationRequest = TabBarNavigationRequest(tab: .payment)
                Current.navigate.to(navigationRequest)
            case .browseBrands:
                let browseBrandsVC = ViewControllerFactory.makeBrowseBrandsViewController()
                let navigationRequest = ModalNavigationRequest(viewController: browseBrandsVC)
                Current.navigate.to(navigationRequest)
            case .settings:
                let settingsVC = ViewControllerFactory.makeSettingsViewController(rowsWithActionRequired: nil)
                let navigationRequest = ModalNavigationRequest(viewController: settingsVC)
                Current.navigate.to(navigationRequest)
            case .lcd:
                guard let membershipCard = Current.wallet.membershipCards?.first else { return }
                
                let mainTabBar = UIViewController.topMostViewController() as? MainTabBarViewController
                if let nav = mainTabBar?.viewControllers?.first as? PortraitNavigationController {
                    if let walletViewController = nav.viewControllers.first as? LoyaltyWalletViewController {
                        walletViewController.shouldUseTransition = true
                        walletViewController.selectedIndexPath = IndexPath(item: 0, section: 0)
                    }
                }
                
                let navigationRequest = PushNavigationRequest(viewController: ViewControllerFactory.makeLoyaltyCardDetailViewController(membershipCard: membershipCard))
                Current.navigate.to(navigationRequest)
            case .barcodeView:
                guard let membershipCard = Current.wallet.membershipCards?.first else { return }
                let viewController = ViewControllerFactory.makeBarcodeViewController(membershipCard: membershipCard)
                let navigationRequest = ModalNavigationRequest(viewController: viewController)
                Current.navigate.to(navigationRequest)
            }
        }
    }
}
