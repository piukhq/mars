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
    }
    
    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureForCurrentTheme()
        Current.themeManager.addObserver(self, handler: #selector(configureForCurrentTheme))
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
}
