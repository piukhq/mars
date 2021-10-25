//
//  CheckYourInboxViewController.swift
//  binkapp
//
//  Created by Sean Williams on 25/10/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import Lottie
import UIKit

class CheckYourInboxViewController: BinkViewController {
    enum Constants {
        static let animationDimension: CGFloat = 330
        static let horizontalInset: CGFloat = 25
        static let bottomInset: CGFloat = 140
        static let buttonFadeInDelay: CGFloat = 3
        static let buttonFadeInAnimationDuration: CGFloat = 0.5
    }
    
    private lazy var stackScrollView: StackScrollView = {
        let stackView = StackScrollView(axis: .vertical, arrangedSubviews: [textView, animationView], adjustForKeyboard: true)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = .clear
        stackView.margin = UIEdgeInsets(top: 0, left: Constants.horizontalInset, bottom: 0, right: Constants.horizontalInset)
        stackView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: Constants.bottomInset, right: 0)
        stackView.distribution = .fill
        stackView.alignment = .fill
        view.addSubview(stackView)
        return stackView
    }()
    
    private lazy var textView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isScrollEnabled = false
        textView.isUserInteractionEnabled = false
        textView.isEditable = false
        textView.backgroundColor = .clear
        return textView
    }()
    
    private lazy var animationView: AnimationView = {
        let animationView = AnimationView(name: "Paperplane")
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.heightAnchor.constraint(equalToConstant: Constants.animationDimension).isActive = true
        animationView.widthAnchor.constraint(equalToConstant: Constants.animationDimension).isActive = true
        return animationView
    }()
    
    private var viewModel: CheckYourInboxViewModel
    
    init(viewModel: CheckYourInboxViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureButton()
        animationView.play()
    }

    override func configureForCurrentTheme() {
        super.configureForCurrentTheme()
        textView.textColor = Current.themeManager.color(for: .text)
    }
    
    private func configureUI() {
        textView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: Constants.bottomInset, right: 0)
        textView.attributedText = viewModel.text
        textView.linkTextAttributes = [.foregroundColor: UIColor.blueAccent, .underlineStyle: NSUnderlineStyle.single.rawValue]
        
        NSLayoutConstraint.activate([
            stackScrollView.topAnchor.constraint(equalTo: view.topAnchor),
            stackScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stackScrollView.leftAnchor.constraint(equalTo: view.leftAnchor),
            stackScrollView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
    }
    
    private func configureButton() {
        if let primaryTitle = viewModel.primaryButtonTitle, let primaryAction = viewModel.primaryButtonAction {
            let button = BinkButton(type: .gradient, title: primaryTitle, action: primaryAction)
            button.setAlpha(0)
            DispatchQueue.main.asyncAfter(deadline: .now() + Constants.buttonFadeInDelay) {
                UIView.animate(withDuration: Constants.buttonFadeInAnimationDuration, delay: 0, options: .curveEaseInOut) {
                    button.setAlpha(1)
                }
            }
            footerButtons.append(button)
        }
    }
}
