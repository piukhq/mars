//
//  PLLViewController.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class PLLScreenViewController: UIViewController {
    @IBOutlet private weak var brandHeaderView: BrandHeaderView!
    @IBOutlet private weak var floatingButtonsView: BinkPrimarySecondaryButtonView!
    
    private let viewModel: PLLScreenViewModel
    
    init(viewModel: PLLScreenViewModel) {
        self.viewModel = viewModel
        super.init(nibName: "PLLScreenViewController", bundle: Bundle(for: PLLScreenViewController.self))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureBrandHeader()
        navigationController?.setNavigationBarHidden(true, animated: false)

        floatingButtonsView.configure(primaryButtonTitle: "Done", secondaryButtonTitle: "Add payment cards", floating: true)
        floatingButtonsView.delegate = self

        configureUI()
    }

    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: false)
    }

    private func configureUI() {
        floatingButtonsView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            floatingButtonsView.leftAnchor.constraint(equalTo: view.leftAnchor),
            floatingButtonsView.rightAnchor.constraint(equalTo: view.rightAnchor),
            floatingButtonsView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -LayoutHelper.PrimarySecondaryButtonView.bottomPadding),
            floatingButtonsView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }
}

// MARK: - Loyalty button delegate

extension PLLScreenViewController: LoyaltyButtonDelegate {
    func brandHeaderViewWasTapped(_ brandHeaderView: BrandHeaderView) {
        viewModel.displaySimplePopup(title: ((viewModel.getMembershipPlan().account?.planNameCard) ?? ""), message: (viewModel.getMembershipPlan().account?.planDescription) ?? "")
    }
}

    // MARK: - Private methods

private extension PLLScreenViewController {
    func configureBrandHeader() {
        let membershipPlan = viewModel.getMembershipPlan()
        brandHeaderView.configure(imageURLString: membershipPlan.firstIconImage()?.url, loyaltyPlanNameCard: (membershipPlan.account?.planNameCard ?? nil), delegate: self)
    }
}

// MARK: - Floating buttons delegate

extension PLLScreenViewController: BinkPrimarySecondaryButtonViewDelegate {
    func binkFloatingButtonsPrimaryButtonWasTapped(_ floatingButtons: BinkPrimarySecondaryButtonView) {
        viewModel.toFullDetailsCardScreen()
    }

    func binkFloatingButtonsSecondaryButtonWasTapped(_ floatingButtons: BinkPrimarySecondaryButtonView) {
        viewModel.displaySimplePopup(title: "Error", message: "Not Implemented")
    }
}
