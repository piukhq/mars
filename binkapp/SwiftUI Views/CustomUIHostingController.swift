//
//  CustomUIHostingController.swift
//  binkapp
//
//  Created by Sean Williams on 29/09/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import SwiftUI
import FirebaseAnalytics


class CustomUIHostingController<Content>: UIHostingController<Content> where Content: View {
    override init(rootView: Content) {
        super.init(rootView: rootView)
    }
    
    public init(rootView: Content, screenName: TrackedScreen? = nil) {
        super.init(rootView: rootView)
        Analytics.logEvent(AnalyticsEventScreenView, parameters: [AnalyticsParameterScreenName: screenName?.rawValue ?? ""])
        configureForCurrentTheme()
        Current.themeManager.addObserver(self, handler: #selector(configureForCurrentTheme))
        
        // Required to disable automatic keyboard avoidance when textfield becomes focussed
        disableSafeArea()
    }
    
    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        Current.themeManager.statusBarStyle(for: traitCollection)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        configureForCurrentTheme()
    }

    @objc func configureForCurrentTheme() {
        view.backgroundColor = Current.themeManager.color(for: .viewBackground)
        switch Current.themeManager.currentTheme.type {
        case .light:
            view.window?.overrideUserInterfaceStyle = .light
        case .dark:
            view.window?.overrideUserInterfaceStyle = .dark
        case .system:
            view.window?.overrideUserInterfaceStyle = .unspecified
        }
    }
    
    func disableSafeArea() {
        guard let viewClass = object_getClass(view) else { return }
        
        let viewSubclassName = String(cString: class_getName(viewClass)).appending("_IgnoreSafeArea")
        if let viewSubclass = NSClassFromString(viewSubclassName) {
            object_setClass(view, viewSubclass)
        } else {
            guard let viewClassNameUtf8 = (viewSubclassName as NSString).utf8String else { return }
            guard let viewSubclass = objc_allocateClassPair(viewClass, viewClassNameUtf8, 0) else { return }
            
            if let method2 = class_getInstanceMethod(viewClass, NSSelectorFromString("keyboardWillShowWithNotification:")) {
                let keyboardWillShow: @convention(block) (AnyObject, AnyObject) -> Void = { _, _ in }
                class_addMethod(viewSubclass, NSSelectorFromString("keyboardWillShowWithNotification:"), imp_implementationWithBlock(keyboardWillShow), method_getTypeEncoding(method2))
            }
            
            objc_registerClassPair(viewSubclass)
            object_setClass(view, viewSubclass)
        }
    }
}
