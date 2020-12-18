//
//  PLLViewController.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit
import CardScan

enum PllScreenJourney {
    case newCard
    case existingCard
}

class PLLScreenViewController: BinkViewController {
    // MARK: - Properties
    
    private let viewModel: PLLScreenViewModel
    private let journey: PllScreenJourney
    
    private lazy var stackScroll: StackScrollView = {
        let stackScroll = StackScrollView(
            axis: .vertical,
            arrangedSubviews: [brandHeaderView, titleLabel, primaryMessageLabel, secondaryMessageLabel, activePaymentCardsTableView, pendingCardsTitleLabel, pendingCardsDetailLabel, pendingPaymentCardsTableView],
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
    
    private lazy var activePaymentCardsTableView: NestedTableView = {
        let tableView = NestedTableView(frame: .zero)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = 100.0
        tableView.dataSource = self
        tableView.separatorStyle = .none
        return tableView
    }()
    
    // MARK: - Pending payment cards
    
    private lazy var pendingCardsTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.headline
        label.textAlignment = .left
        return label
    }()
    
    private lazy var pendingCardsDetailLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.bodyTextLarge
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var pendingPaymentCardsTableView: NestedTableView = {
        let tableView = NestedTableView(frame: .zero)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = 100.0
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        return tableView
    }()

    private lazy var primaryButton: BinkButton = {
        return BinkButton(type: .gradient) { [weak self] in
            self?.handlePrimaryButtonTap()
        }
    }()

    private lazy var secondaryButton: BinkButton = {
        return BinkButton(type: .plain) { [weak self] in
            self?.handleSecondaryButtonTap()
        }
    }()
    
    // MARK: - Initialisation
    
    init(viewModel: PLLScreenViewModel, journey: PllScreenJourney) {
        self.viewModel = viewModel
        self.journey = journey
        super.init(nibName: nil, bundle: nil)
        
        if journey == .newCard {
            let card = viewModel.getMembershipCard()
            
            viewModel.activePaymentCards?.forEach {
                /*
                Filter out cards already associated with this account.
                This means that we don't try to re-add any cards that we have already linked to this account.
                For arguments sake sometimes this is not a new card.. it's a re-authenticated old card.
                */
                if !card.linkedPaymentCards.contains($0) {
                    viewModel.addCardToChangedCardsArray(card: $0)
                }
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        
        configureBrandHeader()
        configureUI()
        configureLayout()
        activePaymentCardsTableView.register(PaymentCardCell.self, asNib: true)
        pendingPaymentCardsTableView.register(PaymentCardDetailLoyaltyCardStatusCell.self, asNib: true)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleWalletReload), name: .didLoadWallet, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleWalletReload), name: .didLoadLocalWallet, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setScreenName(trackedScreen: .pll)
    }
    
    private func configureLayout() {
        NSLayoutConstraint.activate([
            stackScroll.topAnchor.constraint(equalTo: view.topAnchor),
            stackScroll.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stackScroll.leftAnchor.constraint(equalTo: view.leftAnchor),
            stackScroll.rightAnchor.constraint(equalTo: view.rightAnchor),
            activePaymentCardsTableView.widthAnchor.constraint(equalTo: view.widthAnchor),
            titleLabel.leftAnchor.constraint(equalTo: stackScroll.leftAnchor, constant: 25),
            titleLabel.rightAnchor.constraint(equalTo: stackScroll.rightAnchor, constant: -25),
            primaryMessageLabel.leftAnchor.constraint(equalTo: stackScroll.leftAnchor, constant: 25),
            primaryMessageLabel.rightAnchor.constraint(equalTo: stackScroll.rightAnchor, constant: -25),
            secondaryMessageLabel.leftAnchor.constraint(equalTo: stackScroll.leftAnchor, constant: 25),
            secondaryMessageLabel.rightAnchor.constraint(equalTo: stackScroll.rightAnchor, constant: -25),
            pendingCardsTitleLabel.leftAnchor.constraint(equalTo: stackScroll.leftAnchor, constant: 25),
            pendingCardsTitleLabel.rightAnchor.constraint(equalTo: stackScroll.rightAnchor, constant: -25),
            pendingCardsDetailLabel.leftAnchor.constraint(equalTo: stackScroll.leftAnchor, constant: 25),
            pendingCardsDetailLabel.rightAnchor.constraint(equalTo: stackScroll.rightAnchor, constant: -25),
            pendingPaymentCardsTableView.widthAnchor.constraint(equalTo: view.widthAnchor),
            brandHeaderView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])
    }
    
    @objc private func handleWalletReload() {
        viewModel.refreshMembershipCard {
            self.activePaymentCardsTableView.reloadData()
            self.pendingPaymentCardsTableView.reloadData()
            self.configureUI()
            
            // We may be moving from empty PLL to PLL state if we've added a card directly from here
            // So we should update the modal state
            self.refreshModalState()
        }
    }
    
    private func refreshModalState() {
        if !viewModel.shouldAllowDismiss {
            navigationItem.rightBarButtonItem = nil
            if #available(iOS 13.0, *) {
                isModalInPresentation = true
            }
        }
    }
}

// MARK: - Loyalty button delegate

extension PLLScreenViewController: LoyaltyButtonDelegate {
    func brandHeaderViewWasTapped(_ brandHeaderView: BrandHeaderView) {
        viewModel.brandHeaderWasTapped()
    }
}

// MARK: - UITableViewDataSource

