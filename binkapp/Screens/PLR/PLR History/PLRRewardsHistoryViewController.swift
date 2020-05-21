//
//  PLRRewardsHistoryViewController.swift
//  binkapp
//
//  Created by Nick Farrant on 11/11/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class PLRRewardsHistoryViewController: BinkTrackableViewController {
    private lazy var stackScrollView: StackScrollView = {
        let stackView = StackScrollView(axis: .vertical, arrangedSubviews: nil, adjustForKeyboard: true)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = .clear
        stackView.distribution = .fill
        stackView.alignment = .leading
        stackView.clipsToBounds = false
        stackView.margin = UIEdgeInsets(top: 12, left: 25, bottom: 20, right: 25)
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

    init(viewModel: PLRRewardsHistoryViewModel){
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        title = viewModel.navigationTitle

        titleLabel.text = viewModel.titleText
        subtitleLabel.text = viewModel.subtitleText

        stackScrollView.add(arrangedSubviews: [titleLabel, subtitleLabel])
        stackScrollView.customPadding(25, after: subtitleLabel)

        NSLayoutConstraint.activate([
            stackScrollView.topAnchor.constraint(equalTo: view.topAnchor),
            stackScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stackScrollView.widthAnchor.constraint(equalTo: view.widthAnchor),
        ])
        
        // MARK: - Add vouchers
    
        // TODO: Only add padding if last in array
        if let vouchers = viewModel.vouchers {
            for voucher in vouchers {
                let state = VoucherState(rawValue: voucher.state ?? "")
                var cell = PLRBaseCollectionViewCell()
                switch (state, voucher.earnType) {
                case (.inProgress, .accumulator), (.issued, .accumulator):
                    cell = PLRBaseCollectionViewCell.nibForCellType(PLRAccumulatorActiveCell.self)
                case (.redeemed, .accumulator), (.expired, .accumulator):
                    cell = PLRBaseCollectionViewCell.nibForCellType(PLRAccumulatorInactiveCell.self)
                case (.inProgress, .stamps), (.issued, .stamps):
                    cell = PLRBaseCollectionViewCell.nibForCellType(PLRStampsActiveCell.self)
                case (.redeemed, .stamps), (.expired, .stamps):
                    cell = PLRBaseCollectionViewCell.nibForCellType(PLRStampsInactiveCell.self)
                default:
                    break
                }
                let cellViewModel = PLRCellViewModel(voucher: voucher)
                cell.configureWithViewModel(cellViewModel) {
                    self.viewModel.toVoucherDetailScreen(voucher: voucher)
                }
                stackScrollView.add(arrangedSubview: cell)
                cell.widthAnchor.constraint(equalTo: stackScrollView.widthAnchor, constant: -50).isActive = true
                stackScrollView.customPadding(12, after: cell)
            }
        }
    }

}
