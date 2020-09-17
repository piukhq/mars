//
//  Navigate.swift
//  binkapp
//
//  Created by Nick Farrant on 14/08/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import UIKit

// USE CASES TO COVER:
// Removing/inserting view controllers from the navigation stack after pushing
// View controllers should know how they were presented and display close or back buttons accordingly

enum NavigationType {
    case push
    case modal
    case close
}

protocol BaseNavigationRequest {
    var navigationType: NavigationType { get }
}

struct PushNavigationRequest: BaseNavigationRequest {
    let navigationType: NavigationType = .push
    let viewController: UIViewController
    let completion: (() -> Void)?
    let animated: Bool
    init(viewController: UIViewController, completion: (() -> Void)? = nil, animated: Bool = true) {
        self.viewController = viewController
        self.completion = completion
        self.animated = animated
    }
}

struct ModalNavigationRequest: BaseNavigationRequest {
    let navigationType: NavigationType = .modal
    let viewController: UIViewController
    let fullScreen: Bool
    let embedInNavigationController: Bool
    let completion: (() -> Void)?
    let animated: Bool
    // TODO: Add logic for if we don't want the modal to be dragged to dismiss
    init(viewController: UIViewController, fullScreen: Bool = false, embedInNavigationController: Bool = true, completion: (() -> Void)? = nil, animated: Bool = true) {
        self.viewController = viewController
        self.fullScreen = fullScreen
        self.embedInNavigationController = embedInNavigationController
        self.completion = completion
        self.animated = animated
    }
}

struct AlertNavigationRequest: BaseNavigationRequest {
    var navigationType: NavigationType = .modal
    let alertController: UIAlertController
    init(alertController: UIAlertController) {
        self.alertController = alertController
    }
}

struct CloseModalNavigationRequest: BaseNavigationRequest {
    let navigationType: NavigationType = .close
    let animated: Bool
    let completion: (() -> Void)?
    init(animated: Bool = true, completion: (() -> Void)? = nil) {
        self.animated = animated
        self.completion = completion
    }
}

class Navigate {
    /// Maintain a reference to the last navigation type used.
    /// This is so we know how to configure any view controller to be dismissed by Navigate
    private var lastNavigationType: NavigationType?
    
    // TODO: Handle when refactoring onboarding, as there is no tab bar
    private lazy var tabBarController: MainTabBarViewController = {
        guard let tabBarController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarViewController else {
            fatalError("Could not get the tab bar controller. Either we are in onboarding, or something is broken.")
        }
        return tabBarController
    }()
    
    // Obviously remove force unwrapping
    private lazy var navigationHandler = BaseNavigationHandler(tabBarController: tabBarController)
    
    func to(_ navigationRequest: BaseNavigationRequest) {
        lastNavigationType = navigationRequest.navigationType
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
    
    var navigationController: UINavigationController? {
        // Top view controller should always be a navigation controller, unless it is a tab bar controller
        // If a tab bar controller, the selected view controller should generally be a navigation controller
        // If it's not, we can only present modally
        guard let topViewController = UIViewController.topMostViewController() else { return nil }
        if let navigationController = topViewController as? UINavigationController { return navigationController }
        if let tabBarController = topViewController as? UITabBarController, let selectedNavigationController = tabBarController.selectedViewController as? UINavigationController {
            return selectedNavigationController
        }
        return nil
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
            
            // We don't need to depend on a navigation controller to present modally, so simply present from the top view controller if possible
            UIViewController.topMostViewController()?.present(viewController, animated: navigationRequest.animated, completion: navigationRequest.completion)
        case let navigationRequest as CloseModalNavigationRequest:
            UIViewController.topMostViewController()?.dismiss(animated: navigationRequest.animated, completion: navigationRequest.completion)
        case let navigationRequest as AlertNavigationRequest:
            UIViewController.topMostViewController()?.present(navigationRequest.alertController, animated: true, completion: nil)
        default:
            fatalError("Navigation route not implemented")
        }
    }
}
