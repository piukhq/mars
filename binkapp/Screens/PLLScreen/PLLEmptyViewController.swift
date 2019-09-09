//
//  PLLViewController.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class PLLEmptyViewController: UIViewController {
    @IBOutlet private weak var brandHeaderView: BrandHeaderView!
    
    private let viewModel: PLLViewModel
    
    init(viewModel: PLLViewModel) {
        self.viewModel = viewModel
        super.init(nibName: "PLLEmptyViewController", bundle: Bundle(for: PLLEmptyViewController.self))
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
        viewModel.displaySimplePopup(title: "Error", message: "Not Implemented")
    }
}

// MARK: - Loyalty button delegate

extension PLLEmptyViewController: LoyaltyButtonDelegate {
    func buttonWasPressed() {
        viewModel.displaySimplePopup(title: ((viewModel.getMembershipPlan().account?.planNameCard) ?? ""), message: (viewModel.getMembershipPlan().account?.planDescription) ?? "")
    }
}

// MARK: - Private methods

private extension PLLEmptyViewController {
    func configureBrandHeader() {
        let membershipPlan = viewModel.getMembershipPlan()
        if let imageUrlString = membershipPlan.images?.first(where: { $0.type == 3 })?.url {
            brandHeaderView.configure(imageURLString: imageUrlString, loyaltyPlanNameCard: (membershipPlan.account?.planNameCard ?? nil), delegate: self)
        }
    }
}


