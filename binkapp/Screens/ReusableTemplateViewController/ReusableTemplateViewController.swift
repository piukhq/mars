//
//  ReusableTemplateViewController.swift
//  binkapp
//
//  Created by Dorin Pop on 17/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit
import Firebase

class ReusableTemplateViewController: BinkViewController {
    @IBOutlet private weak var textView: UITextView!
    
    lazy var stackScrollView: StackScrollView = {
        let stackView = StackScrollView(axis: .vertical, arrangedSubviews: [brandImageView, textView], adjustForKeyboard: true)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = .clear
        stackView.margin = UIEdgeInsets(top: 0, left: 25, bottom: 0, right: 25)
        stackView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 140, right: 0)
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.customPadding(20, after: brandImageView)
        view.addSubview(stackView)
        return stackView
    }()
    
    lazy var brandImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let viewModel: ReusableModalViewModel
    
    init(viewModel: ReusableModalViewModel) {
        self.viewModel = viewModel
        super.init(nibName: "ReusableTemplateViewController", bundle: Bundle(for: ReusableTemplateViewController.self))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        textView.delegate = self
        configureUI()
        configureButtons()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setScreenName(trackedScreen: .informationModal)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        textView.setContentOffset(.zero, animated: false)
    }
    
    override func configureForCurrentTheme() {
        super.configureForCurrentTheme()
        textView.textColor = Current.themeManager.color(for: .text)
    }
    
    private func configureUI() {
        textView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 140, right: 0)
        textView.attributedText = viewModel.text
        textView.linkTextAttributes = [.foregroundColor: UIColor.blueAccent, .underlineStyle: NSUnderlineStyle.single.rawValue]
        
        NSLayoutConstraint.activate([
            stackScrollView.topAnchor.constraint(equalTo: view.topAnchor),
            stackScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stackScrollView.leftAnchor.constraint(equalTo: view.leftAnchor),
            stackScrollView.rightAnchor.constraint(equalTo: view.rightAnchor),
            brandImageView.heightAnchor.constraint(equalToConstant: 100)
        ])
        
        guard let membershipPlan = viewModel.membershipPlan else {
            brandImageView.isHidden = true
            return
        }
        brandImageView.setImage(forPathType: .membershipPlanAlternativeHero(plan: membershipPlan))
    }

    private func configureButtons() {
        var buttons: [BinkButton] = []

        if let primaryTitle = viewModel.primaryButtonTitle, let primaryAction = viewModel.primaryButtonAction {
            buttons.append(BinkButton(type: .gradient, title: primaryTitle, action: primaryAction))
        }

        if let secondaryTitle = viewModel.secondaryButtonTitle, let secondaryAction = viewModel.secondaryButtonAction {
            buttons.append(BinkButton(type: .plain, title: secondaryTitle, action: secondaryAction))
        }

        footerButtons = buttons
    }
}

// MARK: - UITextViewDelegate

extension ReusableTemplateViewController: UITextViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let textViewFont = textView.font {
            title = scrollView.contentOffset.y > textViewFont.lineHeight ? viewModel.title : ""
        }
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        return true
    }
}
