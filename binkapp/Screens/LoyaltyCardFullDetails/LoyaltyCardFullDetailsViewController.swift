//
//  LoyaltyCardFullDetailsViewController.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class LoyaltyCardFullDetailsViewController: BinkTrackableViewController, BarBlurring {

    // MARK: - UI Lazy Variables

    private lazy var stackScrollView: StackScrollView = {
        let stackView = StackScrollView(axis: .vertical, arrangedSubviews: nil, adjustForKeyboard: true)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = .clear
        stackView.margin = LayoutHelper.PaymentCardDetail.stackScrollViewMargins
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.delegate = self
        stackView.contentInset = LayoutHelper.PaymentCardDetail.stackScrollViewContentInsets
        stackView.margin = UIEdgeInsets(top: 12, left: 25, bottom: 20, right: 25)
        return stackView
    }()

    private lazy var brandHeader: UIImageView = {
        let imageView = UIImageView()
        imageView.isUserInteractionEnabled = true
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        imageView.contentMode = .scaleAspectFill
        imageView.layer.applyDefaultBinkShadow()
        return imageView
    }()

    private lazy var showBarcodeButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = .bodyTextLarge
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(showBarcodeButtonPressed), for: .touchUpInside)
        return button
    }()

    private lazy var modulesStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [pointsModule, linkModule])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = .white
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.axis = .horizontal
        stackView.spacing = 12
        return stackView
    }()

    private lazy var pointsModule: BinkModuleView = {
        return BinkModuleView()
    }()

    private lazy var linkModule: BinkModuleView = {
        return BinkModuleView()
    }()

    private lazy var offerTilesStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = .white
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.axis = .vertical
        stackView.spacing = 12
        return stackView
    }()

    lazy var separator: UIView = {
        let separator = UIView()
        separator.backgroundColor = .lightGray
        separator.translatesAutoresizingMaskIntoConstraints = false
        return separator
    }()

    lazy var informationTableView: NestedTableView = {
        let tableView = NestedTableView(frame: .zero, style: .plain)
        tableView.separatorColor = .lightGray
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CardDetailInfoTableViewCell.self, asNib: true)
        tableView.separatorInset = LayoutHelper.LoyaltyCardDetail.informationTableSeparatorInset
        return tableView
    }()
    
    private let viewModel: LoyaltyCardFullDetailsViewModel
    internal lazy var blurBackground = defaultBlurredBackground()
    
    init(viewModel: LoyaltyCardFullDetailsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        setCloseButton()
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureModules()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setScreenName(trackedScreen: .loyaltyDetail)
    }
    
    // MARK: - Navigation Bar Blurring
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard let bar = navigationController?.navigationBar else { return }
        prepareBarWithBlur(bar: bar, blurBackground: blurBackground)
    }
}

// MARK: - Table view

extension LoyaltyCardFullDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.informationRows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CardDetailInfoTableViewCell = tableView.dequeue(indexPath: indexPath)

        let informationRow = viewModel.informationRow(forIndexPath: indexPath)
        cell.configureWithInformationRow(informationRow)

        if tableView.cellAtIndexPathIsLastInSection(indexPath) {
            cell.hideSeparator()
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.performActionForInformationRow(atIndexPath: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return LayoutHelper.PaymentCardDetail.informationRowCellHeight
    }
}

// MARK: - Private methods

