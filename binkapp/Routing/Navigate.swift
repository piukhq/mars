//
//  Navigate.swift
//  binkapp
//
//  Created by Nick Farrant on 14/08/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import UIKit

enum NavigationLogicHandler {
    case loyaltyWallet
    case paymentWallet
    case modal
}

protocol BaseNavigationRequest {
    var logicHandler: NavigationLogicHandler { get }
    var viewController: UIViewController { get }
}

struct ModalNavigationRequest: BaseNavigationRequest {
    let logicHandler: NavigationLogicHandler
    let viewController: UIViewController
    let fullScreen: Bool
    let embedInNavigationController: Bool
    let completion: (() -> Void)?
    let animated: Bool
    init(viewController: UIViewController, fullScreen: Bool = false, embedInNavigationController: Bool = true, completion: (() -> Void)? = nil, animated: Bool = true) {
        self.logicHandler = .modal
        self.viewController = viewController
        self.fullScreen = fullScreen
        self.embedInNavigationController = embedInNavigationController
        self.completion = completion
        self.animated = animated
    }
}

class Navigate {
    private var lastLogicHandler: NavigationLogicHandler = .loyaltyWallet
    private lazy var tabBarController: MainTabBarViewController? = {
        // For some reason, the root view controller is a navigation controller, with an embedded tab bar controller. This is backwards.
        // We should fix this when we implement the navigation refactor, then remove this logic and make it much nicer to access the tab bar controller via UIApplication
        var tabBarController: MainTabBarViewController?
        if let rootViewController = UIApplication.shared.keyWindow?.rootViewController as? PortraitNavigationController {
            for viewController in rootViewController.viewControllers {
                if let tbc = viewController as? MainTabBarViewController {
                    tabBarController = tbc
                }
                if tabBarController != nil { break }
            }
        }
        return tabBarController
    }()
    
    // Obviously remove force unwrapping
    private lazy var navigationHandler = BaseNavigationHandler(tabBarController: tabBarController!)
    
    func to(_ navigationRequest: BaseNavigationRequest) {
        lastLogicHandler = navigationRequest.logicHandler
        navigationHandler.to(navigationRequest)
    }
}

class BaseNavigationHandler {
    private let tabBarController: UITabBarController
    
    init(tabBarController: UITabBarController) {
        self.tabBarController = tabBarController
    }
    
    // Each tab should have their own navigation controller, with a rootViewController, which should be the respective wallet view controllers
    var navigationController: PortraitNavigationController? {
        let selectedIndex = tabBarController.selectedIndex
        return tabBarController.viewControllers?[safe: selectedIndex]?.navigationController as? PortraitNavigationController
    }
    
    func to(_ navigationRequest: BaseNavigationRequest) {
        switch navigationRequest {
        case let navigationRequest as ModalNavigationRequest:
            let viewController = navigationRequest.embedInNavigationController ? PortraitNavigationController(rootViewController: navigationRequest.viewController) : navigationRequest.viewController
            navigationController?.present(viewController, animated: navigationRequest.animated, completion: navigationRequest.completion)
        default:
            fatalError("Navigation route not implemented")
        }
    }
}




//enum NavigationTransition {
//    case push
//    case modal
//}
//
//protocol Navigate {
//    func navigate(to destination: UIViewController, withTransition transition: NavigationTransition)
//}
//
//extension Navigate where Self: UIViewController {
//    func navigate(to destination: UIViewController, withTransition transition: NavigationTransition) {
//        switch transition {
//        case .push:
//            navigationController?.pushViewController(destination, animated: true)
//        case .modal:
//            present(destination, animated: true, completion: nil)
//        }
//    }
//}
//
//protocol Router: Navigate {}
//
//extension Router where Self: SettingsViewController {
//    func toPreferences() {
//        // repositories dont need api client injection
//        // view models don't need router injection
//        let viewController = PreferencesViewController(viewModel: PreferencesViewModel(repository: PreferencesRepository(apiClient: Current.apiClient), router: MainScreenRouter(delegate: nil)))
//        navigate(to: viewController, withTransition: .push)
//    }
//}
//
//extension Router where Self: BrowseBrandsViewController {
//    func toSomethingElse() {
//
//    }
//}
