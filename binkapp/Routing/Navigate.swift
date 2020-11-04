//
//  Navigate.swift
//  binkapp
//
//  Created by Nick Farrant on 14/08/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import UIKit
import CardScan

protocol BaseNavigationRequest {
    var completion: EmptyCompletionBlock? { get }
}

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
    let dragToDismiss: Bool
    let hideCloseButton: Bool
    let completion: EmptyCompletionBlock?
    init(viewController: UIViewController, fullScreen: Bool = false, embedInNavigationController: Bool = true, animated: Bool = true, transition: UIModalTransitionStyle = .coverVertical, dragToDismiss: Bool = true, hideCloseButton: Bool = false, completion: EmptyCompletionBlock? = nil) {
        self.viewController = viewController
        self.fullScreen = fullScreen
        self.embedInNavigationController = embedInNavigationController
        self.animated = animated
        self.transition = transition
        self.dragToDismiss = dragToDismiss
        self.hideCloseButton = hideCloseButton
        self.completion = completion
    }
}

struct TabBarNavigationRequest: BaseNavigationRequest {
    let tab: NavigationOwner
    let popToRoot: Bool
    let backgroundPushNavigationRequest: PushNavigationRequest?
    let completion: EmptyCompletionBlock?
    init(tab: NavigationOwner, popToRoot: Bool = false, backgroundPushNavigationRequest: PushNavigationRequest? = nil, completion: EmptyCompletionBlock? = nil) {
        self.tab = tab
        self.popToRoot = popToRoot
        self.backgroundPushNavigationRequest = backgroundPushNavigationRequest
        self.completion = completion
    }
}