private extension LoyaltyCardFullDetailsViewController {
    func setCloseButton() {
        let closeButton = UIBarButtonItem(image: UIImage(named: "close"), style: .plain, target: self, action: #selector(popToRootController
            ))
        self.navigationItem.setLeftBarButton(closeButton, animated: true)
    }

    func configureUI() {
        view.addSubview(stackScrollView)
        stackScrollView.add(arrangedSubview: brandHeader)

        stackScrollView.customPadding(LayoutHelper.LoyaltyCardDetail.headerToBarcodeButtonPadding, after: brandHeader)
        
        if viewModel.membershipCard.card?.barcode != nil || viewModel.membershipCard.card?.membershipId != nil {
            let showBarcode = viewModel.membershipCard.card?.barcode != nil
            let buttonTitle = showBarcode ? "details_header_show_barcode".localized : "details_header_show_card_number".localized
            showBarcodeButton.setTitle(buttonTitle, for: .normal)
            stackScrollView.add(arrangedSubview: showBarcodeButton)
            let gestureRecogniser = UITapGestureRecognizer(target: self, action: #selector(showBarcodeButtonPressed))
            brandHeader.addGestureRecognizer(gestureRecogniser)
        }

        stackScrollView.customPadding(LayoutHelper.LoyaltyCardDetail.contentPadding, after: showBarcodeButton)

        stackScrollView.add(arrangedSubview: modulesStackView)
        configureModules()

        stackScrollView.customPadding(LayoutHelper.LoyaltyCardDetail.contentPadding, after: modulesStackView)

        if viewModel.shouldShouldPLR {
            if let vouchers = viewModel.vouchers {
                for voucher in vouchers {
                    // TODO: Should be in viewModel
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
                    cell.widthAnchor.constraint(equalTo: stackScrollView.widthAnchor, constant: -(LayoutHelper.LoyaltyCardDetail.contentPadding * 2)).isActive = true
                    stackScrollView.customPadding(20, after: cell)
                }
            }
        }

        if viewModel.shouldShowOfferTiles {
            stackScrollView.add(arrangedSubview: offerTilesStackView)
            if let offerTileImageUrls = viewModel.getOfferTileImageUrls() {
                offerTileImageUrls.forEach { offer in
                    let offerView = OfferTileView()
                    offerView.translatesAutoresizingMaskIntoConstraints = false
                    offerView.configure(imageUrl: offer)
                    offerTilesStackView.addArrangedSubview(offerView)
                }
            }
            stackScrollView.customPadding(LayoutHelper.LoyaltyCardDetail.contentPadding, after: offerTilesStackView)
            NSLayoutConstraint.activate([
                offerTilesStackView.leftAnchor.constraint(equalTo: stackScrollView.leftAnchor, constant: LayoutHelper.LoyaltyCardDetail.contentPadding),
                offerTilesStackView.rightAnchor.constraint(equalTo: stackScrollView.rightAnchor, constant: -LayoutHelper.LoyaltyCardDetail.contentPadding),
            ])
        }

        stackScrollView.add(arrangedSubview: separator)

        stackScrollView.add(arrangedSubview: informationTableView)

        configureLayout()
        
        guard let plan = viewModel.membershipCard.membershipPlan else { return }
        
        // Build Placeholder
        if let hexStringColor = viewModel.membershipCard.card?.colour {
            brandHeader.backgroundColor = UIColor(hexString: hexStringColor)
            brandHeader.layoutIfNeeded()
            let placeholderName = plan.account?.planNameCard ?? plan.account?.planName ?? ""
            let placeholder = LCDPlaceholderGenerator.generate(with: hexStringColor, planName: placeholderName, destSize: brandHeader.frame.size)
            brandHeader.backgroundColor = UIColor(patternImage: placeholder)
        }
        if viewModel.isMembershipCardAuthorised {
            brandHeader.setImage(forPathType: .membershipPlanTier(card: viewModel.membershipCard), animated: true)
        } else {
            brandHeader.setImage(forPathType: .membershipPlanHero(plan: plan), animated: true)
        }
    }

    func configureLayout() {
        NSLayoutConstraint.activate([
            stackScrollView.topAnchor.constraint(equalTo: view.topAnchor),
            stackScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stackScrollView.leftAnchor.constraint(equalTo: view.leftAnchor),
            stackScrollView.rightAnchor.constraint(equalTo: view.rightAnchor),
            brandHeader.leftAnchor.constraint(equalTo: stackScrollView.leftAnchor, constant: LayoutHelper.LoyaltyCardDetail.contentPadding),
            brandHeader.rightAnchor.constraint(equalTo: stackScrollView.rightAnchor, constant: -LayoutHelper.LoyaltyCardDetail.contentPadding),
            brandHeader.heightAnchor.constraint(equalTo: brandHeader.widthAnchor, multiplier: LayoutHelper.LoyaltyCardDetail.brandHeaderAspectRatio),
            showBarcodeButton.heightAnchor.constraint(equalToConstant: LayoutHelper.LoyaltyCardDetail.barcodeButtonHeight),
            modulesStackView.heightAnchor.constraint(equalToConstant: LayoutHelper.LoyaltyCardDetail.modulesStackViewHeight),
            modulesStackView.leftAnchor.constraint(equalTo: stackScrollView.leftAnchor, constant: LayoutHelper.LoyaltyCardDetail.contentPadding),
            modulesStackView.rightAnchor.constraint(equalTo: stackScrollView.rightAnchor, constant: -LayoutHelper.LoyaltyCardDetail.contentPadding),
            separator.heightAnchor.constraint(equalToConstant: CGFloat.onePointScaled()),
            separator.widthAnchor.constraint(equalTo: stackScrollView.widthAnchor),
            informationTableView.widthAnchor.constraint(equalTo: stackScrollView.widthAnchor),
        ])
    }
    
    func configureModules() {
        pointsModule.configure(moduleType: .points, membershipCard: viewModel.membershipCard, delegate: self)
        linkModule.configure(moduleType: .link, membershipCard: viewModel.membershipCard, paymentCards: viewModel.paymentCards, delegate: self)
    }
    
    @objc func popToRootController() {
        viewModel.popToRootController()
    }

    @objc func showBarcodeButtonPressed() {
        viewModel.toBarcodeModel()
    }
}

