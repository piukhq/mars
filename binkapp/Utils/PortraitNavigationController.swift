//
//  PortraitNavigationController.swift
//  binkapp
//
//  Created by Paul Tiriteu on 10/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class PortraitNavigationController: UINavigationController {
    private let isModallyPresented: Bool
    
    private lazy var backButton: UIBarButtonItem = {
        return UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }()
    
    private lazy var closeButton: UIBarButtonItem = {
        return UIBarButtonItem(image: UIImage(named: "close"), style: .plain, target: self, action: #selector(close))
    }()
    
    init(rootViewController: UIViewController, isModallyPresented: Bool = false) {
        self.isModallyPresented = isModallyPresented
        super.init(rootViewController: rootViewController)
        if isModallyPresented {
            rootViewController.navigationItem.rightBarButtonItem = closeButton
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
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