extension PLLScreenViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == activePaymentCardsTableView { return viewModel.activePaymentCards?.count ?? 0 }
        if tableView == pendingPaymentCardsTableView { return viewModel.pendingPaymentCards?.count ?? 0 }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == activePaymentCardsTableView {
            let cell: PaymentCardCell = tableView.dequeue(indexPath: indexPath)
            guard let paymentCard = viewModel.activePaymentCards?[indexPath.row] else { return cell }
            cell.configureUI(paymentCard: paymentCard, cardIndex: indexPath.row, delegate: self, journey: journey, showAsLinked: viewModel.linkedPaymentCards?.contains(paymentCard) == true)
            return cell
        }
        
        if tableView == pendingPaymentCardsTableView {
            let cell: PaymentCardDetailLoyaltyCardStatusCell = tableView.dequeue(indexPath: indexPath)
            guard let pendingPaymentCard = viewModel.pendingPaymentCards?[indexPath.row] else { return cell }
            cell.configure(with: pendingPaymentCard)
            return cell
        }
        
        fatalError("Invalid table view")
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == pendingPaymentCardsTableView {
            viewModel.toFAQScreen()
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - Private methods

private extension PLLScreenViewController {
    func reloadContent() {
        Current.wallet.refreshLocal {
            self.activePaymentCardsTableView.reloadData()
            self.pendingPaymentCardsTableView.reloadData()
        }
    }
    
    func configureBrandHeader() {
        let membershipPlan = viewModel.getMembershipPlan()
        brandHeaderView.configure(plan: membershipPlan, delegate: self)
    }
    
    func configureUI() {
        titleLabel.text = viewModel.titleText
        titleLabel.isHidden = !viewModel.shouldShowActivePaymentCards && viewModel.shouldShowPendingPaymentCards
        
        primaryMessageLabel.text = viewModel.primaryMessageText
        primaryMessageLabel.isHidden = titleLabel.isHidden
        
        secondaryMessageLabel.text = viewModel.secondaryMessageText
        secondaryMessageLabel.isHidden = viewModel.shouldShowActivePaymentCards || viewModel.shouldShowPendingPaymentCards
        
        activePaymentCardsTableView.isHidden = !viewModel.shouldShowActivePaymentCards
        
        pendingCardsTitleLabel.text = "pll_screen_pending_cards_title".localized
        pendingCardsDetailLabel.text = "pll_screen_pending_cards_detail".localized
        pendingCardsTitleLabel.isHidden = !viewModel.shouldShowPendingPaymentCards
        pendingCardsDetailLabel.isHidden = !viewModel.shouldShowPendingPaymentCards
        pendingPaymentCardsTableView.isHidden = !viewModel.shouldShowPendingPaymentCards

        var buttons: [BinkButton] = [primaryButton]
        switch journey {
        case .newCard:
            primaryButton.setTitle("done".localized)

            if !viewModel.hasActivePaymentCards {
                secondaryButton.setTitle("pll_screen_add_cards_button_title".localized)
                buttons.append(secondaryButton)
            }
        case .existingCard:
            primaryButton.setTitle(viewModel.isEmptyPll ? "pll_screen_add_cards_button_title".localized : "done".localized)
        }
        self.buttons = buttons
        buttonsView.layoutIfNeeded()
        stackScroll.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: buttonsView.bounds.height, right: 0)
        view.sendSubviewToBack(stackScroll)
    }

    func handlePrimaryButtonTap() {
        guard Current.apiClient.networkIsReachable else {
            viewModel.displayNoConnectivityPopup { [weak self] in
                self?.viewModel.close()
            }
            return
        }
        if !viewModel.isEmptyPll && !viewModel.changedLinkCards.isEmpty {
            primaryButton.toggleLoading(isLoading: true)
            view.isUserInteractionEnabled = false
        }
        viewModel.toggleLinkForMembershipCards { [weak self] success in
            guard let self = self else { return }
            if success {
                self.reloadContent()
                self.view.isUserInteractionEnabled = true
                self.primaryButton.toggleLoading(isLoading: false)

                switch self.journey {
                case .newCard:
                    self.viewModel.close()
                case .existingCard:
                    self.viewModel.isEmptyPll ? self.viewModel.toPaymentScanner(delegate: self) : self.viewModel.close()
                }
            } else {
                self.viewModel.close()
            }
        }
    }

    func handleSecondaryButtonTap() {
        viewModel.toPaymentScanner(delegate: self)
    }
}

// MARK: - PaymentCardCellDelegate

extension PLLScreenViewController: PaymentCardCellDelegate {
    func paymentCardCellDidToggleSwitch(_ paymentCell: PaymentCardCell, cardIndex: Int) {
        if let paymentCards = viewModel.activePaymentCards {
            viewModel.addCardToChangedCardsArray(card: paymentCards[cardIndex])
        }
    }
}

extension PLLScreenViewController: ScanDelegate {
    func userDidCancel(_ scanViewController: ScanViewController) {
        Current.navigate.close()
    }
    
    func userDidScanCard(_ scanViewController: ScanViewController, creditCard: CreditCard) {
        BinkAnalytics.track(GenericAnalyticsEvent.paymentScan(success: true))
        let month = creditCard.expiryMonthInteger()
        let year = creditCard.expiryYearInteger()
        let model = PaymentCardCreateModel(fullPan: creditCard.number, nameOnCard: nil, month: month, year: year)
        let viewController = ViewControllerFactory.makeAddPaymentCardViewController(model: model, journey: .pll)
        let navigationRequest = PushNavigationRequest(viewController: viewController, hidesBackButton: true)
        Current.navigate.to(navigationRequest)
    }
    
    func userDidSkip(_ scanViewController: ScanViewController) {
        let viewController = ViewControllerFactory.makeAddPaymentCardViewController(journey: .pll)
        let navigationRequest = PushNavigationRequest(viewController: viewController, hidesBackButton: true)
        Current.navigate.to(navigationRequest)
    }
}
