//
//  PortraitNavigationController.swift
//  binkapp
//
//  Created by Paul Tiriteu on 10/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class PortraitNavigationController: UINavigationController {
    private var isModallyPresented: Bool = false
    
    private lazy var backButton: UIBarButtonItem = {
        return UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }()
    
    private lazy var closeButton: UIBarButtonItem = {
        return UIBarButtonItem(image: UIImage(named: "close"), style: .plain, target: self, action: #selector(close))
    }()
    
    // TODO: When we kill off iOS 12 support, remove the init overrides and just use a custom init
    
    convenience init(rootViewController: UIViewController, isModallyPresented: Bool = false, shouldShowCloseButton: Bool = true) {
        self.init(rootViewController: rootViewController)
        self.isModallyPresented = isModallyPresented
        if isModallyPresented && shouldShowCloseButton {
            rootViewController.navigationItem.rightBarButtonItem = closeButton
        }
        configureNavigationBarAppearance()
    }
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        configureNavigationBarAppearance()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        configureNavigationBarAppearance()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if let topViewController = viewControllers.last {
            return topViewController.preferredStatusBarStyle
        }
        return .default
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        super.pushViewController(viewController, animated: animated)
        viewController.navigationItem.backBarButtonItem = backButton
        if isModallyPresented {
            viewController.navigationItem.rightBarButtonItem = closeButton
        }
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
}

// MARK: - Bar appearance

extension PortraitNavigationController {
    func configureNavigationBarAppearance() {
        navigationBar.standardAppearance = .defaultAppearance
        navigationBar.scrollEdgeAppearance = .defaultAppearance
    }
}

extension UINavigationBarAppearance {
    static let defaultAppearance: UINavigationBarAppearance = {
        let backInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)
        let backButtonImage = UIImage(named: "navbarIconsBack")?.withAlignmentRectInsets(backInsets)

        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.shadowImage = UIImage()
        appearance.backgroundColor = .init(white: 1.0, alpha: 0.6)
        appearance.backgroundEffect = UIBlurEffect(style: .light)
        appearance.titleTextAttributes = [NSAttributedString.Key.font: UIFont.navBar, NSAttributedString.Key.foregroundColor: UIColor.black]
        appearance.setBackIndicatorImage(backButtonImage, transitionMaskImage: backButtonImage)

        return appearance
    }()
}
