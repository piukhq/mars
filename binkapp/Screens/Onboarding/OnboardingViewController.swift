//
//  OnboardingViewController.swift
//  binkapp
//
//  Created by Nick Farrant on 21/10/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class OnboardingViewModel {
    private let router: MainScreenRouter
    private let repository: LoginRepository

    private let fallbackUserEmail = "Bink20iteration1@testbink.com"

    private var userEmail: String {
        guard let userEmail = Current.userDefaults.string(forKey: "userEmail") else {
            Current.userDefaults.set(fallbackUserEmail, forKey: "userEmail")
            return fallbackUserEmail
        }
        return userEmail
    }

    init(router: MainScreenRouter, repository: LoginRepository) {
        self.router = router
        self.repository = repository
    }

    func login() {
        repository.register(email: userEmail) { [weak self] in
            guard let self = self else { return }
            self.router.toMainScreen()
        }
    }
}

class OnboardingViewController: UIViewController {
    @IBOutlet private weak var facebookPillButton: BinkPillButton!
    @IBOutlet private weak var floatingButtonsView: BinkFloatingButtonsView!

    private let viewModel: OnboardingViewModel

    init(viewModel: OnboardingViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
    }

    private func configureUI() {
        facebookPillButton.configureForType(.facebook)
        facebookPillButton.addTarget(self, action: #selector(handleFacebookButtonPressed), for: .touchUpInside)

        floatingButtonsView.configure(primaryButtonTitle: "Sign up with email", secondaryButtonTitle: "Log in with email")
        floatingButtonsView.delegate = self

        facebookPillButton.translatesAutoresizingMaskIntoConstraints = false
        floatingButtonsView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            floatingButtonsView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            floatingButtonsView.heightAnchor.constraint(equalToConstant: LayoutHelper.FloatingButtons.height),
            floatingButtonsView.widthAnchor.constraint(equalToConstant: LayoutHelper.FloatingButtons.width),
            floatingButtonsView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            facebookPillButton.heightAnchor.constraint(equalToConstant: LayoutHelper.PillButton.height),
            facebookPillButton.widthAnchor.constraint(equalToConstant: LayoutHelper.PillButton.width),
            facebookPillButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            facebookPillButton.bottomAnchor.constraint(equalTo: floatingButtonsView.topAnchor, constant: -LayoutHelper.PillButton.verticalSpacing)
        ])
    }

    // MARK: Button handlers

    @objc private func handleFacebookButtonPressed() {
        print("Facebook login not implemented")
    }
}

extension OnboardingViewController: BinkFloatingButtonsViewDelegate {
    func binkFloatingButtonsPrimaryButtonWasTapped(_ floatingButtons: BinkFloatingButtonsView) {
        print("Sign up with email not implemented")
    }

    func binkFloatingButtonsSecondaryButtonWasTapped(_ floatingButtons: BinkFloatingButtonsView) {
        viewModel.login()
    }
}
