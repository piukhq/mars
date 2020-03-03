//
//  PaymentCardDetailViewController.swift
//  binkapp
//
//  Created by Nick Farrant on 03/10/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class PaymentCardDetailViewController: BinkTrackableViewController {
    private var viewModel: PaymentCardDetailViewModel
    private var hasSetupCell = false

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
        return title
    }()

    private lazy var addedCardsDescriptionLabel: UILabel = {
        let description = UILabel()
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
        
        let backButton = UIBarButtonItem(image: UIImage(named: "navbarIconsBack"), style: .plain, target: self, action: #selector(popToRoot))
        self.navigationItem.leftBarButtonItem = backButton
        
        configureUI()
        setupTables()

        getLinkedCards()
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
    func configureUI() {
        addedCardsTitleLabel.text = viewModel.addedCardsTitle
        addedCardsDescriptionLabel.text = viewModel.addedCardsDescription
        otherCardsTitleLabel.text = viewModel.otherCardsTitle
        otherCardsDescriptionLabel.text = viewModel.otherCardsDescription

        stackScrollView.delegate = self
        configureLayout()
    }

    func configureLayout() {
        stackScrollView.insert(arrangedSubview: card, atIndex: 0, customSpacing: LayoutHelper.PaymentCardDetail.stackScrollViewTopPadding)

        if viewModel.shouldShowAddedLoyaltyCardTableView {
            stackScrollView.add(arrangedSubviews: [addedCardsTitleLabel, addedCardsDescriptionLabel, addedCardsTableView])
            NSLayoutConstraint.activate([
                addedCardsTitleLabel.leftAnchor.constraint(equalTo: stackScrollView.leftAnchor, constant: LayoutHelper.PaymentCardDetail.headerViewsPadding),
                addedCardsTitleLabel.rightAnchor.constraint(equalTo: stackScrollView.rightAnchor, constant: -LayoutHelper.PaymentCardDetail.headerViewsPadding),
                addedCardsDescriptionLabel.leftAnchor.constraint(equalTo: stackScrollView.leftAnchor, constant: LayoutHelper.PaymentCardDetail.headerViewsPadding),
                addedCardsDescriptionLabel.rightAnchor.constraint(equalTo: stackScrollView.rightAnchor, constant: -LayoutHelper.PaymentCardDetail.headerViewsPadding),
                addedCardsTableView.widthAnchor.constraint(equalTo: stackScrollView.widthAnchor),
            ])
        }
        if viewModel.shouldShowOtherCardsTableView {
            if viewModel.shouldShowAddedLoyaltyCardTableView {
                stackScrollView.customPadding(LayoutHelper.PaymentCardDetail.headerViewsPadding, after: addedCardsTableView)
            }

            stackScrollView.add(arrangedSubviews: [otherCardsTitleLabel, otherCardsDescriptionLabel, otherCardsTableView])
            NSLayoutConstraint.activate([
                otherCardsTitleLabel.leftAnchor.constraint(equalTo: stackScrollView.leftAnchor, constant: LayoutHelper.PaymentCardDetail.headerViewsPadding),
                otherCardsTitleLabel.rightAnchor.constraint(equalTo: stackScrollView.rightAnchor, constant: -LayoutHelper.PaymentCardDetail.headerViewsPadding),
                otherCardsDescriptionLabel.leftAnchor.constraint(equalTo: stackScrollView.leftAnchor, constant: LayoutHelper.PaymentCardDetail.headerViewsPadding),
                otherCardsDescriptionLabel.rightAnchor.constraint(equalTo: stackScrollView.rightAnchor, constant: -LayoutHelper.PaymentCardDetail.headerViewsPadding),
                otherCardsTableView.widthAnchor.constraint(equalTo: stackScrollView.widthAnchor),
            ])
        }

        stackScrollView.add(arrangedSubviews: [informationTableView])
        NSLayoutConstraint.activate([
            stackScrollView.topAnchor.constraint(equalTo: view.topAnchor),
            stackScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stackScrollView.leftAnchor.constraint(equalTo: view.leftAnchor),
            stackScrollView.rightAnchor.constraint(equalTo: view.rightAnchor),
            card.heightAnchor.constraint(equalToConstant: LayoutHelper.WalletDimensions.cardSize.height),
            card.widthAnchor.constraint(equalTo: stackScrollView.widthAnchor, constant: -LayoutHelper.PaymentCardDetail.cardViewPadding),
            informationTableView.widthAnchor.constraint(equalTo: stackScrollView.widthAnchor),
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
    
    @objc func popToRoot() {
        viewModel.popToRootViewController()
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

            let cellViewModel = PaymentCardDetailAddLoyaltyCardCellViewModel(membershipPlan: plan, router: viewModel.router)

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
    func cardDetailInformationRowFactory(_ factory: PaymentCardDetailInformationRowFactory, shouldPerformActionForRowType informationRowType: CardDetailInformationRow.RowType) {
        switch informationRowType {
        case .securityAndPrivacy:
            viewModel.toSecurityAndPrivacyScreen()
        case .deletePaymentCard:
            viewModel.showDeleteConfirmationAlert()
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
