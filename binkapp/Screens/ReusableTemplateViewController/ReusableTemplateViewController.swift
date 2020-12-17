//
//  ReusableTemplateViewController.swift
//  binkapp
//
//  Created by Dorin Pop on 17/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit
import Firebase

protocol ReusableTemplateViewControllerDelegate: AnyObject {
    func primaryButtonWasTapped(_ viewController: ReusableTemplateViewController)
}

class ReusableTemplateViewController: BinkViewController, BarBlurring {
    lazy var blurBackground = defaultBlurredBackground()

    @IBOutlet private weak var textView: UITextView!

    weak var delegate: ReusableTemplateViewControllerDelegate?
    
    private let viewModel: ReusableModalViewModel
    
    init(viewModel: ReusableModalViewModel, delegate: ReusableTemplateViewControllerDelegate? = nil) {
        self.viewModel = viewModel
        self.delegate = delegate
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
        
        guard let bar = navigationController?.navigationBar else { return }
        prepareBarWithBlur(bar: bar, blurBackground: blurBackground)
    }
    
    private func configureUI() {
        textView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 140, right: 0)
        textView.attributedText = viewModel.text
        textView.linkTextAttributes = [.foregroundColor: UIColor.blueAccent, .underlineStyle: NSUnderlineStyle.single.rawValue]
        textView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            textView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 25),
            textView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -25),
            textView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func configureButtons() {
        var buttons: [BinkButton] = []

        if let primaryTitle = viewModel.primaryButtonTitle, let primaryAction = viewModel.primaryButtonAction {
            buttons.append(BinkButton(type: .gradient, title: primaryTitle, action: primaryAction))
        }

        if let secondaryTitle = viewModel.secondaryButtonTitle, let secondaryAction = viewModel.secondaryButtonAction {
            buttons.append(BinkButton(type: .gradient, title: secondaryTitle, action: secondaryAction))
        }

        buttonsView = BinkButtonsView(buttons: buttons)
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
