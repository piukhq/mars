//
//  NewFeatureView.swift
//  binkapp
//
//  Created by Sean Williams on 02/03/2023.
//  Copyright © 2023 Bink. All rights reserved.
//

import SwiftUI

enum Screen: Int {
    case loyaltyWallet
    case paymentWallet
    case browseBrands
    case settings
    case lcd
    case barcodeView
}

class NewFeatureViewModel {
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

struct NewFeatureView: View {
    var feature: NewFeatureModel
    let viewModel = NewFeatureViewModel()
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .frame(height: 120)
                .foregroundColor(Color(Current.themeManager.color(for: .walletCardBackground)))
            HStack {
                VStack(alignment: .leading, spacing: 10) {
                    Text(feature.title ?? "Title")
                        .font(.nunitoBold(18))
                        .foregroundColor(Color(Current.themeManager.color(for: .text)))
                    Text(feature.description ?? "This summary, which briefly sets out your rights and obligations in relation to administration charges")
                        .font(.nunitoSans(14))
                        .foregroundColor(Color(Current.themeManager.color(for: .text)))
                    
                    if let screen = feature.screen {
                        HStack {
                            Spacer()
                            Button {
                                viewModel.navigate(to: Screen(rawValue: screen))
                            } label: {
                                Text("Take me there")
                                    .font(.nunitoSemiBold(14))
                            }
                        }
                    }
                }
                .padding(20)
                
                Spacer()
            }
        }
        .padding()
    }
}

struct NewFeatureView_Previews: PreviewProvider {
    static var previews: some View {
        NewFeatureView(feature: NewFeatureModel(id: nil, title: "Updates", description: "Great stuff here", screen: 2))
    }
}
