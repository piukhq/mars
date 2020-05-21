//
//  PLRRewardDetailViewController.swift
//  binkapp
//
//  Created by Nick Farrant on 11/11/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class PLRRewardDetailViewController: BinkTrackableViewController {

    // MARK: - UI properties

    private lazy var stackScrollView: StackScrollView = {
        let stackView = StackScrollView(axis: .vertical, arrangedSubviews: nil, adjustForKeyboard: true)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = .clear
        stackView.distribution = .fill
        stackView.alignment = .leading
        stackView.clipsToBounds = false
        stackView.margin = UIEdgeInsets(top: 16, left: 25, bottom: 20, right: 25)
        view.addSubview(stackView)
        return stackView
    }()

    private lazy var codeLabel: UILabel = {
        let label = UILabel()
        label.font = .headline
        label.numberOfLines = 0
        return label
    }()

    private lazy var headerLabel: UILabel = {
        let label = UILabel()
        label.font = .headline
        label.numberOfLines = 0
        return label
    }()

    private lazy var subtextLabel: UILabel = {
        let label = UILabel()
        label.font = .bodyTextLarge
        label.numberOfLines = 0
        return label
    }()

    private lazy var issuedDateLabel: UILabel = {
        let label = UILabel()
        label.font = .bodyTextSmall
        label.numberOfLines = 0
        return label
    }()

    private lazy var redeemedDateLabel: UILabel = {
        let label = UILabel()
        label.font = .bodyTextSmall
        label.numberOfLines = 0
        return label
    }()

    private lazy var expiryDateLabel: UILabel = {
        let label = UILabel()
        label.font = .bodyTextSmall
        label.numberOfLines = 0
        return label
    }()

    private lazy var termsAndConditionsButton: HyperlinkButton = {
        let button = HyperlinkButton()
        button.setTitle(viewModel.termsAndConditionsButtonTitle, for: .normal)
        button.setTitleColor(.blueAccent, for: .normal)
        button.titleLabel?.font = .linkUnderlined
        button.addTarget(self, action: #selector(handleTermsAndConditionsButtonPress), for: .touchUpInside)
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
        setupUI()
    }
}

private extension PLRRewardDetailViewController {
    func setupUI() {
        view.backgroundColor = .white
        title = viewModel.title

        switch (viewModel.voucherState, viewModel.voucherEarnType) {
        case (.inProgress, .accumulator), (.issued, .accumulator):
            let cell: PLRAccumulatorActiveCell = .fromNib()
            cell.configureWithViewModel(viewModel.voucherCellViewModel)
            stackScrollView.add(arrangedSubview: cell)
            cell.widthAnchor.constraint(equalTo: stackScrollView.widthAnchor, constant: -50).isActive = true
        case (.redeemed, .accumulator), (.expired, .accumulator):
            let cell: PLRAccumulatorInactiveCell = .fromNib()
            cell.configureWithViewModel(viewModel.voucherCellViewModel)
            stackScrollView.add(arrangedSubview: cell)
            cell.widthAnchor.constraint(equalTo: stackScrollView.widthAnchor, constant: -50).isActive = true
        case (.inProgress, .stamps), (.issued, .stamps):
            let cell: PLRStampsActiveCell = .fromNib()
            cell.configureWithViewModel(viewModel.voucherCellViewModel)
            stackScrollView.add(arrangedSubview: cell)
        case (.redeemed, .stamps), (.expired, .stamps):
            let cell: PLRStampsInactiveCell = .fromNib()
            cell.configureWithViewModel(viewModel.voucherCellViewModel)
            stackScrollView.add(arrangedSubview: cell)
        default:
            break
        }

        // View decisioning
        if viewModel.shouldShowCode {
            codeLabel.text = viewModel.codeString
            codeLabel.textColor = codeLabelColor(forState: viewModel.voucherState)
            stackScrollView.add(arrangedSubview: codeLabel)
            stackScrollView.customPadding(LayoutHelper.PLRRewardDetail.codeLabelTopPadding, before: codeLabel)
        }

        if viewModel.shouldShowHeader {
            headerLabel.text = viewModel.headerString
            stackScrollView.add(arrangedSubview: headerLabel)
            stackScrollView.customPadding(LayoutHelper.PLRRewardDetail.headerLabelTopPadding, before: headerLabel)
        }

        if viewModel.shouldShowSubtext {
            subtextLabel.text = viewModel.subtextString
            stackScrollView.add(arrangedSubview: subtextLabel)
            let topPadding = viewModel.shouldShowHeader ? LayoutHelper.PLRRewardDetail.subtextLabelUnderHeaderTopPadding : LayoutHelper.PLRRewardDetail.subtextLabelTopPadding
            stackScrollView.customPadding(topPadding, before: subtextLabel)
        }

        if viewModel.shouldShowIssuedDate {
            issuedDateLabel.text = viewModel.issuedDateString
            stackScrollView.add(arrangedSubview: issuedDateLabel)
            stackScrollView.customPadding(LayoutHelper.PLRRewardDetail.dateLabelsTopPadding, before: issuedDateLabel)
        }

        if viewModel.shouldShowRedeemedDate {
            redeemedDateLabel.text = viewModel.redeemedDateString
            stackScrollView.add(arrangedSubview: redeemedDateLabel)
            stackScrollView.customPadding(LayoutHelper.PLRRewardDetail.dateLabelsTopPadding, before: redeemedDateLabel)
        }

        if viewModel.shouldShowExpiredDate {
            expiryDateLabel.text = viewModel.expiredDateString
            stackScrollView.add(arrangedSubview: expiryDateLabel)
            stackScrollView.customPadding(LayoutHelper.PLRRewardDetail.dateLabelsTopPadding, before: expiryDateLabel)
        }

        if viewModel.shouldShowTermsAndConditionsButton {
            stackScrollView.add(arrangedSubview: termsAndConditionsButton)
            stackScrollView.customPadding(LayoutHelper.PLRRewardDetail.tAndCButtonTopPadding, before: termsAndConditionsButton)
        }

        setupLayout()
    }

    func setupLayout() {
        NSLayoutConstraint.activate([
            stackScrollView.topAnchor.constraint(equalTo: view.topAnchor),
            stackScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stackScrollView.leftAnchor.constraint(equalTo: view.leftAnchor),
            stackScrollView.rightAnchor.constraint(equalTo: view.rightAnchor),
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

    @objc func handleTermsAndConditionsButtonPress() {
        viewModel.openTermsAndConditionsWebView()
    }
}

extension LayoutHelper {
    struct PLRRewardDetail {
        static let stackViewPadding: CGFloat = 25
        static let codeLabelTopPadding: CGFloat = 48
        static let headerLabelTopPadding: CGFloat = 30
        static let subtextLabelTopPadding: CGFloat = 25
        static let subtextLabelUnderHeaderTopPadding: CGFloat = 4
        static let dateLabelsTopPadding: CGFloat = 8
        static let tAndCButtonTopPadding: CGFloat = 30
    }
}

private extension Selector {
    static let openTermsAndConditions = #selector(PLRRewardDetailViewController.handleTermsAndConditionsButtonPress)
}
