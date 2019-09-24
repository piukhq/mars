//
//  PaymentTermsAndConditionsViewController.swift
//  binkapp
//
//  Created by Dorin Pop on 17/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class PaymentTermsAndConditionsViewController: UIViewController {
    @IBOutlet private weak var floatingButtonsContainer: BinkFloatingButtonsView!
    @IBOutlet private weak var textView: UITextView!
    
    private let viewModel: PaymentTermsAndConditionsViewModel
    
    init(viewModel: PaymentTermsAndConditionsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: "PaymentTermsAndConditionsViewController", bundle: Bundle(for: PaymentTermsAndConditionsViewController.self))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCloseButton()
        floatingButtonsContainer.delegate = self
        textView.delegate = self
        textView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 209, right: 0)
    }
    
    override func viewDidLayoutSubviews() {
        textView.setContentOffset(.zero, animated: false)
    }
    
    private func configureUI() {
        title = viewModel.title
        textView.text = viewModel.text
        textView.font = viewModel.font
    }
}

// MARK: - Private methods

private extension PaymentTermsAndConditionsViewController {
    func setCloseButton() {
        let closeButton = UIBarButtonItem(image: UIImage(named: "close")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(popViewController))
        self.navigationItem.setLeftBarButton(closeButton, animated: true)
    }
    
    @objc func popViewController() {
        viewModel.popViewController()
    }
}

// MARK: - BinkFloatingButtonsDelegate

extension PaymentTermsAndConditionsViewController: BinkFloatingButtonsViewDelegate {
    func binkFloatingButtonsPrimaryButtonWasTapped(_: BinkFloatingButtonsView) {
        viewModel.createCard()
    }
    
    func binkFloatingButtonsSecondaryButtonWasTapped(_: BinkFloatingButtonsView) {
        viewModel.toRootViewController()
    }
}

// MARK: - UITextViewDelegate

extension PaymentTermsAndConditionsViewController: UITextViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let textViewFont = textView.font {
            title = scrollView.contentOffset.y > textViewFont.lineHeight ? "terms_and_conditions_title".localized : ""
        }
    }
}
