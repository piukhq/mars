//
//  PLRRewardsHistoryViewController.swift
//  binkapp
//
//  Created by Nick Farrant on 11/11/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class PLRRewardsHistoryViewController: UIViewController {
    private lazy var stackScrollView: StackScrollView = {
        let stackView = StackScrollView(axis: .vertical, arrangedSubviews: nil, adjustForKeyboard: true)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = .clear
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.clipsToBounds = false
        stackView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 20, right: 0)
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

    private lazy var collectionView: NestedCollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 12
        let collectionView = NestedCollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.isScrollEnabled = false
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        collectionView.clipsToBounds = false
        collectionView.register(PLRAccumulatorInactiveCell.self, asNib: true)
        return collectionView
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

        stackScrollView.add(arrangedSubviews: [titleLabel, subtitleLabel, collectionView])
        stackScrollView.customPadding(25, after: subtitleLabel)

        NSLayoutConstraint.activate([
            stackScrollView.topAnchor.constraint(equalTo: view.topAnchor),
            stackScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stackScrollView.leftAnchor.constraint(equalTo: view.leftAnchor),
            stackScrollView.rightAnchor.constraint(equalTo: view.rightAnchor),
            collectionView.widthAnchor.constraint(equalTo: stackScrollView.widthAnchor, constant: -50),
            titleLabel.widthAnchor.constraint(equalTo: stackScrollView.widthAnchor, constant: -50),
            subtitleLabel.widthAnchor.constraint(equalTo: stackScrollView.widthAnchor, constant: -50),
        ])
    }

}

extension PLRRewardsHistoryViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.vouchersCount
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: PLRAccumulatorInactiveCell = collectionView.dequeue(indexPath: indexPath)

        guard let voucher = viewModel.voucherForIndexPath(indexPath) else { return cell }

        let cellViewModel = PLRCellViewModel(voucher: voucher)
        cell.configureWithViewModel(cellViewModel)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: LayoutHelper.PLRCollectionViewCell.accumulatorInactiveCellHeight)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let voucher = viewModel.voucherForIndexPath(indexPath) else { return }
        viewModel.toVoucherDetailScreen(voucher: voucher)
    }
}
