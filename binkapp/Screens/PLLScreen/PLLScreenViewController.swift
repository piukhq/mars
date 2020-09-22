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
        
        if journey == .newCard {
            let card = viewModel.getMembershipCard()
            
            viewModel.paymentCards?.forEach {
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
        paymentCardsTableView.register(PaymentCardCell.self, asNib: true)
        floatingButtonsView.delegate = self
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
            floatingButtonsView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            floatingButtonsView.heightAnchor.constraint(equalToConstant: floatingButtonsView.isSecondaryButtonHidden ?
                LayoutHelper.PrimarySecondaryButtonView.oneButtonHeight :
                LayoutHelper.PrimarySecondaryButtonView.twoButtonsHeight)
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
        viewModel.toggleLinkForMembershipCards { [weak self] in
            guard let self = self else { return }
            self.reloadContent()
            self.view.isUserInteractionEnabled = true
            floatingButtons.primaryButton.stopLoading()
            self.handlePrimaryButtonPress()
        }
    }
    
    func binkFloatingButtonsSecondaryButtonWasTapped(_ floatingButtons: BinkPrimarySecondaryButtonView) {
        viewModel.toPaymentScanner(delegate: self)
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
            cell.configureUI(
                paymentCard: paymentCard,
                cardIndex: indexPath.row,
                delegate: self,
                journey: journey,
                isLastCell: isLastCell,
                showAsLinked: viewModel.linkedPaymentCards?.contains(paymentCard) == true
            )
        }
        return cell 
    }
}

// MARK: - Private methods

private extension PLLScreenViewController {
    func reloadContent() {
        viewModel.reloadPaymentCards()
        paymentCardsTableView.reloadData()
    }
    
    func configureBrandHeader() {
        let membershipPlan = viewModel.getMembershipPlan()
        brandHeaderView.configure(plan: membershipPlan, delegate: self)
    }
    
    func configureUI() {
        titleLabel.text = viewModel.titleText
        primaryMessageLabel.text = viewModel.primaryMessageText
        secondaryMessageLabel.text = viewModel.secondaryMessageText
        secondaryMessageLabel.isHidden = !viewModel.isEmptyPll
        paymentCardsTableView.isHidden = viewModel.isEmptyPll
        stackScroll.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: LayoutHelper.PrimarySecondaryButtonView.height, right: 0)
        switch journey {
        case .newCard:
            floatingButtonsView.configure(primaryButtonTitle: "done".localized, secondaryButtonTitle: viewModel.hasPaymentCards ? nil : "pll_screen_add_cards_button_title".localized, hasGradient: true)
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
        if let paymentCards = viewModel.paymentCards {
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
