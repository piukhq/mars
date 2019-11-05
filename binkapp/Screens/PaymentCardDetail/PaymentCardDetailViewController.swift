//
//  PaymentCardDetailViewController.swift
//  binkapp
//
//  Created by Nick Farrant on 03/10/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class PaymentCardDetailViewController: UIViewController {
    private var viewModel: PaymentCardDetailViewModel
    private var hasSetupCell = false

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

    private lazy var linkedCardsTitleLabel: UILabel = {
        let title = UILabel()
        title.font = .headline
        title.textAlignment = .left
        title.translatesAutoresizingMaskIntoConstraints = false
        return title
    }()

    private lazy var linkedCardsDescriptionLabel: UILabel = {
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

    lazy var linkedCardsTableView: NestedTableView = {
        let tableView = NestedTableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    lazy var otherCardsTableView: NestedTableView = {
        let tableView = NestedTableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    lazy var informationTableView: NestedTableView = {
        let tableView = NestedTableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    func makeTableViewSeparator() -> UIView {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = linkedCardsTableView.separatorColor
        return view
    }

    init(viewModel: PaymentCardDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        linkedCardsTitleLabel.text = viewModel.titleText
        linkedCardsDescriptionLabel.text = viewModel.descriptionText
        otherCardsTitleLabel.text = "Other cards you can add"
        otherCardsDescriptionLabel.text = "You can also add the cards below and link them to your payment cards."

        linkedCardsTableView.delegate = self
        linkedCardsTableView.dataSource = self
        otherCardsTableView.delegate = self
        otherCardsTableView.dataSource = self
        informationTableView.delegate = self
        informationTableView.dataSource = self

        stackScrollView.delegate = self
        stackScrollView.insert(arrangedSubview: card, atIndex: 0, customSpacing: 30)
        stackScrollView.add(arrangedSubviews: [linkedCardsTitleLabel, linkedCardsDescriptionLabel, linkedCardsTableView, otherCardsTitleLabel, otherCardsDescriptionLabel, otherCardsTableView, informationTableView])

        NSLayoutConstraint.activate([
            stackScrollView.topAnchor.constraint(equalTo: view.topAnchor),
            stackScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stackScrollView.leftAnchor.constraint(equalTo: view.leftAnchor),
            stackScrollView.rightAnchor.constraint(equalTo: view.rightAnchor),
            card.heightAnchor.constraint(equalToConstant: LayoutHelper.WalletDimensions.cardSize.height),
            card.widthAnchor.constraint(equalTo: stackScrollView.widthAnchor, constant: -50),
            linkedCardsTitleLabel.leftAnchor.constraint(equalTo: stackScrollView.leftAnchor, constant: 25),
            linkedCardsTitleLabel.rightAnchor.constraint(equalTo: stackScrollView.rightAnchor, constant: -25),
            linkedCardsDescriptionLabel.leftAnchor.constraint(equalTo: stackScrollView.leftAnchor, constant: 25),
            linkedCardsDescriptionLabel.rightAnchor.constraint(equalTo: stackScrollView.rightAnchor, constant: -25),
            otherCardsTitleLabel.leftAnchor.constraint(equalTo: stackScrollView.leftAnchor, constant: 25),
            otherCardsTitleLabel.rightAnchor.constraint(equalTo: stackScrollView.rightAnchor, constant: -25),
            otherCardsDescriptionLabel.leftAnchor.constraint(equalTo: stackScrollView.leftAnchor, constant: 25),
            otherCardsDescriptionLabel.rightAnchor.constraint(equalTo: stackScrollView.rightAnchor, constant: -25),
            linkedCardsTableView.widthAnchor.constraint(equalTo: stackScrollView.widthAnchor),
            otherCardsTableView.widthAnchor.constraint(equalTo: stackScrollView.widthAnchor),
            informationTableView.widthAnchor.constraint(equalTo: stackScrollView.widthAnchor),
        ])

        linkedCardsTableView.register(PaymentCardDetailLinkLoyaltyCardCell.self, asNib: true)
        otherCardsTableView.register(PaymentCardDetailAddLoyaltyCardCell.self, asNib: true)
        informationTableView.register(CardDetailInfoTableViewCell.self, asNib: true)
        linkedCardsTableView.separatorInset = UIEdgeInsets(top: 0, left: 25, bottom: 0, right: 25)
        otherCardsTableView.separatorInset = UIEdgeInsets(top: 0, left: 25, bottom: 0, right: 25)
        informationTableView.separatorInset = UIEdgeInsets(top: 0, left: 25, bottom: 0, right: 25)

        getLinkedCards()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // This is due to strange layout issues on first appearance
        if !hasSetupCell {
            hasSetupCell = true
            card.frame = CGRect(origin: .zero, size: CGSize(width: stackScrollView.frame.width - 50, height: LayoutHelper.WalletDimensions.cardSize.height))
            card.configureWithViewModel(viewModel.paymentCardCellViewModel, delegate: nil)
        }
    }

    private func getLinkedCards() {
        viewModel.getLinkedMembershipCards { [weak self] in
            self?.linkedCardsTableView.reloadData()
            self?.otherCardsTableView.reloadData()
        }
    }

    private func refreshViews() {
        self.card.configureWithViewModel(self.viewModel.paymentCardCellViewModel, delegate: nil)
        self.linkedCardsTableView.reloadData()
        self.otherCardsTableView.reloadData()
        Current.wallet.refreshLocal()
    }

}

extension PaymentCardDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == linkedCardsTableView {
            return viewModel.pllEnabledMembershipCardsCount
        }

        if tableView == otherCardsTableView {
            return viewModel.pllPlansNotAddedToWallet?.count ?? 0 // TODO: Improve from viewmodel
        }

        if tableView == informationTableView {
            return viewModel.informationRows.count
        }

        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == linkedCardsTableView {
            let cell: PaymentCardDetailLinkLoyaltyCardCell = tableView.dequeue(indexPath: indexPath)

            guard let membershipCard = viewModel.membershipCard(forIndexPath: indexPath) else {
                return cell
            }

            let isLinked = viewModel.membershipCardIsLinked(membershipCard)
            let cellViewModel = PaymentCardDetailLinkLoyaltyCardCellViewModel(membershipCard: membershipCard, isLinked: isLinked)

            cell.configureWithViewModel(cellViewModel, delegate: self)

            return cell
        } else if tableView == otherCardsTableView {
            let cell: PaymentCardDetailAddLoyaltyCardCell = tableView.dequeue(indexPath: indexPath)

            // TODO: Improve in viewmodel
            guard let plan = viewModel.pllPlansNotAddedToWallet?[indexPath.row] else {
                return cell
            }

            let cellViewModel = PaymentCardDetailAddLoyaltyCardCellViewModel(membershipPlan: plan)

            cell.configureWithViewModel(cellViewModel)

            return cell
        } else { // This will always be the information table view
            let cell: CardDetailInfoTableViewCell = tableView.dequeue(indexPath: indexPath)

            let informationRow = viewModel.informationRow(forIndexPath: indexPath)
            cell.configureWithInformationRow(informationRow)

            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == informationTableView {
            viewModel.performActionForInformationRow(atIndexPath: indexPath)
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView == linkedCardsTableView || tableView == otherCardsTableView ? 100 : 88
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return makeTableViewSeparator()
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if viewModel.pllEnabledMembershipCardsCount == 0 {
            return 0.0
        }
        return tableView == linkedCardsTableView || tableView == otherCardsTableView ? 0.5 : 0.0
    }
}

extension PaymentCardDetailViewController: LinkedLoyaltyCardCellDelegate {
    func linkedLoyaltyCardCell(_ cell: PaymentCardDetailLinkLoyaltyCardCell, shouldToggleLinkedStateForMembershipCard membershipCard: CD_MembershipCard) {
        viewModel.toggleLinkForMembershipCard(membershipCard) { [weak self] in
            self?.refreshViews()
        }
    }
}

extension PaymentCardDetailViewController: CardDetailInformationRowFactoryDelegate {
    func cardDetailInformationRowFactory(_ factory: PaymentCardDetailInformationRowFactory, shouldPerformActionForRowType informationRowType: CardDetailInformationRow.RowType) {
        switch informationRowType {
        case .securityAndPrivacy:
            viewModel.toSecurityAndPrivacyScreen()
        case .deletePaymentCard:
            viewModel.deletePaymentCard()
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

class NestedTableView: UITableView {
    override var contentSize: CGSize {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }

    override var intrinsicContentSize: CGSize {
        return contentSize
    }
}

extension LayoutHelper {
    struct PaymentCardDetail {
        static func navBarTitleViewScrollOffset(withNavigationBar navigationBar: UINavigationBar?) -> CGFloat {
            let stackScrollViewInitialOffset: CGFloat = 108
            let desiredOffset = LayoutHelper.statusBarHeight + LayoutHelper.heightForNavigationBar(navigationBar) + stackScrollViewContentInsets.top + (LayoutHelper.WalletDimensions.cardSize.height / 2)
            return stackScrollViewInitialOffset - desiredOffset
        }

        static let stackScrollViewMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        static let stackScrollViewContentInsets = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
    }
}
