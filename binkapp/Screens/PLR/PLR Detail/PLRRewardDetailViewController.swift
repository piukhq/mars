//
//  PLRRewardDetailViewController.swift
//  binkapp
//
//  Created by Nick Farrant on 11/11/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class PLRRewardDetailViewController: UIViewController {

    // MARK: - UI properties

    private lazy var stackScrollView: StackScrollView = {
        let stackView = StackScrollView(axis: .vertical, arrangedSubviews: nil, adjustForKeyboard: true)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = .clear
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 0, right: 0)
        view.addSubview(stackView)
        return stackView
    }()

    private lazy var voucher: PLRAccumulatorActiveCell = {
        let cell: PLRAccumulatorActiveCell = .fromNib()
        cell.translatesAutoresizingMaskIntoConstraints = false
        return cell
    }()

    // MARK: - Properties

    private let viewModel: PLRRewardDetailViewModel
    private var hasSetupCell = false

    // MARK: - Init and view lifecycle

    init(viewModel: PLRRewardDetailViewModel){
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "FatFace"

        setupUI()
    }

//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//
//        // This is due to strange layout issues on first appearance
//        if !hasSetupCell {
//            hasSetupCell = true
//            let cardWidth = stackScrollView.frame.width - LayoutHelper.PaymentCardDetail.cardViewPadding
//            let cardHeight = LayoutHelper.WalletDimensions.cardSize.height
//            card.frame = CGRect(origin: .zero, size: CGSize(width: cardWidth, height: cardHeight))
//            card.configureWithViewModel(viewModel.paymentCardCellViewModel, delegate: nil)
//        }
//    }
}

private extension PLRRewardDetailViewController {
    func setupUI() {
        voucher.configureWithViewModel(viewModel.voucherCellViewModel)
        stackScrollView.add(arrangedSubview: voucher)

        setupLayout()
    }

    func setupLayout() {
        NSLayoutConstraint.activate([
            stackScrollView.topAnchor.constraint(equalTo: view.topAnchor),
            stackScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stackScrollView.leftAnchor.constraint(equalTo: view.leftAnchor),
            stackScrollView.rightAnchor.constraint(equalTo: view.rightAnchor),
            voucher.topAnchor.constraint(equalTo: stackScrollView.topAnchor),
            voucher.widthAnchor.constraint(equalTo: stackScrollView.widthAnchor, constant: -50),
            voucher.heightAnchor.constraint(equalToConstant: 188),
        ])
    }
}