struct AlertNavigationRequest: BaseNavigationRequest {
    let alertController: UIAlertController
    let completion: EmptyCompletionBlock?
    init(alertController: UIAlertController, completion: EmptyCompletionBlock? = nil) {
        self.alertController = alertController
        self.completion = completion
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

struct CloseShieldViewNavigationRequest: BaseNavigationRequest {
    let completion: EmptyCompletionBlock?
    init(completion: EmptyCompletionBlock? = nil) {
        self.completion = completion
    }
}

struct ExternalUrlNavigationRequest: BaseNavigationRequest {
    let urlString: String
    let completion: EmptyCompletionBlock?
    init(urlString: String, completion: EmptyCompletionBlock? = nil) {
        self.urlString = urlString
        self.completion = completion
    }
}

class Navigate {
    static let transitionDuration: TimeInterval = 0.3
    private let navigationHandler = BaseNavigationHandler()
    private var rootViewController: UIViewController?
    private var allowRequests = true
    
    private var tabBarController: MainTabBarViewController? {
        return rootViewController as? MainTabBarViewController
    }
    
    var loyaltyCardScannerDelegate: BarcodeScannerViewControllerDelegate? {
        return tabBarController
    }
    
    var paymentCardScannerDelegate: ScanDelegate? {
        return tabBarController
    }
    
    func setRootViewController(_ rootViewController: UIViewController?) {
        self.rootViewController = rootViewController
        
        /// If the root view controller is a tab bar controller, set the value in our navigation handler
        navigationHandler.tabBarController = tabBarController
    }
    
    func to(_ navigationRequest: BaseNavigationRequest) {
        guard allowRequests else { return }

        /// If we are attempting to close the shield screen, we should always continue.
        if let request = navigationRequest as? CloseShieldViewNavigationRequest {
            navigationHandler.to(request)
            return
        }

        /// If the top view is the shield screen at this point, we weren't expecting it to be.
        /// We should dismiss the shield view before executing the navigation request that we originally intended.
        /// We only know of this behaviour when system alerts (i.e. camera permission) are presented.
        if let topViewController = UIViewController.topMostViewController(), topViewController.isShieldView {
            /// Temporarily ignore any incoming navigation requests while we dismiss the shield view
            allowRequests = false
            let closeLaunchScreenNavigationRequest = CloseModalNavigationRequest {
                self.navigationHandler.to(navigationRequest)
                /// Once the shield view has been closed, allow navigation requests as normal
                self.allowRequests = true
            }
            navigationHandler.to(closeLaunchScreenNavigationRequest)
        } else {
            navigationHandler.to(navigationRequest)
        }
    }
    
    func back(toRoot: Bool = false, animated: Bool = true, completion: EmptyCompletionBlock? = nil) {
        to(PopNavigationRequest(toRoot: toRoot, animated: animated, completion: completion))
    }
    
    func close(animated: Bool = true, completion: EmptyCompletionBlock? = nil) {
        to(CloseModalNavigationRequest(animated: animated, completion: completion))
    }

    func closeShieldView(completion: EmptyCompletionBlock? = nil) {
        to(CloseShieldViewNavigationRequest(completion: completion))
    }
}

class BaseNavigationHandler {
    var topViewController: UIViewController? {
        return UIViewController.topMostViewController()
    }
    
    /// This value is set by Navigate when it's root view controller is set
    var tabBarController: MainTabBarViewController?
    
    var navigationController: PortraitNavigationController? {
        // Top view controller should always be a navigation controller or a tab bar controller
        // If a tab bar controller, the selected view controller should generally be a navigation controller
        // If it's not, we can only present modally
        guard let topViewController = topViewController else { return nil }
        if let navigationController = topViewController as? PortraitNavigationController { return navigationController }
        if let selectedTabNavigationController = tabBarController?.selectedViewController as? PortraitNavigationController {
            return selectedTabNavigationController
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
            let viewController = navigationRequest.embedInNavigationController ? PortraitNavigationController(rootViewController: navigationRequest.viewController, isModallyPresented: true, shouldShowCloseButton: !navigationRequest.hideCloseButton) : navigationRequest.viewController
            
            // Otherwise will default to iOS 13 style modal
            if navigationRequest.fullScreen {
                viewController.modalPresentationStyle = .fullScreen
            }
            
            viewController.modalTransitionStyle = navigationRequest.transition
            
            if !navigationRequest.dragToDismiss {
                if #available(iOS 13.0, *) {
                    viewController.isModalInPresentation = true
                }
            }
            
            // We don't need to depend on a navigation controller to present modally, so simply present from the top view controller if possible
            topViewController?.present(viewController, animated: navigationRequest.animated, completion: navigationRequest.completion)
        case let navigationRequest as TabBarNavigationRequest:
            tabBarController?.selectedIndex = navigationRequest.tab.rawValue
            
            guard let tabBarNavigationController = tabBarController?.selectedViewController as? PortraitNavigationController else { return }
            
            if navigationRequest.popToRoot {
                tabBarNavigationController.popToRootViewController()
            }
            
            if let backgroundNavigationRequest = navigationRequest.backgroundPushNavigationRequest {
                tabBarNavigationController.pushViewController(backgroundNavigationRequest.viewController, animated: backgroundNavigationRequest.animated, hidesBackButton: backgroundNavigationRequest.hidesBackButton, completion: backgroundNavigationRequest.completion)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + Navigate.transitionDuration) {
                navigationRequest.completion?()
            }
        case let navigationRequest as CloseModalNavigationRequest:
            topViewController?.dismiss(animated: navigationRequest.animated, completion: navigationRequest.completion)
        case let navigationRequest as AlertNavigationRequest:
            topViewController?.present(navigationRequest.alertController, animated: true, completion: navigationRequest.completion)
        case let navigationRequest as ExternalUrlNavigationRequest:
            guard let url = URL(string: navigationRequest.urlString), UIApplication.shared.canOpenURL(url) else { return }
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        case let navigationRequest as CloseShieldViewNavigationRequest:
            guard topViewController?.isShieldView == true else { return }
            topViewController?.dismiss(animated: true, completion: navigationRequest.completion)
        default:
            fatalError("Navigation route not implemented")
        }
    }
}
