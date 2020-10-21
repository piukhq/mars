//
//  BarBlur.swift
//  Bink
//
//  Created by Max Woodhams on 03/12/2018.
//  Copyright © 2018 Loyalty Angels. All rights reserved.
//

import UIKit

protocol BarBlurring {
    func prepareBarWithBlur(bar: UINavigationBar, blurBackground: UIVisualEffectView)
    func prepareBarWithBlur(bar: UITabBar, blurBackground: UIVisualEffectView)
    var blurBackground: UIVisualEffectView { get set }
    func defaultBlurredBackground() -> UIVisualEffectView
}

enum BarTypeBlur {
    case navigationBar
    case tabBar
}

extension BarBlurring {

    func prepareBarWithBlur(bar: UINavigationBar, blurBackground: UIVisualEffectView) {
        prepareBlur(bar: bar, blurBackground: blurBackground, frame: frameWithType(type: .navigationBar, background: blurBackground, bar: bar))
    }

    func prepareBarWithBlur(bar: UITabBar, blurBackground: UIVisualEffectView) {
        prepareBlur(bar: bar, blurBackground: blurBackground, frame: frameWithType(type: .tabBar, background: blurBackground, bar: bar))
    }
    
    func frameWithType(type: BarTypeBlur, background: UIView, bar: UIView) -> CGRect {

        var topEdge, bottomEdge: CGFloat

        switch type {
        case .navigationBar:
            topEdge = 50.0
            bottomEdge = 1.0
        case .tabBar:
            topEdge = 4.0
            bottomEdge = 0.0
        }

        return CGRect(x: 0, y: -topEdge, width: bar.frame.size.width, height: bar.frame.size.height + topEdge + bottomEdge)
    }
    
    func prepareBlur(bar: AnyObject, blurBackground: UIVisualEffectView, frame: CGRect) {
        // This is only necessary pre iOS 13. We will leave this calling through but catch here
        if #available(iOS 13, *) {} else {
            if let declaredBar = bar as? UIView {
                declaredBar.clearBackgroundImage()

                if blurBackground.superview == nil {
                    declaredBar.insertSubview(blurBackground, at: 0)

                    blurBackground.frame = frame
                } else {
                    let subviews = declaredBar.subviews

                    if let originalIndex = subviews.firstIndex(of: blurBackground) {
                        if originalIndex != 0 {
                            declaredBar.insertSubview(blurBackground, at: 0)
                            blurBackground.frame = frame
                        }
                    }
                }
            }
        }
    }
    
    func defaultBlurredBackground() -> UIVisualEffectView {
        let visualEffectView: UIVisualEffectView = UIVisualEffectView(effect: UIBlurEffect.init(style: .light))
        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        visualEffectView.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        return visualEffectView
    }
}

private extension UIView {
    func clearBackgroundImage() {
        backgroundColor = UIColor.clear
        
        if let navBar = self as? UINavigationBar {
            navBar.shadowImage = UIImage()
            navBar.setBackgroundImage(UIImage(), for: .default)
            
        } else if let tabBar = self as? UITabBar {
            tabBar.backgroundImage = UIImage()
        }
    }
}
