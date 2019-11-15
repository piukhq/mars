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
        stackView.clipsToBounds = false
        stackView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 0, right: 0)
        view.addSubview(stackView)
        return stackView
    }()

    private lazy var voucher: PLRAccumulatorActiveCell = {
        let cell: PLRAccumulatorActiveCell = .fromNib()
        cell.translatesAutoresizingMaskIntoConstraints = false
        return cell
    }()

    private lazy var codeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = .headline
        label.text = "012 345 678 910"
        return label
    }()

    private lazy var headerLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = .headline
        label.text = "Your £5 voucher is ready!"
        return label
    }()

    private lazy var subtextLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = .bodyTextLarge
        label.text = "for joining FatFace Rewards"
        return label
    }()

    private lazy var issuedDateLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = .bodyTextSmall
        label.text = "Issued date"
        return label
    }()

    private lazy var redeemedDateLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = .bodyTextSmall
        label.text = "Redeemed date"
        return label
    }()

    private lazy var expiryDateLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = .bodyTextSmall
        label.text = "Expired date"
        return label
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
}

private extension PLRRewardDetailViewController {
    func setupUI() {
        voucher.configureWithViewModel(viewModel.voucherCellViewModel)
        stackScrollView.add(arrangedSubviews: [voucher, codeLabel, headerLabel, subtextLabel, issuedDateLabel, redeemedDateLabel, expiryDateLabel])

        // View decisioning
        codeLabel.isHidden = !viewModel.shouldShowCode
        headerLabel.isHidden = !viewModel.shouldShowHeader
        subtextLabel.isHidden = !viewModel.shouldShowSubtext
        issuedDateLabel.isHidden = !viewModel.shouldShowIssuedDate
        redeemedDateLabel.isHidden = !viewModel.shouldShowRedeemedDate
        expiryDateLabel.isHidden = !viewModel.shouldShowExpiredDate

        // Values
        codeLabel.text = viewModel.codeString
        headerLabel.text = viewModel.headerString
        subtextLabel.text = viewModel.subtextString
        issuedDateLabel.text = viewModel.issuedDateString
        redeemedDateLabel.text = viewModel.redeemedDateString
        expiryDateLabel.text = viewModel.expiredDateString

        setupLayout()
    }

    func setupLayout() {
        NSLayoutConstraint.activate([
            stackScrollView.topAnchor.constraint(equalTo: view.topAnchor),
            stackScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stackScrollView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 25),
            stackScrollView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -25),
            voucher.topAnchor.constraint(equalTo: stackScrollView.topAnchor),
            voucher.widthAnchor.constraint(equalTo: stackScrollView.widthAnchor),
            voucher.heightAnchor.constraint(equalToConstant: 188),
            codeLabel.widthAnchor.constraint(equalTo: stackScrollView.widthAnchor),
            headerLabel.widthAnchor.constraint(equalTo: stackScrollView.widthAnchor),
            subtextLabel.widthAnchor.constraint(equalTo: stackScrollView.widthAnchor),
            issuedDateLabel.widthAnchor.constraint(equalTo: stackScrollView.widthAnchor),
            redeemedDateLabel.widthAnchor.constraint(equalTo: stackScrollView.widthAnchor),
            expiryDateLabel.widthAnchor.constraint(equalTo: stackScrollView.widthAnchor),
        ])
    }
}
