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
    @IBOutlet private weak var floatingButtonsViewHeightConstraint: NSLayoutConstraint!
    
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
        let backButton = UIBarButtonItem(image: UIImage(named: "navbarIconsBack"), style: .plain, target: self, action: #selector(popViewController))
        navigationItem.leftBarButtonItem = backButton
        
        floatingButtonsView.delegate = self
        configureBrandHeader()
        configureUI()
        paymentCardsTableView.register(PaymentCardCell.self, asNib: true)
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
        let activityIndicator = UIActivityIndicatorView(frame: view.frame)
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        viewModel.toggleLinkForMembershipCards {
            self.reloadContent()
            self.viewModel.toFullDetailsCardScreen()
            activityIndicator.removeFromSuperview()
        }
    }
    
    func binkFloatingButtonsSecondaryButtonWasTapped(_ floatingButtons: BinkFloatingButtonsView) {
        viewModel.toAddPaymentCardScreen()
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
        let cell: PaymentCardCell = tableView.dequeue(indexPath: indexPath)
        if let paymentCard = viewModel.paymentCards?[indexPath.row] {
            cell.configureUI(membershipCard: viewModel.getMembershipCard(), paymentCard: paymentCard, cardIndex: indexPath.row, delegate: self, isAddJourney: viewModel.isAddJourney)
            if viewModel.isAddJourney {
                viewModel.addCardToChangedCardsArray(card: paymentCard)
            }
        }
        return cell 
    }
}

// MARK: - Private methods

private extension PLLScreenViewController {
    @objc func popViewController() {
        viewModel.popViewController()
    }
    
    func reloadContent() {
        viewModel.reloadPaymentCards()
        paymentCardsTableView.reloadData()
    }
    
    func configureBrandHeader() {
        let membershipPlan = viewModel.getMembershipPlan()
        brandHeaderView.configure(imageURLString: membershipPlan.firstIconImage()?.url, loyaltyPlanNameCard: (membershipPlan.account?.planNameCard ?? nil), delegate: self)
    }
    
    func configureUI() {
        navigationController?.setNavigationBarHidden(viewModel.isEmptyPll || viewModel.isAddJourney, animated: false)
        titleLabel.text = viewModel.isEmptyPll ? "pll_screen_link_title".localized : "pll_screen_add_title".localized
        primaryMessageLabel.text = viewModel.isEmptyPll ? "pll_screen_link_message".localized : "pll_screen_add_message".localized
        secondaryMesageLabel.isHidden = !viewModel.isEmptyPll
        paymentCardsTableView.isHidden = viewModel.isEmptyPll
        floatingButtonsViewHeightConstraint.constant = viewModel.isEmptyPll ? 210.0 : 130.0
        paymentCardsTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: floatingButtonsViewHeightConstraint.constant, right: 0)
        viewModel.isEmptyPll ? floatingButtonsView.configure(primaryButtonTitle: "done".localized, secondaryButtonTitle: "pll_screen_add_cards_button_title".localized) : floatingButtonsView.configure(primaryButtonTitle: "done".localized, secondaryButtonTitle: nil)
    }
}

// MARK: - PaymentCardCellDelegat3

extension PLLScreenViewController: PaymentCardCellDelegate {
    func paymentCardCellDidToggleSwitch(_ paymentCell: PaymentCardCell, cardIndex: Int) {
        if let paymentCards = viewModel.paymentCards {
            viewModel.addCardToChangedCardsArray(card: paymentCards[cardIndex])
        }
    }
}

