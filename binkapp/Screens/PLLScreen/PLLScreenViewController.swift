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

class PLLScreenViewController: BinkTrackableViewController {
    
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
        floatingButtonsView.delegate = self
        
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
            brandHeaderView.widthAnchor.constraint(equalTo: view.widthAnchor),
            floatingButtonsView.leftAnchor.constraint(equalTo: view.leftAnchor),
            floatingButtonsView.rightAnchor.constraint(equalTo: view.rightAnchor),
            floatingButtonsView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            floatingButtonsView.heightAnchor.constraint(equalToConstant: floatingButtonsView.isSecondaryButtonHidden ?
                LayoutHelper.PrimarySecondaryButtonView.oneButtonHeight :
                LayoutHelper.PrimarySecondaryButtonView.twoButtonsHeight)
        ])
    }
    
    @objc private func handleWalletReload() {
        viewModel.refreshMembershipCard {
            self.activePaymentCardsTableView.reloadData()
            self.pendingPaymentCardsTableView.reloadData()
            self.configureUI()
        }
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
        guard Current.apiClient.networkIsReachable else {
            viewModel.displayNoConnectivityPopup { [weak self] in
                self?.viewModel.close()
            }
            return
        }
        if !viewModel.isEmptyPll && !viewModel.changedLinkCards.isEmpty {
            floatingButtons.primaryButton.startLoading()
            view.isUserInteractionEnabled = false
        }
        viewModel.toggleLinkForMembershipCards { [weak self] success in
            guard let self = self else { return }
            if success {
                self.reloadContent()
                self.view.isUserInteractionEnabled = true
                floatingButtons.primaryButton.stopLoading()
                self.handlePrimaryButtonPress()
            } else {
                self.viewModel.close()
            }
        }
    }
    
    func binkFloatingButtonsSecondaryButtonWasTapped(_ floatingButtons: BinkPrimarySecondaryButtonView) {
        viewModel.toPaymentScanner(delegate: self)
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
        
        stackScroll.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: LayoutHelper.PrimarySecondaryButtonView.height, right: 0)
        switch journey {
        case .newCard:
            floatingButtonsView.configure(primaryButtonTitle: "done".localized, secondaryButtonTitle: viewModel.hasActivePaymentCards ? nil : "pll_screen_add_cards_button_title".localized, hasGradient: true)
        case .existingCard:
            viewModel.isEmptyPll ? floatingButtonsView.configure(primaryButtonTitle: "pll_screen_add_cards_button_title".localized, secondaryButtonTitle: nil) : floatingButtonsView.configure(primaryButtonTitle: "done".localized, secondaryButtonTitle: nil, hasGradient: true)
        }
    }
    
    func handlePrimaryButtonPress() {
        switch journey {
        case .newCard:
            viewModel.close()
            break
        case .existingCard:
            viewModel.isEmptyPll ? viewModel.toPaymentScanner(delegate: self) : viewModel.close()
            break
        }
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
        let month = Int(creditCard.expiryMonth ?? "")
        let year = Int(creditCard.expiryYear ?? "")
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
