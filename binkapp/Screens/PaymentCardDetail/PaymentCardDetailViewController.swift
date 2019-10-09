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
        stackView.margin = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        view.addSubview(stackView)
        return stackView
    }()

    private lazy var card: PaymentCardCollectionViewCell = {
        let cell: PaymentCardCollectionViewCell = .fromNib()
        cell.translatesAutoresizingMaskIntoConstraints = false
        return cell
    }()

    private lazy var titleLabel: UILabel = {
        let title = UILabel()
        title.font = UIFont.headline
        title.textAlignment = .left
        title.translatesAutoresizingMaskIntoConstraints = false
        return title
    }()

    private lazy var descriptionLabel: UILabel = {
        let description = UILabel()
        description.font = UIFont.bodyTextLarge
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

        titleLabel.text = viewModel.titleText
        descriptionLabel.text = viewModel.descriptionText

        linkedCardsTableView.delegate = self
        linkedCardsTableView.dataSource = self
        informationTableView.delegate = self
        informationTableView.dataSource = self

        stackScrollView.delegate = self
        stackScrollView.insert(arrangedSubview: card, atIndex: 0, customSpacing: 30)
        stackScrollView.add(arrangedSubviews: [titleLabel, descriptionLabel, linkedCardsTableView, informationTableView])

        NSLayoutConstraint.activate([
            stackScrollView.topAnchor.constraint(equalTo: view.topAnchor),
            stackScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stackScrollView.leftAnchor.constraint(equalTo: view.leftAnchor),
            stackScrollView.rightAnchor.constraint(equalTo: view.rightAnchor),
            card.heightAnchor.constraint(equalToConstant: LayoutHelper.WalletDimensions.cardSize.height),
            card.widthAnchor.constraint(equalTo: stackScrollView.widthAnchor, constant: -50),
            titleLabel.leftAnchor.constraint(equalTo: stackScrollView.leftAnchor, constant: 25),
            titleLabel.rightAnchor.constraint(equalTo: stackScrollView.rightAnchor, constant: -25),
            descriptionLabel.leftAnchor.constraint(equalTo: stackScrollView.leftAnchor, constant: 25),
            descriptionLabel.rightAnchor.constraint(equalTo: stackScrollView.rightAnchor, constant: -25),
            linkedCardsTableView.widthAnchor.constraint(equalTo: stackScrollView.widthAnchor),
            informationTableView.widthAnchor.constraint(equalTo: stackScrollView.widthAnchor),
        ])

        linkedCardsTableView.register(LinkedLoyaltyCardTableViewCell.self, asNib: true)
        informationTableView.register(CardDetailInfoTableViewCell.self, asNib: true)
        linkedCardsTableView.separatorInset = UIEdgeInsets(top: 0, left: 25, bottom: 0, right: 25)
        informationTableView.separatorInset = UIEdgeInsets(top: 0, left: 25, bottom: 0, right: 25)

        getLinkedCards()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // This is due to strange layout issues on first appearance
        if !hasSetupCell {
            hasSetupCell = true
            card.frame = CGRect(origin: .zero, size: CGSize(width: stackScrollView.frame.width - 50, height: LayoutHelper.WalletDimensions.cardSize.height))
            card.configureWithViewModel(viewModel.paymentCardCellViewModel)
        }
    }

    private func getLinkedCards() {
        viewModel.getLinkedMembershipCards { [weak self] in
            self?.linkedCardsTableView.reloadData()
        }
    }

    private func refreshViews() {
        self.card.configureWithViewModel(self.viewModel.paymentCardCellViewModel)
        self.linkedCardsTableView.reloadData()
        Current.wallet.refreshLocal()
    }

}

extension PaymentCardDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == linkedCardsTableView {
            return viewModel.pllEnabledMembershipCardsCount
        }

        if tableView == informationTableView {
            return viewModel.informationRows.count
        }

        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == linkedCardsTableView {
            let cell: LinkedLoyaltyCardTableViewCell = tableView.dequeue(indexPath: indexPath)

            guard let membershipCard = viewModel.membershipCard(forIndexPath: indexPath) else {
                return cell
            }

            let isLinked = viewModel.membershipCardIsLinked(membershipCard)
            let cellViewModel = LinkedLoyaltyCellViewModel(membershipCard: membershipCard, isLinked: isLinked)

            cell.configureWithViewModel(cellViewModel, delegate: self)

            return cell
        }

        if tableView == informationTableView {
            let cell: CardDetailInfoTableViewCell = tableView.dequeue(indexPath: indexPath)

            let informationRow = viewModel.informationRow(forIndexPath: indexPath)
            cell.configureWithInformationRow(informationRow)

            return cell
        }
        
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == informationTableView {
            viewModel.performActionForInformationRow(atIndexPath: indexPath)
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView == linkedCardsTableView ? 100 : 88
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return makeTableViewSeparator()
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if viewModel.pllEnabledMembershipCardsCount == 0 {
            return 0.0
        }
        return tableView == linkedCardsTableView ? 0.5 : 0.0
    }
}

extension PaymentCardDetailViewController: LinkedLoyaltyCardCellDelegate {
    func linkedLoyaltyCardCell(_ cell: LinkedLoyaltyCardTableViewCell, shouldToggleLinkedStateForMembershipCard membershipCard: CD_MembershipCard) {
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

        let offset: CGFloat = 44 + 20 + 20 + 60
        navigationItem.titleView = scrollView.contentOffset.y > 108 - offset ? titleView : nil
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
