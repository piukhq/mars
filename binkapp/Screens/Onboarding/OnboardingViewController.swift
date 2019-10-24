//
//  OnboardingViewController.swift
//  binkapp
//
//  Created by Nick Farrant on 21/10/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class OnboardingViewController: UIViewController {
    @IBOutlet private weak var facebookPillButton: BinkPillButton!
    @IBOutlet private weak var floatingButtonsView: BinkPrimarySecondaryButtonView!
    @IBOutlet private weak var learningContainer: UIView!

    private let scrollView = UIScrollView(frame: .zero)

    private let viewModel: OnboardingViewModel

    private var didLayoutSubviews = false

    init(viewModel: OnboardingViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !didLayoutSubviews {
            configureUI()
            didLayoutSubviews = true
        }
    }

    private func configureUI() {
        scrollView.clipsToBounds = false
        let views = [
            TestView(bgColor: .systemTeal),
            OnboardingLearningView(frame: .zero),
            TestView(bgColor: .systemOrange)
        ]
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        learningContainer.addSubview(scrollView)
        scrollView.frame = CGRect(x: 0, y: 0, width: learningContainer.frame.width, height: learningContainer.frame.height)
        scrollView.contentSize = CGSize(width: learningContainer.frame.width * CGFloat(views.count), height: learningContainer.frame.height)

        scrollView.bounces = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
//        scrollView.delegate = self

        scrollView.isPagingEnabled = true

        for i in 0..<views.count {
            views[i].frame = CGRect(x: learningContainer.frame.width * CGFloat(i), y: 0, width: learningContainer.frame.width, height: learningContainer.frame.height)
            scrollView.addSubview(views[i])
        }

        facebookPillButton.configureForType(.facebook)
        facebookPillButton.addTarget(self, action: #selector(handleFacebookButtonPressed), for: .touchUpInside)

        floatingButtonsView.configure(primaryButtonTitle: viewModel.signUpWithEmailButtonText, secondaryButtonTitle: viewModel.loginWithEmailButtonText)
        floatingButtonsView.delegate = self

        facebookPillButton.translatesAutoresizingMaskIntoConstraints = false
        floatingButtonsView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            floatingButtonsView.leftAnchor.constraint(equalTo: view.leftAnchor),
            floatingButtonsView.rightAnchor.constraint(equalTo: view.rightAnchor),
            floatingButtonsView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -LayoutHelper.PrimarySecondaryButtonView.bottomPadding),
            facebookPillButton.heightAnchor.constraint(equalToConstant: LayoutHelper.PillButton.height),
            facebookPillButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: LayoutHelper.PillButton.widthPercentage),
            facebookPillButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            facebookPillButton.bottomAnchor.constraint(equalTo: floatingButtonsView.topAnchor, constant: -LayoutHelper.PillButton.verticalSpacing),
        ])
    }

    // MARK: Button handlers

    @objc private func handleFacebookButtonPressed() {
        viewModel.notImplemented()
    }
}

extension OnboardingViewController: BinkPrimarySecondaryButtonViewDelegate {
    func binkFloatingButtonsPrimaryButtonWasTapped(_ floatingButtons: BinkPrimarySecondaryButtonView) {
        viewModel.notImplemented()
    }

    func binkFloatingButtonsSecondaryButtonWasTapped(_ floatingButtons: BinkPrimarySecondaryButtonView) {
        viewModel.login()
    }
}

class TestView: UIView {
    init(bgColor: UIColor) {
        super.init(frame: .zero)
        self.backgroundColor = bgColor
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
