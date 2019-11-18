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
        stackView.alignment = .leading
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
        label.font = .headline
        return label
    }()

    private lazy var headerLabel: UILabel = {
        let label = UILabel()
        label.font = .headline
        return label
    }()

    private lazy var subtextLabel: UILabel = {
        let label = UILabel()
        label.font = .bodyTextLarge
        return label
    }()

    private lazy var issuedDateLabel: UILabel = {
        let label = UILabel()
        label.font = .bodyTextSmall
        return label
    }()

    private lazy var redeemedDateLabel: UILabel = {
        let label = UILabel()
        label.font = .bodyTextSmall
        return label
    }()

    private lazy var expiryDateLabel: UILabel = {
        let label = UILabel()
        label.font = .bodyTextSmall
        return label
    }()

    private lazy var termsAndConditionsButton: HyperlinkButton = {
        let button = HyperlinkButton()
        button.setTitle("Terms & Conditions", for: .normal)
        button.setTitleColor(.blueAccent, for: .normal)
        button.titleLabel?.font = .linkUnderlined
        return button
    }()

    private lazy var privacyPolicyButton: HyperlinkButton = {
        let button = HyperlinkButton()
        button.setTitle("Privacy Policy", for: .normal)
        button.setTitleColor(.blueAccent, for: .normal)
        button.titleLabel?.font = .linkUnderlined
        return button
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
        title = viewModel.title

        setupUI()
    }
}

private extension PLRRewardDetailViewController {
    func setupUI() {
        voucher.configureWithViewModel(viewModel.voucherCellViewModel)
        stackScrollView.add(arrangedSubviews: [voucher])

        // View decisioning
        if viewModel.shouldShowCode {
            codeLabel.text = viewModel.codeString
            codeLabel.textColor = codeLabelColor(forState: viewModel.voucherState)
            stackScrollView.add(arrangedSubview: codeLabel)
            NSLayoutConstraint.activate([
                codeLabel.widthAnchor.constraint(equalTo: stackScrollView.widthAnchor),
            ])
            stackScrollView.customPadding(48, before: codeLabel)
        }

        if viewModel.shouldShowHeader {
            headerLabel.text = viewModel.headerString
            stackScrollView.add(arrangedSubview: headerLabel)
            NSLayoutConstraint.activate([
                headerLabel.widthAnchor.constraint(equalTo: stackScrollView.widthAnchor),
            ])
            stackScrollView.customPadding(30, before: headerLabel)
        }

        if viewModel.shouldShowSubtext {
            subtextLabel.text = viewModel.subtextString
            stackScrollView.add(arrangedSubview: subtextLabel)
            NSLayoutConstraint.activate([
                subtextLabel.widthAnchor.constraint(equalTo: stackScrollView.widthAnchor),
            ])
            stackScrollView.customPadding(4, before: subtextLabel)
        }

        if viewModel.shouldShowIssuedDate {
            issuedDateLabel.text = viewModel.issuedDateString
            stackScrollView.add(arrangedSubview: issuedDateLabel)
            NSLayoutConstraint.activate([
                issuedDateLabel.widthAnchor.constraint(equalTo: stackScrollView.widthAnchor),
            ])
            stackScrollView.customPadding(8, before: issuedDateLabel)
        }

        if viewModel.shouldShowRedeemedDate {
            redeemedDateLabel.text = viewModel.redeemedDateString
            stackScrollView.add(arrangedSubview: redeemedDateLabel)
            NSLayoutConstraint.activate([
                redeemedDateLabel.widthAnchor.constraint(equalTo: stackScrollView.widthAnchor),
            ])
            stackScrollView.customPadding(8, before: redeemedDateLabel)
        }

        if viewModel.shouldShowExpiredDate {
            expiryDateLabel.text = viewModel.expiredDateString
            stackScrollView.add(arrangedSubview: expiryDateLabel)
            NSLayoutConstraint.activate([
                expiryDateLabel.widthAnchor.constraint(equalTo: stackScrollView.widthAnchor),
            ])
            stackScrollView.customPadding(8, before: expiryDateLabel)
        }

        stackScrollView.add(arrangedSubviews: [termsAndConditionsButton, privacyPolicyButton])
        stackScrollView.customPadding(30, before: termsAndConditionsButton)
        stackScrollView.customPadding(34, before: privacyPolicyButton)

        setupLayout()
    }

    func setupLayout() {
        NSLayoutConstraint.activate([
            stackScrollView.topAnchor.constraint(equalTo: view.topAnchor),
            stackScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stackScrollView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: LayoutHelper.PLRRewardDetail.stackViewPadding),
            stackScrollView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -LayoutHelper.PLRRewardDetail.stackViewPadding),
            voucher.topAnchor.constraint(equalTo: stackScrollView.topAnchor),
            voucher.widthAnchor.constraint(equalTo: stackScrollView.widthAnchor),
            voucher.heightAnchor.constraint(equalToConstant: LayoutHelper.PLRCollectionViewCell.accumulatorActiveCellHeight),
        ])
    }

    func codeLabelColor(forState state: VoucherState?) -> UIColor {
        switch state {
        case .issued:
            return .greenOk
        default:
            return .blueInactive
        }
    }
}

extension LayoutHelper {
    struct PLRRewardDetail {
        static let stackViewPadding: CGFloat = 25
    }
}
