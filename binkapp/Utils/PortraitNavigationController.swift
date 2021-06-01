//
//  PortraitNavigationController.swift
//  binkapp
//
//  Created by Paul Tiriteu on 10/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class PortraitNavigationController: UINavigationController {
    private var isModallyPresented = false
    private var statusBarStyle: UIStatusBarStyle = .default
    
    private lazy var backButton: UIBarButtonItem = {
        let back = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        back.accessibilityIdentifier = "back"
        return back
    }()
    
    private lazy var closeButton: UIBarButtonItem = {
        return UIBarButtonItem(image: Asset.close.image, style: .plain, target: self, action: #selector(close))
    }()
    
    // TODO: When we kill off iOS 12 support, remove the init overrides and just use a custom init
    
    convenience init(rootViewController: UIViewController, isModallyPresented: Bool = false, shouldShowCloseButton: Bool = true) {
        self.init(rootViewController: rootViewController)
        self.isModallyPresented = isModallyPresented
        if isModallyPresented && shouldShowCloseButton {
            rootViewController.navigationItem.rightBarButtonItem = closeButton
        }
        configureForCurrentTheme()
        Current.themeManager.addObserver(self, handler: #selector(configureForCurrentTheme))
    }
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        configureForCurrentTheme()
        Current.themeManager.addObserver(self, handler: #selector(configureForCurrentTheme))
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        configureForCurrentTheme()
        Current.themeManager.addObserver(self, handler: #selector(configureForCurrentTheme))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        // If top view controller is LCD and navBar is visible, set status bar style using theme manager, otherwise get style from view controller
        if let loyaltyCardDetailsViewController = viewControllers.last as? LoyaltyCardFullDetailsViewController {
            if loyaltyCardDetailsViewController.navigationBarShouldBeVisible {
                return statusBarStyle
            } else {
                return loyaltyCardDetailsViewController.preferredStatusBarStyle
            }
        }
        return viewControllers.last?.preferredStatusBarStyle ?? statusBarStyle
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        super.pushViewController(viewController, animated: animated)
        viewController.navigationItem.backBarButtonItem = backButton
        if isModallyPresented {
            viewController.navigationItem.rightBarButtonItem = closeButton
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        configureForCurrentTheme()
    }
    
    func pushViewController(_ viewController: UIViewController, animated: Bool = false, hidesBackButton: Bool = false, completion: EmptyCompletionBlock? = nil) {
        viewController.navigationItem.setHidesBackButton(hidesBackButton, animated: true)
        pushViewController(viewController, animated: animated)
        
        guard animated, let coordinator = transitionCoordinator else {
            DispatchQueue.main.async { completion?() }
            return
        }
        coordinator.animate(alongsideTransition: nil) { _ in completion?() }
    }
    
    func popViewController(animated: Bool = false, completion: EmptyCompletionBlock? = nil) {
        popViewController(animated: animated)
        
        guard animated, let coordinator = transitionCoordinator else {
            DispatchQueue.main.async { completion?() }
            return
        }
        coordinator.animate(alongsideTransition: nil) { _ in completion?() }
    }
    
    func popToRootViewController(animated: Bool = false, completion: EmptyCompletionBlock? = nil) {
        popToRootViewController(animated: animated)
        
        guard animated, let coordinator = transitionCoordinator else {
            DispatchQueue.main.async { completion?() }
            return
        }
        coordinator.animate(alongsideTransition: nil) { _ in completion?() }
    }
    
    @objc private func close() {
        Current.navigate.close()
    }

    @objc func configureForCurrentTheme() {
        navigationBar.standardAppearance = Current.themeManager.navBarAppearance(for: traitCollection)
        navigationBar.scrollEdgeAppearance = Current.themeManager.navBarAppearance(for: traitCollection)
        toolbar.standardAppearance = Current.themeManager.toolbarAppearance(for: traitCollection)
        
        // If top view controller is LCD and navBar is not visible, don't change tint colour
        if let loyaltyCardDetailsViewController = viewControllers.last as? LoyaltyCardFullDetailsViewController {
            if loyaltyCardDetailsViewController.navigationBarShouldBeVisible {
                navigationBar.tintColor = Current.themeManager.color(for: .text)
            }
        } else {
            navigationBar.tintColor = Current.themeManager.color(for: .text)
        }
        
        navigationBar.setNeedsLayout()
        statusBarStyle = Current.themeManager.statusBarStyle(for: traitCollection)
        setNeedsStatusBarAppearanceUpdate()
    }
}
