//
//  PLLViewController.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class PLLScreenViewController: UIViewController {
    @IBOutlet private weak var brandHeaderView: BrandHeaderView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var primaryMessageLabel: UILabel!
    @IBOutlet weak var secondaryMesageLabel: UILabel!
    @IBOutlet weak var floatingButtonsView: BinkFloatingButtonsView!
    @IBOutlet weak var paymentCardsTableView: UITableView!
    
    private let viewModel: PLLScreenViewModel
    private let isEmpty: Bool
    private let paymentCards: [PaymentCardModel]
    
    init(viewModel: PLLScreenViewModel, isEmpty: Bool, paymentCards: [PaymentCardModel]? = nil) {
        self.viewModel = viewModel
        self.isEmpty = isEmpty
        self.paymentCards = paymentCards ?? []
        super.init(nibName: "PLLScreenViewController", bundle: Bundle(for: PLLScreenViewController.self))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureBrandHeader()
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: false)
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
    func brandHeaderViewWasTapped(_ brandHeaderView: BrandHeaderView) {
        viewModel.displaySimplePopup(title: ((viewModel.getMembershipPlan().account?.planNameCard) ?? ""), message: (viewModel.getMembershipPlan().account?.planDescription) ?? "")
    }
}

// MARK: - UITableViewDataSource

extension PLLScreenViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return paymentCards.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = PaymentCardCell()
        return cell
    }
}

// MARK: - UITableViewDelegate

extension PLLScreenViewController: UITableViewDelegate {
    
}

// MARK: - Private methods

private extension PLLScreenViewController {
    func configureBrandHeader() {
        let membershipPlan = viewModel.getMembershipPlan()
        let imageUrlString = membershipPlan.images?.first(where: { $0.type == ImageType.icon.rawValue })?.url
        brandHeaderView.configure(imageURLString: imageUrlString, loyaltyPlanNameCard: (membershipPlan.account?.planNameCard ?? nil), delegate: self)
    }
}

