//
//  PaymentTermsAndConditionsViewController.swift
//  binkapp
//
//  Created by Dorin Pop on 17/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

protocol PaymentTermsAndConditionsViewControllerDelegate: AnyObject {
    func paymentTermsAndConditionsViewControllerDidAccept(_ viewController: PaymentTermsAndConditionsViewController)
}

class PaymentTermsAndConditionsViewController: UIViewController {
    @IBOutlet private weak var floatingButtonsContainer: BinkFloatingButtonsView!
    @IBOutlet private weak var textView: UITextView!

    weak var delegate: PaymentTermsAndConditionsViewControllerDelegate?
    
    private let viewModel: ReusableModalViewModel
    
    init(viewModel: ReusableModalViewModel, delegate: PaymentTermsAndConditionsViewControllerDelegate? = nil) {
        self.viewModel = viewModel
        self.delegate = delegate
        super.init(nibName: "PaymentTermsAndConditionsViewController", bundle: Bundle(for: PaymentTermsAndConditionsViewController.self))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        floatingButtonsContainer.delegate = self
        textView.delegate = self
        configureUI()
    }
    
    override func viewDidLayoutSubviews() {
        textView.setContentOffset(.zero, animated: false)
    }
    
    private func configureUI() {
        setCloseButton()
        let primary = viewModel.primaryButtonTitle
        let secondary = viewModel.secondaryButtonTitle
        let showingButtons = viewModel.primaryButtonTitle != nil || viewModel.secondaryButtonTitle != nil
        textView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: showingButtons ? 209 : 140, right: 0)
        textView.attributedText = viewModel.text
        textView.linkTextAttributes = [.foregroundColor: UIColor.blueAccent, .underlineStyle: NSUnderlineStyle.single.rawValue]
        
        floatingButtonsContainer.configure(
            primaryButtonTitle: primary,
            secondaryButtonTitle: secondary
        )
    }
}

// MARK: - Private methods

private extension PaymentTermsAndConditionsViewController {
    func setCloseButton() {
        if viewModel.showCloseButton {
                    let closeButton = UIBarButtonItem(image: UIImage(named: "close")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(dismissViewController))
            navigationItem.setRightBarButton(closeButton, animated: false)
        } else {
            self.navigationItem.setLeftBarButton(viewModel.tabBarBackButton, animated: true)
        }
    }
    
    @objc func popViewController() {
        viewModel.popViewController()
    }
    
    @objc func dismissViewController() {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - BinkFloatingButtonsDelegate

extension PaymentTermsAndConditionsViewController: BinkFloatingButtonsViewDelegate {
    func binkFloatingButtonsPrimaryButtonWasTapped(_: BinkFloatingButtonsView) {
        viewModel.mainButtonWasTapped() { [weak self] in
            guard let self = self, let delegate = self.delegate else { return }
            delegate.paymentTermsAndConditionsViewControllerDidAccept(self)
        }
    }
    
    func binkFloatingButtonsSecondaryButtonWasTapped(_: BinkFloatingButtonsView) {
        viewModel.secondaryButtonWasTapped()
    }
}

// MARK: - UITextViewDelegate

extension PaymentTermsAndConditionsViewController: UITextViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let textViewFont = textView.font {
            title = scrollView.contentOffset.y > textViewFont.lineHeight ? viewModel.title : ""
        }
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        return true
    }
}
