//
//  PLLViewController.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

enum PllScreenJourney {
    case newCard
    case existingCard
}

class PLLScreenViewController: UIViewController {
    @IBOutlet private weak var brandHeaderView: BrandHeaderView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var primaryMessageLabel: UILabel!
    @IBOutlet private weak var secondaryMesageLabel: UILabel!
    @IBOutlet private weak var floatingButtonsView: BinkFloatingButtonsView!
    @IBOutlet private weak var paymentCardsTableView: UITableView!
    @IBOutlet private weak var floatingButtonsViewHeightConstraint: NSLayoutConstraint!
    
    private let viewModel: PLLScreenViewModel
    private let journey: PllScreenJourney
    
    init(viewModel: PLLScreenViewModel, journey: PllScreenJourney) {
        self.viewModel = viewModel
        self.journey = journey
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
        viewModel.brandHeaderWasTapped()
    }
}

// MARK: - BinkFloatingButtonsViewDelegate

extension PLLScreenViewController: BinkFloatingButtonsViewDelegate {
    func binkFloatingButtonsPrimaryButtonWasTapped(_ floatingButtons: BinkFloatingButtonsView) {
        floatingButtons.primaryButton.startLoading()
        view.isUserInteractionEnabled = false
        viewModel.toggleLinkForMembershipCards { [weak self] in
            guard let self = self else {return}
            self.reloadContent()
            self.view.isUserInteractionEnabled = true
            floatingButtons.primaryButton.stopLoading()
            self.navigateToLCDScreen()
        }
    }
    
    func binkFloatingButtonsSecondaryButtonWasTapped(_ floatingButtons: BinkFloatingButtonsView) {
        viewModel.toAddPaymentCardScreen()
    }
}

// MARK: - UITableViewDataSource

extension PLLScreenViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let paymentCards = viewModel.paymentCards {
            return paymentCards.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: PaymentCardCell = tableView.dequeue(indexPath: indexPath)
        if let paymentCards = viewModel.paymentCards {
            let paymentCard = paymentCards[indexPath.row]
            let isLastCell = indexPath.row == paymentCards.count - 1
            cell.configureUI(membershipCard: viewModel.getMembershipCard(), paymentCard: paymentCard, cardIndex: indexPath.row, delegate: self, journey: journey, isLastCell: isLastCell)
            if journey == .newCard {
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
        brandHeaderView.configure(imageURLString: membershipPlan?.firstIconImage()?.url, loyaltyPlanNameCard: (membershipPlan?.account?.planNameCard ?? nil), delegate: self)
    }
    
    func configureUI() {
        navigationController?.setNavigationBarHidden(viewModel.isNavigationVisisble, animated: false)
        titleLabel.text = viewModel.titleText
        primaryMessageLabel.text = viewModel.primaryMessageText
        secondaryMesageLabel.isHidden = !viewModel.isEmptyPll
        paymentCardsTableView.isHidden = viewModel.isEmptyPll
        floatingButtonsViewHeightConstraint.constant = viewModel.isEmptyPll ? 210.0 : 130.0
        paymentCardsTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: floatingButtonsViewHeightConstraint.constant, right: 0)
        viewModel.isEmptyPll ? floatingButtonsView.configure(primaryButtonTitle: "done".localized, secondaryButtonTitle: "pll_screen_add_cards_button_title".localized) : floatingButtonsView.configure(primaryButtonTitle: "done".localized, secondaryButtonTitle: nil)
    }
    
    func navigateToLCDScreen() {
        switch journey {
        case .newCard:
            viewModel.toFullDetailsCardScreen()
            break
        case .existingCard:
            viewModel.popViewController()
            break
        }
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

