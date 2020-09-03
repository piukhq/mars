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
    // Add logic for if we don't want the modal to be dragged to dismiss
    init(viewController: UIViewController, fullScreen: Bool = false, embedInNavigationController: Bool = true, completion: (() -> Void)? = nil, animated: Bool = true) {
        self.viewController = viewController
        self.fullScreen = fullScreen
        self.embedInNavigationController = embedInNavigationController
        self.completion = completion
        self.animated = animated
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
    
    // Each tab should have their own navigation controller, with a rootViewController, which should be the respective wallet view controllers
    // TODO: This currently only works for the wallet navigation controllers. When we present Settings for example, if we want to present modally from there, this should return Settings' navigation controller.
    var navigationController: UINavigationController? {
        // We should only ever be attempting navigation on the top most view controller, and only where it is a navigation controller
        return UIViewController.topMostViewController() as? UINavigationController
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
            if let visibleViewController = UIViewController.topMostViewController() {
                visibleViewController.dismiss(animated: navigationRequest.animated, completion: navigationRequest.completion)
            }
        default:
            fatalError("Navigation route not implemented")
        }
    }
}
