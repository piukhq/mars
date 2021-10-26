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
        animationView.play()
        NotificationCenter.default.addObserver(self, selector: #selector(playAnimation), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    private func configureButton() {
        let availableEmailClients = EmailClient.availableEmailClientsForDevice()
        var button: BinkButton
        
        if availableEmailClients.count == 1 {
            let buttonTitle = L10n.openMailButtonTitle(availableEmailClients.first?.rawValue.capitalized ?? "")
            button = BinkButton(type: .gradient, title: buttonTitle, action: {
                availableEmailClients.first?.open()
            })
        } else if availableEmailClients.count > 1 {
            button = BinkButton(type: .gradient, title: L10n.openMailButtonTitleMultipleClients, action: {
                let alert = ViewControllerFactory.makeEmailClientsAlertController(availableEmailClients)
                let navigationRequest = AlertNavigationRequest(alertController: alert)
                Current.navigate.to(navigationRequest)
            })
        } else {
            return
        }
        
        button.setAlpha(0)
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.buttonFadeInDelay) {
            UIView.animate(withDuration: Constants.buttonFadeInAnimationDuration, delay: 0, options: .curveEaseInOut) {
                button.setAlpha(1)
            }
        }
        
        footerButtons.append(button)
    }
    
    @objc func playAnimation() {
        animationView.play()
    }
}
