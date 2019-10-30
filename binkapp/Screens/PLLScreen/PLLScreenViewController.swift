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
    
    // MARK: - Properties
    
    private let viewModel: PLLScreenViewModel
    private let journey: PllScreenJourney
    
    private lazy var stackScroll: StackScrollView = {
        let stackScroll = StackScrollView(
            axis: .vertical,
            arrangedSubviews: [brandHeaderView, titleLabel, primaryMessageLabel, secondaryMessageLabel, paymentCardsTableView],
            adjustForKeyboard: false
        )
        stackScroll.translatesAutoresizingMaskIntoConstraints = false
        stackScroll.alignment = .center
        stackScroll.customPadding(25.0, after: brandHeaderView)
        view.addSubview(stackScroll)
        return stackScroll
    }()
    
    private lazy var brandHeaderView: BrandHeaderView = {
        let brandHeader = BrandHeaderView()
        brandHeader.heightAnchor.constraint(equalToConstant: 110).isActive = true
        return brandHeader
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.headline
        label.textAlignment = .left
        return label
    }()
    
    private lazy var primaryMessageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.bodyTextLarge
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var secondaryMessageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.bodyTextLarge
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var paymentCardsTableView: NestedTableView = {
        let tableView = NestedTableView(frame: .zero)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = 100.0
        tableView.dataSource = self
        tableView.separatorStyle = .none
        return tableView
    }()
    
    private lazy var floatingButtonsView: BinkPrimarySecondaryButtonView = {
        let floatingButtonsView = BinkPrimarySecondaryButtonView(frame: .zero)
        floatingButtonsView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(floatingButtonsView)
        return floatingButtonsView
    }()
    
    // MARK: - Initialisation
    
    init(viewModel: PLLScreenViewModel, journey: PllScreenJourney) {
        self.viewModel = viewModel
        self.journey = journey
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let backButton = UIBarButtonItem(image: UIImage(named: "navbarIconsBack"), style: .plain, target: self, action: #selector(popViewController))
        navigationItem.leftBarButtonItem = backButton
        view.backgroundColor = .white
        
        configureBrandHeader()
        configureLayout()
        configureUI()
        paymentCardsTableView.register(PaymentCardCell.self, asNib: true)
        floatingButtonsView.delegate = self
    }

    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    private func configureLayout() {
        NSLayoutConstraint.activate([
            stackScroll.topAnchor.constraint(equalTo: view.topAnchor),
            stackScroll.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stackScroll.leftAnchor.constraint(equalTo: view.leftAnchor),
            stackScroll.rightAnchor.constraint(equalTo: view.rightAnchor),
            paymentCardsTableView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -50.0),
            titleLabel.leftAnchor.constraint(equalTo: stackScroll.leftAnchor, constant: 25),
            titleLabel.rightAnchor.constraint(equalTo: stackScroll.rightAnchor, constant: -25),
            primaryMessageLabel.leftAnchor.constraint(equalTo: stackScroll.leftAnchor, constant: 25),
            primaryMessageLabel.rightAnchor.constraint(equalTo: stackScroll.rightAnchor, constant: -25),
            secondaryMessageLabel.leftAnchor.constraint(equalTo: stackScroll.leftAnchor, constant: 25),
            secondaryMessageLabel.rightAnchor.constraint(equalTo: stackScroll.rightAnchor, constant: -25),
            brandHeaderView.widthAnchor.constraint(equalTo: view.widthAnchor),
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
        viewModel.brandHeaderWasTapped()
    }
}

// MARK: - BinkFloatingButtonsViewDelegate

extension PLLScreenViewController: BinkPrimarySecondaryButtonViewDelegate {
    func binkFloatingButtonsPrimaryButtonWasTapped(_ floatingButtons: BinkPrimarySecondaryButtonView) {
        floatingButtons.primaryButton.startLoading()
        view.isUserInteractionEnabled = false
        viewModel.toggleLinkForMembershipCards { [weak self] in
            guard let self = self else { return }
            self.reloadContent()
            self.view.isUserInteractionEnabled = true
            floatingButtons.primaryButton.stopLoading()
            self.navigateToLCDScreen()
        }
    }
    
    func binkFloatingButtonsSecondaryButtonWasTapped(_ floatingButtons: BinkPrimarySecondaryButtonView) {
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
        secondaryMessageLabel.text = viewModel.secondaryMessageText
        secondaryMessageLabel.isHidden = !viewModel.isEmptyPll
        paymentCardsTableView.isHidden = viewModel.isEmptyPll
        stackScroll.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: LayoutHelper.PrimarySecondaryButtonView.height, right: 0)
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
