//
//  PaymentCardDetailViewController.swift
//  binkapp
//
//  Created by Nick Farrant on 03/10/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit
import SupportSDK

class PaymentCardDetailViewController: BinkTrackableViewController {
    private var viewModel: PaymentCardDetailViewModel
    private var hasSetupCell = false
    
    private var refreshTimer: Timer?
    private var zendeskPromptFirstNameTextField: UITextField!
    private var zendeskPromptLastNameTextField: UITextField!
    private var zendeskPromptOKAction: UIAlertAction!

    // MARK: - UI lazy vars

    private lazy var stackScrollView: StackScrollView = {
        let stackView = StackScrollView(axis: .vertical, arrangedSubviews: nil, adjustForKeyboard: true)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = .white
        stackView.margin = LayoutHelper.PaymentCardDetail.stackScrollViewMargins
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.contentInset = LayoutHelper.PaymentCardDetail.stackScrollViewContentInsets
        view.addSubview(stackView)
        return stackView
    }()

    private lazy var card: PaymentCardCollectionViewCell = {
        let cell: PaymentCardCollectionViewCell = .fromNib()
        cell.translatesAutoresizingMaskIntoConstraints = false
        return cell
    }()

    private lazy var addedCardsTitleLabel: UILabel = {
        let title = UILabel()
        title.font = .headline
        title.textAlignment = .left
        title.translatesAutoresizingMaskIntoConstraints = false
        title.numberOfLines = 0
        return title
    }()

    private lazy var addedCardsDescriptionLabel: HyperlinkLabel = {
        let description = HyperlinkLabel()
        description.font = .bodyTextLarge
        description.numberOfLines = 0
        description.textAlignment = .left
        description.translatesAutoresizingMaskIntoConstraints = false
        return description
    }()

    private lazy var otherCardsTitleLabel: UILabel = {
        let title = UILabel()
        title.font = .headline
        title.textAlignment = .left
        title.translatesAutoresizingMaskIntoConstraints = false
        return title
    }()

    private lazy var otherCardsDescriptionLabel: UILabel = {
        let description = UILabel()
        description.font = .bodyTextLarge
        description.numberOfLines = 0
        description.textAlignment = .left
        description.translatesAutoresizingMaskIntoConstraints = false
        return description
    }()
    
    private lazy var cardAddedLabel: UILabel = {
        let description = UILabel()
        description.font = .bodyTextSmall
        description.numberOfLines = 0
        description.textAlignment = .left
        description.translatesAutoresizingMaskIntoConstraints = false
        return description
    }()

