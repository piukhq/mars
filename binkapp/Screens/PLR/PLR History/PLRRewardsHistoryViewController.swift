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
    
        // TODO: Tidy this up
        // TOOD: Add tap gesture to navigate to reward detail
        if let vouchers = viewModel.vouchers {
            for voucher in vouchers {
                let state = VoucherState(rawValue: voucher.state ?? "")
                switch (state, voucher.earnType) {
                case (.inProgress, .accumulator), (.issued, .accumulator):
                    let cell: PLRAccumulatorActiveCell = .fromNib()
                    let cellViewModel = PLRCellViewModel(voucher: voucher)
                    cell.configureWithViewModel(cellViewModel)
                    stackScrollView.add(arrangedSubview: cell)
                case (.redeemed, .accumulator), (.expired, .accumulator):
                    let cell: PLRAccumulatorInactiveCell = .fromNib()
                    let cellViewModel = PLRCellViewModel(voucher: voucher)
                    cell.configureWithViewModel(cellViewModel)
                    stackScrollView.add(arrangedSubview: cell)
                case (.inProgress, .stamps), (.issued, .stamps):
                    let cell: PLRStampsActiveCell = .fromNib()
                    let cellViewModel = PLRCellViewModel(voucher: voucher)
                    cell.configureWithViewModel(cellViewModel)
                    stackScrollView.add(arrangedSubview: cell)
                case (.redeemed, .stamps), (.expired, .stamps):
                    let cell: PLRStampsInactiveCell = .fromNib()
                    let cellViewModel = PLRCellViewModel(voucher: voucher)
                    cell.configureWithViewModel(cellViewModel)
                    stackScrollView.add(arrangedSubview: cell)
                default:
                    break
                }
            }
        }
    }

}

//extension PLRRewardsHistoryViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return viewModel.vouchersCount
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        guard let voucher = viewModel.voucherForIndexPath(indexPath) else {
//            fatalError("Could not get voucher for index path")
//        }
//
//        let cellViewModel = PLRCellViewModel(voucher: voucher)
//        if voucher.earnType == .accumulator {
//            let cell: PLRAccumulatorInactiveCell = collectionView.dequeue(indexPath: indexPath)
//            cell.configureWithViewModel(cellViewModel)
//            return cell
//        } else if voucher.earnType == .stamps {
//            let cell: PLRStampsInactiveCell = collectionView.dequeue(indexPath: indexPath)
//            cell.configureWithViewModel(cellViewModel)
//            return cell
//        } else {
//            fatalError("Could not get voucher earn type")
//        }
//    }
//
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        guard let voucher = viewModel.voucherForIndexPath(indexPath) else { return }
//        viewModel.toVoucherDetailScreen(voucher: voucher)
//    }
//}
