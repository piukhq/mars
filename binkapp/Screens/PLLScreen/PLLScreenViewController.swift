//
//  PLLViewController.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class PLLScreenViewController: UIViewController {
    @IBOutlet private weak var brandHeaderView: BrandHeaderView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var primaryMessageLabel: UILabel!
    @IBOutlet private weak var secondaryMesageLabel: UILabel!
    @IBOutlet private weak var floatingButtonsView: BinkFloatingButtonsView!
    @IBOutlet private weak var paymentCardsTableView: UITableView!
    
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
        floatingButtonsView.delegate = self
        configureBrandHeader()
        configureUI()
        paymentCardsTableView.register(UINib(nibName: "PaymentCardCell", bundle: Bundle(for: PaymentCardCell.self)), forCellReuseIdentifier: "PaymentCardCell")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
}

// MARK: - Loyalty button delegate

extension PLLScreenViewController: LoyaltyButtonDelegate {
    func brandHeaderViewWasTapped(_ brandHeaderView: BrandHeaderView) {
        viewModel.displaySimplePopup(title: ((viewModel.getMembershipPlan().account?.planNameCard) ?? ""), message: (viewModel.getMembershipPlan().account?.planDescription) ?? "")
    }
}

// MARK: - BinkFloatingButtonsViewDelegate

extension PLLScreenViewController: BinkFloatingButtonsViewDelegate {
    func binkFloatingButtonsPrimaryButtonWasTapped(_ floatingButtons: BinkFloatingButtonsView) {
        viewModel.toFullDetailsCardScreen()
    }
    
    func binkFloatingButtonsSecondaryButtonWasTapped(_ floatingButtons: BinkFloatingButtonsView) {
        viewModel.displaySimplePopup(title: "error_title".localized, message: "to_be_implemented_message".localized)
    }
}

// MARK: - UITableViewDataSource

extension PLLScreenViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let paymentCards = viewModel.paymentCards {
            return paymentCards.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentCardCell", for: indexPath) as! PaymentCardCell
        if let paymentCard = viewModel.paymentCards?[indexPath.row] {
            cell.configureUI(paymentCard: paymentCard)
        }
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
        brandHeaderView.configure(imageURLString: membershipPlan.firstIconImage()?.url, loyaltyPlanNameCard: (membershipPlan.account?.planNameCard ?? nil), delegate: self)
    }
    
    func configureUI(){
        navigationController?.setNavigationBarHidden(viewModel.isEmptyPll, animated: false)
        titleLabel.text = viewModel.isEmptyPll ? "pll_screen_link_title".localized : "pll_screen_add_title".localized
        primaryMessageLabel.text = viewModel.isEmptyPll ? "pll_screen_link_message".localized : "pll_screen_link_message".localized
        secondaryMesageLabel.isHidden = viewModel.isEmptyPll
        paymentCardsTableView.isHidden = viewModel.isEmptyPll
        viewModel.isEmptyPll ? floatingButtonsView.configure(primaryButtonTitle: "Done", secondaryButtonTitle: "Add payment cards") : floatingButtonsView.configure(primaryButtonTitle: "Done", secondaryButtonTitle: nil)
    }
    
}