    private lazy var addedCardsTableView: NestedTableView = {
        let tableView = NestedTableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    private lazy var otherCardsTableView: NestedTableView = {
        let tableView = NestedTableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    private lazy var informationTableView: NestedTableView = {
        let tableView = NestedTableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    lazy var separator: UIView = {
        let separator = UIView()
        separator.backgroundColor = .lightGray
        separator.translatesAutoresizingMaskIntoConstraints = false
        return separator
    }()

    // MARK: - Init

    init(viewModel: PaymentCardDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        configureLayout()
        configureUI()
        setupTables()

        getLinkedCards()
        
        if viewModel.paymentCardStatus == .pending {
            refreshTimer = Timer.scheduledTimer(withTimeInterval: viewModel.pendingRefreshInterval, repeats: false, block: { timer in
                self.refresh()
                timer.invalidate()
            })
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setScreenName(trackedScreen: .paymentDetail)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // This is due to strange layout issues on first appearance
        if !hasSetupCell {
            hasSetupCell = true
            let cardWidth = stackScrollView.frame.width - LayoutHelper.PaymentCardDetail.cardViewPadding
            let cardHeight = LayoutHelper.WalletDimensions.cardSize.height
            card.frame = CGRect(origin: .zero, size: CGSize(width: cardWidth, height: cardHeight))
            card.configureWithViewModel(viewModel.paymentCardCellViewModel, enableSwipeGesture: false, delegate: nil)
        }
    }

}

// MARK - Private methods

private extension PaymentCardDetailViewController {
    func refresh() {
        viewModel.refreshPaymentCard {
            self.configureUI()
            self.card.configureWithViewModel(self.viewModel.paymentCardCellViewModel, enableSwipeGesture: false, delegate: nil)
            Current.wallet.refreshLocal()
        }
    }
    
    func configureUI() {
        addedCardsTitleLabel.text = viewModel.addedCardsTitle
        viewModel.paymentCardStatus == .active ? addedCardsDescriptionLabel.text = viewModel.addedCardsDescription : addedCardsDescriptionLabel.configure(viewModel.addedCardsDescription, withHyperlink: "Contact us", delegate: self)
        otherCardsTitleLabel.text = viewModel.otherCardsTitle
        otherCardsDescriptionLabel.text = viewModel.otherCardsDescription
        cardAddedLabel.text = viewModel.cardAddedDateString
        
        card.isHidden = !viewModel.shouldShowPaymentCardCell
        addedCardsTitleLabel.isHidden = !viewModel.shouldShowAddedCardsTitleLabel
        addedCardsDescriptionLabel.isHidden = !viewModel.shouldShowAddedCardsDescriptionLabel
        otherCardsTitleLabel.isHidden = !viewModel.shouldShowOtherCardsTitleLabel
        otherCardsDescriptionLabel.isHidden = !viewModel.shouldShowOtherCardsDescriptionLabel
        cardAddedLabel.isHidden = !viewModel.shouldShowCardAddedLabel
        addedCardsTableView.isHidden = !viewModel.shouldShowAddedLoyaltyCardTableView
        otherCardsTableView.isHidden = !viewModel.shouldShowOtherCardsTableView
        informationTableView.isHidden = !viewModel.shouldShowInformationTableView
        separator.isHidden = !viewModel.shouldShowSeparator
        
        stackScrollView.customPadding(viewModel.paymentCardStatus == .pending ? 20 : 0, after: cardAddedLabel)
        stackScrollView.customPadding(viewModel.paymentCardStatus != .active ? 20 : 0, after: addedCardsDescriptionLabel)
        stackScrollView.customPadding(viewModel.shouldShowAddedLoyaltyCardTableView ? LayoutHelper.PaymentCardDetail.headerViewsPadding : 0, after: addedCardsTableView)
    
        stackScrollView.delegate = self
    }

    func configureLayout() {
        stackScrollView.insert(arrangedSubview: card, atIndex: 0, customSpacing: LayoutHelper.PaymentCardDetail.stackScrollViewTopPadding)
        
        stackScrollView.add(arrangedSubviews: [addedCardsTitleLabel, addedCardsDescriptionLabel, cardAddedLabel, addedCardsTableView, otherCardsTitleLabel, otherCardsDescriptionLabel, otherCardsTableView, separator, informationTableView])
        NSLayoutConstraint.activate([
            addedCardsTitleLabel.leftAnchor.constraint(equalTo: stackScrollView.leftAnchor, constant: LayoutHelper.PaymentCardDetail.headerViewsPadding),
            addedCardsTitleLabel.rightAnchor.constraint(equalTo: stackScrollView.rightAnchor, constant: -LayoutHelper.PaymentCardDetail.headerViewsPadding),
            addedCardsDescriptionLabel.leftAnchor.constraint(equalTo: stackScrollView.leftAnchor, constant: LayoutHelper.PaymentCardDetail.headerViewsPadding),
            addedCardsDescriptionLabel.rightAnchor.constraint(equalTo: stackScrollView.rightAnchor, constant: -LayoutHelper.PaymentCardDetail.headerViewsPadding),
            cardAddedLabel.leftAnchor.constraint(equalTo: stackScrollView.leftAnchor, constant: LayoutHelper.PaymentCardDetail.headerViewsPadding),
            cardAddedLabel.rightAnchor.constraint(equalTo: stackScrollView.rightAnchor, constant: -LayoutHelper.PaymentCardDetail.headerViewsPadding),
            addedCardsTableView.widthAnchor.constraint(equalTo: stackScrollView.widthAnchor),
            otherCardsTitleLabel.leftAnchor.constraint(equalTo: stackScrollView.leftAnchor, constant: LayoutHelper.PaymentCardDetail.headerViewsPadding),
            otherCardsTitleLabel.rightAnchor.constraint(equalTo: stackScrollView.rightAnchor, constant: -LayoutHelper.PaymentCardDetail.headerViewsPadding),
            otherCardsDescriptionLabel.leftAnchor.constraint(equalTo: stackScrollView.leftAnchor, constant: LayoutHelper.PaymentCardDetail.headerViewsPadding),
            otherCardsDescriptionLabel.rightAnchor.constraint(equalTo: stackScrollView.rightAnchor, constant: -LayoutHelper.PaymentCardDetail.headerViewsPadding),
            otherCardsTableView.widthAnchor.constraint(equalTo: stackScrollView.widthAnchor),
            stackScrollView.topAnchor.constraint(equalTo: view.topAnchor),
            stackScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stackScrollView.leftAnchor.constraint(equalTo: view.leftAnchor),
            stackScrollView.rightAnchor.constraint(equalTo: view.rightAnchor),
            card.heightAnchor.constraint(equalToConstant: LayoutHelper.WalletDimensions.cardSize.height),
            card.widthAnchor.constraint(equalTo: stackScrollView.widthAnchor, constant: -LayoutHelper.PaymentCardDetail.cardViewPadding),
            informationTableView.widthAnchor.constraint(equalTo: stackScrollView.widthAnchor),
            separator.heightAnchor.constraint(equalToConstant: CGFloat.onePointScaled()),
            separator.widthAnchor.constraint(equalTo: stackScrollView.widthAnchor)
        ])
    }

    func setupTables() {
        [addedCardsTableView, otherCardsTableView, informationTableView].forEach {
            $0.delegate = self
            $0.dataSource = self
            $0.separatorInset = LayoutHelper.PaymentCardDetail.tableViewCellSeparatorInsets
        }

        addedCardsTableView.register(PaymentCardDetailLinkLoyaltyCardCell.self, asNib: true)
        addedCardsTableView.register(PaymentCardDetailLoyaltyCardStatusCell.self, asNib: true)
        otherCardsTableView.register(PaymentCardDetailAddLoyaltyCardCell.self, asNib: true)
        informationTableView.register(CardDetailInfoTableViewCell.self, asNib: true)

        getLinkedCards()
    }

    func getLinkedCards() {
        viewModel.getLinkedMembershipCards { [weak self] in
            self?.addedCardsTableView.reloadData()
            self?.otherCardsTableView.reloadData()
        }
    }

    func refreshViews() {
        self.card.configureWithViewModel(self.viewModel.paymentCardCellViewModel, delegate: nil)
        self.addedCardsTableView.reloadData()
        self.otherCardsTableView.reloadData()
        Current.wallet.refreshLocal()
    }
}

// MARK: Table view delegate & datasource

extension PaymentCardDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == addedCardsTableView {
            return viewModel.pllMembershipCardsCount
        }

        if tableView == otherCardsTableView {
            return viewModel.pllPlansNotAddedToWalletCount
        }

        if tableView == informationTableView {
            return viewModel.informationRows.count
        }

        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == addedCardsTableView {
            guard let membershipCard = viewModel.membershipCard(forIndexPath: indexPath) else {
                fatalError("Could not get membership card at index path")
            }
            guard let cardStatus = viewModel.statusForMembershipCard(atIndexPath: indexPath) else {
                fatalError("Could not get status for membership card")
            }

            if cardStatus.status == .authorised {
                let cell: PaymentCardDetailLinkLoyaltyCardCell = tableView.dequeue(indexPath: indexPath)
                let isLinked = viewModel.membershipCardIsLinked(membershipCard)
                let cellViewModel = PaymentCardDetailLinkLoyaltyCardCellViewModel(membershipCard: membershipCard, isLinked: isLinked)

                cell.configureWithViewModel(cellViewModel, delegate: self)

                if tableView.cellAtIndexPathIsLastInSection(indexPath) {
                    cell.setSeparatorFullWidth()
                }

                return cell
            } else {
                let cell: PaymentCardDetailLoyaltyCardStatusCell = tableView.dequeue(indexPath: indexPath)
                let cellViewModel = PaymentCardDetailLoyaltyCardStatusCellViewModel(membershipCard: membershipCard)

                cell.configureWithViewModel(cellViewModel)

                if tableView.cellAtIndexPathIsLastInSection(indexPath) {
                    cell.setSeparatorFullWidth()
                }

                return cell
            }
        } else if tableView == otherCardsTableView {
            let cell: PaymentCardDetailAddLoyaltyCardCell = tableView.dequeue(indexPath: indexPath)

            guard let plan = viewModel.pllPlanNotAddedToWallet(forIndexPath: indexPath) else {
                return cell
            }

            let cellViewModel = PaymentCardDetailAddLoyaltyCardCellViewModel(membershipPlan: plan)

            cell.configureWithViewModel(cellViewModel)

            if tableView.cellAtIndexPathIsLastInSection(indexPath) {
                cell.setSeparatorFullWidth()
            }

            return cell
        } else { // This will always be the information table view
            let cell: CardDetailInfoTableViewCell = tableView.dequeue(indexPath: indexPath)

            let informationRow = viewModel.informationRow(forIndexPath: indexPath)
            cell.configureWithInformationRow(informationRow)

            if tableView.cellAtIndexPathIsLastInSection(indexPath) {
                cell.hideSeparator()
            }

            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == addedCardsTableView {
            guard let membershipCard = viewModel.membershipCard(forIndexPath: indexPath) else { return }
            viewModel.toCardDetail(forMembershipCard: membershipCard)
        }

        if tableView == otherCardsTableView {
            guard let membershipPlan = viewModel.pllMembershipPlans?[indexPath.row] else { return }
            viewModel.toAddOrJoin(forMembershipPlan: membershipPlan)
        }

        if tableView == informationTableView {
            viewModel.performActionForInformationRow(atIndexPath: indexPath)
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView == addedCardsTableView || tableView == otherCardsTableView ? LayoutHelper.PaymentCardDetail.pllCellRowHeight : LayoutHelper.PaymentCardDetail.informationRowCellHeight
    }
}

// MARK: - PaymentCardDetailLinkLoyaltyCardCellDelegate

extension PaymentCardDetailViewController: PaymentCardDetailLinkLoyaltyCardCellDelegate {
    func linkedLoyaltyCardCell(_ cell: PaymentCardDetailLinkLoyaltyCardCell, shouldToggleLinkedStateForMembershipCard membershipCard: CD_MembershipCard) {
        viewModel.toggleLinkForMembershipCard(membershipCard) { [weak self] in
            self?.refreshViews()
        }
    }
}

// MARK: - CardDetailInformationRowFactoryDelegate

extension PaymentCardDetailViewController: CardDetailInformationRowFactoryDelegate {
    func cardDetailInformationRowFactory(_ factory: WalletCardDetailInformationRowFactory, shouldPerformActionForRowType informationRowType: CardDetailInformationRow.RowType) {
        switch informationRowType {
        case .securityAndPrivacy:
            viewModel.toSecurityAndPrivacyScreen()
        case .deletePaymentCard:
            viewModel.showDeleteConfirmationAlert()
        case .faqs:
            viewModel.toFAQsScreen()
        default:
            return
        }
    }
}

// MARK: - Navigation title scrolling behaviour

extension PaymentCardDetailViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let titleView: DetailNavigationTitleView = .fromNib()
        titleView.configureWithTitle(viewModel.navigationViewTitleText, detail: viewModel.navigationViewDetailText)

        let offset = LayoutHelper.PaymentCardDetail.navBarTitleViewScrollOffset(withNavigationBar: navigationController?.navigationBar)
        navigationItem.titleView = scrollView.contentOffset.y > offset ? titleView : nil
    }
}

// MARK: - Layout Helper

extension LayoutHelper {
    struct PaymentCardDetail {
        static func navBarTitleViewScrollOffset(withNavigationBar navigationBar: UINavigationBar?) -> CGFloat {
            let stackScrollViewInitialOffset: CGFloat = 108
            let desiredOffset = LayoutHelper.statusBarHeight + LayoutHelper.heightForNavigationBar(navigationBar) + stackScrollViewContentInsets.top + (LayoutHelper.WalletDimensions.cardSize.height / 2)
            return stackScrollViewInitialOffset - desiredOffset
        }

        static let stackScrollViewMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        static let stackScrollViewTopPadding: CGFloat = 30
        static let stackScrollViewContentInsets = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        static let headerViewsPadding: CGFloat = 25
        static let cardViewPadding: CGFloat = 50
        static let tableViewCellSeparatorInsets = UIEdgeInsets(top: 0, left: 25, bottom: 0, right: 25)
        static let pllCellRowHeight: CGFloat = 100
        static let informationRowCellHeight: CGFloat = 88
    }
}

extension PaymentCardDetailViewController: HyperlinkLabelDelegate {
    func hyperlinkLabelWasTapped(_ hyperlinkLabel: HyperlinkLabel) {
        let launchContactUs = {
            let viewController = RequestUi.buildRequestList()
            let navigationRequest = ModalNavigationRequest(viewController: viewController)
            Current.navigate.to(navigationRequest)
        }
    
        if ZendeskService.shouldPromptForIdentity {
            let alert = UIAlertController.makeZendeskIdentityAlertController(firstNameTextField: { [weak self] textField in
                self?.zendeskPromptFirstNameTextField = textField
            }, lastNameTextField: { [weak self] textField in
                self?.zendeskPromptLastNameTextField = textField
            }, okActionObject: { [weak self] actionObject in
                self?.zendeskPromptOKAction = actionObject
            }, okActionHandler: {
                launchContactUs()
            }, textFieldDelegate: self)
            let navigationRequest = AlertNavigationRequest(alertController: alert)
            Current.navigate.to(navigationRequest)
        } else {
            launchContactUs()
        }
    }
}

extension PaymentCardDetailViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        /// If both textfields are empty, disable ok action as at least one textfield will be empty after updating
        let firstNameText = zendeskPromptFirstNameTextField.text ?? ""
        let lastNameText = zendeskPromptLastNameTextField.text ?? ""
        if firstNameText.isEmpty && lastNameText.isEmpty {
            zendeskPromptOKAction.isEnabled = false
        }
        /// If both textfields are NOT empty, and the replacement string is NOT empty, we know that both textfields must have values after updating
        if !firstNameText.isEmpty && !lastNameText.isEmpty && !string.isEmpty {
            zendeskPromptOKAction.isEnabled = true
        }

        /// If the textfield being updated is firstName, and it has no current value, and the replacement string has a value, and lastName has a value then we know that both textfields will have values after updating
        if textField == zendeskPromptFirstNameTextField && firstNameText.isEmpty && !string.isEmpty && !lastNameText.isEmpty {
            zendeskPromptOKAction.isEnabled = true
        }

        /// If the textfield being updated is lastName, and it has no current value, and the replacement string has a value, and firstName has a value then we know that both textfields will have values after updating
        if textField == zendeskPromptLastNameTextField && lastNameText.isEmpty && !string.isEmpty && !firstNameText.isEmpty {
            zendeskPromptOKAction.isEnabled = true
        }

        /// If the textfield being updated is firstName, and it's current value is only one character, and the replacement string has no value then we know the textfield will have no value after updating
        if textField == zendeskPromptFirstNameTextField && firstNameText.count == 1 && string.isEmpty {
            zendeskPromptOKAction.isEnabled = false
        }

        /// If the textfield being updated is lastName, and it's current value is only one character, and the replacement string has no value then we know the textfield will have no value after updating
        if textField == zendeskPromptLastNameTextField && lastNameText.count == 1 && string.isEmpty {
            zendeskPromptOKAction.isEnabled = false
        }

        return true
    }
}

