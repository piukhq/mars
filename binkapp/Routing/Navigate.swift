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
}

struct PushNavigationRequest: BaseNavigationRequest {
    let logicHandler: NavigationLogicHandler
    let viewController: UIViewController
    let completion: (() -> Void)?
    let animated: Bool
    init(viewController: UIViewController, completion: (() -> Void)? = nil, animated: Bool = true) {
        self.logicHandler = .modal
        self.viewController = viewController
        self.completion = completion
        self.animated = animated
    }
}

struct ModalNavigationRequest: BaseNavigationRequest {
    let logicHandler: NavigationLogicHandler
    let viewController: UIViewController
    let fullScreen: Bool
    let embedInNavigationController: Bool
    let completion: (() -> Void)?
    let animated: Bool
    // Add logic for if we don't want the modal to be dragged to dismiss
    init(viewController: UIViewController, fullScreen: Bool = false, embedInNavigationController: Bool = true, completion: (() -> Void)? = nil, animated: Bool = true) {
        self.logicHandler = .modal
        self.viewController = viewController
        self.fullScreen = fullScreen
        self.embedInNavigationController = embedInNavigationController
        self.completion = completion
        self.animated = animated
    }
}

struct CloseModalNavigationRequest: BaseNavigationRequest {
    let logicHandler: NavigationLogicHandler
    let animated: Bool
    let completion: (() -> Void)?
    init(animated: Bool = true, completion: (() -> Void)? = nil) {
        self.animated = animated
        self.completion = completion
        self.logicHandler = .modal
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
    
    func close() {
        to(CloseModalNavigationRequest())
    }
}

class BaseNavigationHandler {
    private let tabBarController: UITabBarController
    
    init(tabBarController: UITabBarController) {
        self.tabBarController = tabBarController
    }
    
    // Each tab should have their own navigation controller, with a rootViewController, which should be the respective wallet view controllers
    // TODO: This currently only works for the wallet navigation controllers. When we present Settings for example, if we want to present modally from there, this should return Settings' navigation controller.
    var navigationController: PortraitNavigationController? {
        let selectedIndex = tabBarController.selectedIndex
        return tabBarController.viewControllers?[safe: selectedIndex]?.navigationController as? PortraitNavigationController
    }
    
    func to(_ navigationRequest: BaseNavigationRequest) {
        switch navigationRequest {
        case let navigationRequest as PushNavigationRequest:
            navigationController?.pushViewController(navigationRequest.viewController, animated: navigationRequest.animated)
        case let navigationRequest as ModalNavigationRequest:
            let viewController = navigationRequest.embedInNavigationController ? PortraitNavigationController(rootViewController: navigationRequest.viewController) : navigationRequest.viewController
            
            // Otherwise will default to iOS 13 style modal
            if navigationRequest.fullScreen {
                viewController.modalPresentationStyle = .fullScreen
            }
            navigationController?.present(viewController, animated: navigationRequest.animated, completion: navigationRequest.completion)
        case let navigationRequest as CloseModalNavigationRequest:
            // The navigation controller should always be the same one that presented the view modally
            navigationController?.dismiss(animated: navigationRequest.animated, completion: navigationRequest.completion)
        default:
            fatalError("Navigation route not implemented")
        }
    }
}
