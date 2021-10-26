//
//  CheckYourInboxViewController.swift
//  binkapp
//
//  Created by Sean Williams on 25/10/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import Lottie
import UIKit

class CheckYourInboxViewController: ReusableTemplateViewController {
    enum Constants {
        static let animationDimension: CGFloat = 330
        static let buttonFadeInDelay: CGFloat = 3
        static let buttonFadeInAnimationDuration: CGFloat = 0.5
    }

    private lazy var animationView: AnimationView = {
        let animationView = AnimationView(name: "Paperplane")
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.heightAnchor.constraint(equalToConstant: Constants.animationDimension).isActive = true
        animationView.widthAnchor.constraint(equalToConstant: Constants.animationDimension).isActive = true
        return animationView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stackScrollView.add(arrangedSubview: animationView)
        configureButton()
        playAnimation()
        NotificationCenter.default.addObserver(self, selector: #selector(playAnimation), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
 
    private func configureButton() {
        footerButtons.first?.setAlpha(0)
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.buttonFadeInDelay) {
            UIView.animate(withDuration: Constants.buttonFadeInAnimationDuration, delay: 0, options: .curveEaseInOut) {
                self.footerButtons.first?.setAlpha(1)
            }
        }
    }
    
    @objc func playAnimation() {
        animationView.play()
    }
}
