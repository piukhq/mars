//
//  PLRRewardsHistoryViewController.swift
//  binkapp
//
//  Created by Nick Farrant on 11/11/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class PLRRewardsHistoryViewController: BinkViewController {
    enum Constants {
        static let stackViewMargin = UIEdgeInsets(top: 12, left: 25, bottom: 20, right: 25)
        static let postCellPadding: CGFloat = 20
    }
    
    private lazy var stackScrollView: StackScrollView = {
        let stackView = StackScrollView(axis: .vertical, arrangedSubviews: nil, adjustForKeyboard: true)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = .clear
        stackView.distribution = .fill
        stackView.alignment = .leading
        stackView.clipsToBounds = false
        stackView.margin = Constants.stackViewMargin
        view.addSubview(stackView)
        return stackView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .headline
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .bodyTextLarge
        return label
    }()

    private let viewModel: PLRRewardsHistoryViewModel

    init(viewModel: PLRRewardsHistoryViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = viewModel.navigationTitle

        titleLabel.text = viewModel.titleText
        subtitleLabel.text = viewModel.subtitleText

        stackScrollView.add(arrangedSubviews: [titleLabel, subtitleLabel])
        stackScrollView.customPadding(25, after: subtitleLabel)

        NSLayoutConstraint.activate([
            stackScrollView.topAnchor.constraint(equalTo: view.topAnchor),
            stackScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stackScrollView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])
        
        // MARK: - Add vouchers
    
        if let vouchers = viewModel.vouchers {
            for voucher in vouchers {
                let state = VoucherState(rawValue: voucher.state ?? "")
                switch (state, voucher.earnType) {
                case (.inProgress, .accumulator), (.issued, .accumulator):
                    setupCellForType(PLRAccumulatorActiveCell.self, voucher: voucher)
                case (.redeemed, .accumulator), (.expired, .accumulator), (.cancelled, .accumulator):
                    setupCellForType(PLRAccumulatorInactiveCell.self, voucher: voucher)
                case (.inProgress, .stamps), (.issued, .stamps):
                    setupCellForType(PLRStampsActiveCell.self, voucher: voucher)
                case (.redeemed, .stamps), (.expired, .stamps), (.cancelled, .stamps):
                    setupCellForType(PLRStampsInactiveCell.self, voucher: voucher)
                default:
                    break
                }
            }
        }
    }
    
    override func configureForCurrentTheme() {
        super.configureForCurrentTheme()
        titleLabel.textColor = Current.themeManager.color(for: .text)
        subtitleLabel.textColor = Current.themeManager.color(for: .text)
        navigationController?.navigationBar.tintColor = Current.themeManager.color(for: .text)
    }

    private func setupCellForType<T: PLRBaseCollectionViewCell>(_ cellType: T.Type, voucher: CD_Voucher) {
        let cell = PLRBaseCollectionViewCell.nibForCellType(cellType)
        let cellViewModel = PLRCellViewModel(voucher: voucher)
        cell.configureWithViewModel(cellViewModel) {
            self.viewModel.toVoucherDetailScreen(voucher: voucher)
        }
        stackScrollView.add(arrangedSubview: cell)
        cell.widthAnchor.constraint(equalTo: stackScrollView.widthAnchor, constant: -(LayoutHelper.LoyaltyCardDetail.contentPadding * 2)).isActive = true
        stackScrollView.customPadding(Constants.postCellPadding, after: cell)
    }
}
