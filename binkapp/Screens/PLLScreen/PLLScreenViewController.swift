//
//  PLLViewController.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class PLLScreenViewController: UIViewController {
    @IBOutlet private weak var brandHeaderView: BrandHeaderView!
    
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
    }
    
    // MARK: - Actions
    
    @IBAction func addPaymentCardsButtonTapped(_ sender: Any) {
        viewModel.displaySimplePopup(title: "Error", message: "Not Implemented")
    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        viewModel.toFullDetailsCardScreen()
    }
}

// MARK: - Loyalty button delegate

extension PLLScreenViewController: LoyaltyButtonDelegate {
    func brandHeaderViewDidTap(_ brandHeaderView: BrandHeaderView) {
        viewModel.displaySimplePopup(title: ((viewModel.getMembershipPlan().account?.planNameCard) ?? ""), message: (viewModel.getMembershipPlan().account?.planDescription) ?? "")
    }
}

// MARK: - Private methods

private extension PLLScreenViewController {
    func configureBrandHeader() {
        let membershipPlan = viewModel.getMembershipPlan()
        let imageUrlString = membershipPlan.images?.first(where: { $0.type == ImageType.icon.rawValue })?.url
        brandHeaderView.configure(imageURLString: imageUrlString, loyaltyPlanNameCard: (membershipPlan.account?.planNameCard ?? nil), delegate: self)
    }
}

