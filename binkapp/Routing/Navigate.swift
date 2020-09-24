//
//  Navigate.swift
//  binkapp
//
//  Created by Nick Farrant on 14/08/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import UIKit
import CardScan

protocol BaseNavigationRequest {}

enum NavigationOwner: Int {
    case loyalty = 0
    case payment = 2
}

struct PushNavigationRequest: BaseNavigationRequest {
    let viewController: UIViewController
    let animated: Bool
    let hidesBackButton: Bool
    let completion: EmptyCompletionBlock?
    init(viewController: UIViewController, animated: Bool = true, hidesBackButton: Bool = false, completion: EmptyCompletionBlock? = nil) {
        self.viewController = viewController
        self.animated = animated
        self.hidesBackButton = hidesBackButton
        self.completion = completion
    }
}

struct PopNavigationRequest: BaseNavigationRequest {
    let toRoot: Bool
    let animated: Bool
    let completion: EmptyCompletionBlock?
    init(toRoot: Bool = false, animated: Bool = true, completion: EmptyCompletionBlock? = nil) {
        self.toRoot = toRoot
        self.animated = animated
        self.completion = completion
    }
}

struct ModalNavigationRequest: BaseNavigationRequest {
    let viewController: UIViewController
    let fullScreen: Bool
    let embedInNavigationController: Bool
    let animated: Bool
    let transition: UIModalTransitionStyle
    let allowDismiss: Bool
    let completion: EmptyCompletionBlock?
    init(viewController: UIViewController, fullScreen: Bool = false, embedInNavigationController: Bool = true, animated: Bool = true, transition: UIModalTransitionStyle = .coverVertical, allowDismiss: Bool = true, completion: EmptyCompletionBlock? = nil) {
        self.viewController = viewController
        self.fullScreen = fullScreen
        self.embedInNavigationController = embedInNavigationController
        self.animated = animated
        self.transition = transition
        self.allowDismiss = allowDismiss
        self.completion = completion
    }
}

struct AlertNavigationRequest: BaseNavigationRequest {
    let alertController: UIAlertController
    init(alertController: UIAlertController) {
        self.alertController = alertController
    }
}

struct CloseModalNavigationRequest: BaseNavigationRequest {
    let animated: Bool
    let completion: EmptyCompletionBlock?
    init(animated: Bool = true, completion: EmptyCompletionBlock? = nil) {
        self.animated = animated
        self.completion = completion
    }
}

struct ExternalUrlNavigationRequest: BaseNavigationRequest {
    let url: String
}

class Navigate {
    // TODO: Handle when refactoring onboarding, as there is no tab bar
    private lazy var tabBarController: MainTabBarViewController = {
        guard let tabBarController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarViewController else {
            fatalError("Could not get the tab bar controller. Either we are in onboarding, or something is broken.")
        }
        return tabBarController
    }()
    
    private lazy var navigationHandler = BaseNavigationHandler(tabBarController: tabBarController)
    
    var loyaltyCardScannerDelegate: BarcodeScannerViewControllerDelegate {
        return tabBarController
    }
    
    var paymentCardScannerDelegate: ScanDelegate {
        return tabBarController
    }
    
    func to(_ navigationRequest: BaseNavigationRequest) {
        navigationHandler.to(navigationRequest)
    }
    
    func to(_ tab: NavigationOwner, popToRoot: Bool = false, nestedPushNavigationRequest: PushNavigationRequest? = nil, completion: EmptyCompletionBlock? = nil) {
        tabBarController.selectedIndex = tab.rawValue
        if let nestedNavigationRequest = nestedPushNavigationRequest {
            // We cannot execute the nested navigation request on the navigation handler, as that will use the top most navigation controller, which if we are using this method should not be from the tab bar.
            if let navigationController = tabBarController.selectedViewController as? PortraitNavigationController {
                if popToRoot {
                    navigationController.popToRootViewController()
                }
                navigationController.pushViewController(nestedNavigationRequest.viewController, animated: nestedNavigationRequest.animated, hidesBackButton: nestedNavigationRequest.hidesBackButton, completion: nestedNavigationRequest.completion)
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            completion?()
        }
    }
    
    func back(toRoot: Bool = false, animated: Bool = true, completion: EmptyCompletionBlock? = nil) {
        to(PopNavigationRequest(toRoot: toRoot, animated: animated, completion: completion))
    }
    
    func close(animated: Bool = true, completion: EmptyCompletionBlock? = nil) {
        to(CloseModalNavigationRequest(animated: animated, completion: completion))
    }
}

class BaseNavigationHandler {
    private let tabBarController: UITabBarController
    
    init(tabBarController: UITabBarController) {
        self.tabBarController = tabBarController
    }
    
    var navigationController: PortraitNavigationController? {
        // Top view controller should always be a navigation controller, unless it is a tab bar controller
        // If a tab bar controller, the selected view controller should generally be a navigation controller
        // If it's not, we can only present modally
        guard let topViewController = UIViewController.topMostViewController() else { return nil }
        if let navigationController = topViewController as? PortraitNavigationController { return navigationController }
        if let tabBarController = topViewController as? UITabBarController, let selectedNavigationController = tabBarController.selectedViewController as? PortraitNavigationController {
            return selectedNavigationController
        }
        return nil
    }
    
    func to(_ navigationRequest: BaseNavigationRequest) {
        switch navigationRequest {
        case let navigationRequest as PushNavigationRequest:
            navigationController?.pushViewController(navigationRequest.viewController, animated: navigationRequest.animated, hidesBackButton: navigationRequest.hidesBackButton, completion: navigationRequest.completion)
        case let navigationRequest as PopNavigationRequest:
            if navigationRequest.toRoot {
                navigationController?.popToRootViewController(animated: navigationRequest.animated, completion: navigationRequest.completion)
            } else {
                navigationController?.popViewController(animated: navigationRequest.animated, completion: navigationRequest.completion)
            }
        case let navigationRequest as ModalNavigationRequest:
            let viewController = navigationRequest.embedInNavigationController ? PortraitNavigationController(rootViewController: navigationRequest.viewController, isModallyPresented: true) : navigationRequest.viewController
            
            // Otherwise will default to iOS 13 style modal
            if navigationRequest.fullScreen {
                viewController.modalPresentationStyle = .fullScreen
            }
            
            viewController.modalTransitionStyle = navigationRequest.transition
            
            if !navigationRequest.allowDismiss {
                if #available(iOS 13.0, *) {
                    viewController.isModalInPresentation = true
                }
            }
            
            // We don't need to depend on a navigation controller to present modally, so simply present from the top view controller if possible
            UIViewController.topMostViewController()?.present(viewController, animated: navigationRequest.animated, completion: navigationRequest.completion)
        case let navigationRequest as CloseModalNavigationRequest:
            UIViewController.topMostViewController()?.dismiss(animated: navigationRequest.animated, completion: navigationRequest.completion)
        case let navigationRequest as AlertNavigationRequest:
            UIViewController.topMostViewController()?.present(navigationRequest.alertController, animated: true, completion: nil)
        case let navigationRequest as ExternalUrlNavigationRequest:
            guard let url = URL(string: navigationRequest.url), UIApplication.shared.canOpenURL(url) else { return }
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        default:
            fatalError("Navigation route not implemented")
        }
    }
}