// MARK: - CardDetailInformationRowFactoryDelegate

extension LoyaltyCardFullDetailsViewController: CardDetailInformationRowFactoryDelegate {
    func cardDetailInformationRowFactory(_ factory: PaymentCardDetailInformationRowFactory, shouldPerformActionForRowType informationRowType: CardDetailInformationRow.RowType) {
        switch informationRowType {
        case .about:
            viewModel.toAboutMembershipPlanScreen()
        case .securityAndPrivacy:
            viewModel.toSecurityAndPrivacyScreen()
        case .deleteMembershipCard:
            viewModel.showDeleteConfirmationAlert()
        case .rewardsHistory:
            viewModel.toRewardsHistoryScreen()
        default:
            return
        }
    }
}

// MARK: - PointsModuleViewDelegate

extension LoyaltyCardFullDetailsViewController: BinkModuleViewDelegate {
    func binkModuleViewWasTapped(moduleView: BinkModuleView, withAction action: BinkModuleView.BinkModuleAction) {
        viewModel.goToScreenForAction(action: action)
    }
}

// MARK: - Navigation title scrolling behaviour

extension LoyaltyCardFullDetailsViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let titleView: DetailNavigationTitleView = .fromNib()
        titleView.configureWithTitle(viewModel.brandName, detail: viewModel.pointsValueText)

        let offset = LayoutHelper.LoyaltyCardDetail.navBarTitleViewScrollOffset
        navigationItem.titleView = scrollView.contentOffset.y > offset ? titleView : nil
    }
}

extension LayoutHelper {
    struct LoyaltyCardDetail {
        static let navBarTitleViewScrollOffset: CGFloat = 100
        static let contentPadding: CGFloat = 25
        static let headerToBarcodeButtonPadding: CGFloat = 12
        static let brandHeaderAspectRatio: CGFloat = 115/182
        static let modulesStackViewHeight: CGFloat = 128
        static let barcodeButtonHeight: CGFloat = 22
        static let informationTableSeparatorInset = UIEdgeInsets(top: 0, left: 25, bottom: 0, right: 25)
    }
}
