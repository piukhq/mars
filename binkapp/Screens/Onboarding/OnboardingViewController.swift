//
//  OnboardingViewController.swift
//  binkapp
//
//  Created by Nick Farrant on 21/10/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class OnboardingViewController: UIViewController {
    @IBOutlet private weak var floatingButtonsView: BinkFloatingButtonsView!

    override func viewDidLoad() {
        super.viewDidLoad()

        floatingButtonsView.configure(primaryButtonTitle: "Sign up with email", secondaryButtonTitle: "Log in with email")
        floatingButtonsView.delegate = self
    }
}

extension OnboardingViewController: BinkFloatingButtonsViewDelegate {
    func binkFloatingButtonsPrimaryButtonWasTapped(_ floatingButtons: BinkFloatingButtonsView) {
        //
    }

    func binkFloatingButtonsSecondaryButtonWasTapped(_ floatingButtons: BinkFloatingButtonsView) {
        //
    }
}
