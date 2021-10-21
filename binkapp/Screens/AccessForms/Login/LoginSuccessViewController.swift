//
//  LoginSuccessViewController.swift
//  binkapp
//
//  Created by Sean Williams on 20/07/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import Lottie
import UIKit

class LoginSuccessViewController: BinkViewController, UserServiceProtocol, CheckboxViewDelegate {
    enum Constants {
        static let animationDimension: CGFloat = 300
        static let horizontalInset: CGFloat = 25.0
        static let bottomInset: CGFloat = 150.0
        static let postTextViewPadding: CGFloat = 15.0
    }
    
    private lazy var continueButton: BinkButton = {
        return BinkButton(type: .gradient, title: L10n.continueButtonTitle) { [weak self] in
            self?.continueButtonTapped()
        }
    }()
    
    private lazy var stackScrollView: StackScrollView = {
        let stackView = StackScrollView(axis: .vertical, arrangedSubviews: [animationView, titleLabel, textView], adjustForKeyboard: true)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = .clear
        stackView.margin = UIEdgeInsets(top: 0, left: Constants.horizontalInset, bottom: 0, right: Constants.horizontalInset)
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: Constants.bottomInset, right: 0)
        stackView.customPadding(Constants.postTextViewPadding, after: textView)
        view.addSubview(stackView)
        return stackView
    }()
    
    private lazy var titleLabel: UILabel = {
        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.font = UIFont.headline
        title.numberOfLines = 0
        return title
    }()
    
    private lazy var textView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isScrollEnabled = false
        textView.isUserInteractionEnabled = true
        textView.isEditable = false
        textView.backgroundColor = .clear
        textView.textContainerInset = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: -5)
        textView.linkTextAttributes = [.foregroundColor: UIColor.blueAccent, .underlineStyle: NSUnderlineStyle.single.rawValue]
        return textView
    }()
 
    private lazy var animationView: AnimationView = {
        let animationView = AnimationView(name: "success")
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .playOnce
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.heightAnchor.constraint(equalToConstant: Constants.animationDimension).isActive = true
        animationView.widthAnchor.constraint(equalToConstant: Constants.animationDimension).isActive = true
        return animationView
    }()
    
    private var checkboxes: [CheckboxView] = []
    
    init() {
        let emailAddress = Current.userManager.currentEmailAddress
        let attributedBody = NSMutableAttributedString(string: L10n.loginSuccesSubtitle(emailAddress ?? L10n.nilEmailAddress), attributes: [.font: UIFont.bodyTextLarge])
        let baseBody = NSString(string: attributedBody.string)
        let emailRange = baseBody.range(of: emailAddress ?? "")
        let attributes: [NSAttributedString.Key: Any] = [.font: UIFont(name: "NunitoSans-ExtraBold", size: 18.0) ?? UIFont()]
        attributedBody.addAttributes(attributes, range: emailRange)
        super.init(nibName: nil, bundle: nil)
        titleLabel.text = L10n.loginSuccessTitle
        textView.attributedText = attributedBody
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureLayout()
        configureCheckboxes()
        stackScrollView.alignment = .center
        textView.textAlignment = .center
        footerButtons = [continueButton]
        animationView.play()
    }
    
    override func configureForCurrentTheme() {
        super.configureForCurrentTheme()
        titleLabel.textColor = .binkBlueTitleText
    }
    
    private func configureLayout() {
        NSLayoutConstraint.activate([
            stackScrollView.topAnchor.constraint(equalTo: view.topAnchor),
            stackScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stackScrollView.leftAnchor.constraint(equalTo: view.leftAnchor),
            stackScrollView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
    }
    
    private func configureCheckboxes() {
        let attributedMarketing = NSMutableAttributedString(string: L10n.marketingTitle + "\n" + L10n.preferencesPrompt, attributes: [.font: UIFont.bodyTextSmall])
        let baseMarketing = NSString(string: attributedMarketing.string)
        let rewardsRange = baseMarketing.range(of: L10n.preferencesPromptHighlightRewards)
        let offersRange = baseMarketing.range(of: L10n.preferencesPromptHighlightOffers)
        let updatesRange = baseMarketing.range(of: L10n.preferencesPromptHighlightUpdates)
        
        let attributes: [NSAttributedString.Key: Any] = [.font: UIFont(name: "NunitoSans-ExtraBold", size: 14.0) ?? UIFont()]
        
        attributedMarketing.addAttributes(attributes, range: rewardsRange)
        attributedMarketing.addAttributes(attributes, range: offersRange)
        attributedMarketing.addAttributes(attributes, range: updatesRange)
        
        let marketingCheckbox = CheckboxView(checked: false)
        marketingCheckbox.configure(title: attributedMarketing, columnName: "marketing-bink", columnKind: .userPreference, delegate: self, optional: true)
        checkboxes.append(marketingCheckbox)
        stackScrollView.add(arrangedSubview: marketingCheckbox)
    }
    
    @objc func continueButtonTapped() {
        continueButton.toggleLoading(isLoading: true)
        
        let preferenceCheckbox = checkboxes.filter { $0.columnKind == .userPreference }
        var params: [String: String] = [:]
        
        preferenceCheckbox.forEach {
            if let columnName = $0.columnName {
                params[columnName] = $0.value
            }
        }
        
        guard !params.isEmpty else {
            Current.navigate.close()
            return
        }
        setPreferences(params: params)
        Current.navigate.close()
    }
}
