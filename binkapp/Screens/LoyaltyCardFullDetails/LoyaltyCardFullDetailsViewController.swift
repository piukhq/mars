//
//  LoyaltyCardFullDetailsViewController.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

protocol LoyaltyCardFullDetailsModalDelegate: AnyObject {
    func modalWillDismiss()
}

class LoyaltyCardFullDetailsViewController: BinkViewController, InAppReviewable {
    enum Constants {
        static let stackViewMargin = UIEdgeInsets(top: 12, left: 25, bottom: 20, right: 25)
        static let stackViewSpacing: CGFloat = 12
        static let postCellPadding: CGFloat = 20
        static let cornerRadius: CGFloat = 12
    }
    
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
        return stackView
    }()
    
    lazy var brandHeader: UIImageView = {
        let imageView = UIImageView()
        imageView.isUserInteractionEnabled = true
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = Constants.cornerRadius
        imageView.contentMode = .scaleAspectFill
        imageView.layer.applyDefaultBinkShadow()
        return imageView
    }()
    
    lazy var secondaryColorView: UIView = {
        let secondaryColorView = UIView()
        secondaryColorView.translatesAutoresizingMaskIntoConstraints = false
        secondaryColorView.backgroundColor = viewModel.secondaryColor
        return secondaryColorView
    }()
    
    private lazy var brandHeaderBarcodeButtonPadding: UIView = {
        let paddingView = UIView()
        paddingView.translatesAutoresizingMaskIntoConstraints = false
        return paddingView
    }()
    
    private lazy var showBarcodeButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = .bodyTextLarge
        button.addTarget(self, action: #selector(showBarcodeButtonPressed), for: .touchUpInside)
        return button
    }()
    
    private lazy var modulesStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [pointsModule, linkModule])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = .clear
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.axis = .horizontal
        stackView.spacing = Constants.stackViewSpacing
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
        stackView.backgroundColor = .clear
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.axis = .vertical
        stackView.spacing = Constants.stackViewSpacing
        return stackView
    }()
    
    lazy var separator: UIView = {
        let separator = UIView()
        separator.translatesAutoresizingMaskIntoConstraints = false
        return separator
    }()
    
    lazy var informationTableView: NestedTableView = {
        let tableView = NestedTableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .clear
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CardDetailInfoTableViewCell.self, asNib: true)
        tableView.separatorInset = LayoutHelper.LoyaltyCardDetail.informationTableSeparatorInset
        return tableView
    }()
    
    let viewModel: LoyaltyCardFullDetailsViewModel
    var navigationBarShouldBeVisible = false
    private var previousOffset = 0.0
    private var topConstraint: NSLayoutConstraint?
    private lazy var contentAnimationSpacerHeightConstraint: NSLayoutConstraint = {
        let constraint = brandHeaderBarcodeButtonPadding.heightAnchor.constraint(equalToConstant: LayoutHelper.LoyaltyCardDetail.animationSpacerHeight)
        constraint.isActive = true
        return constraint
    }()
    private var didLayoutSubviews = false
    private var statusBarStyle: UIStatusBarStyle = .darkContent

    private let titleView: DetailNavigationTitleView = .fromNib()

    init(viewModel: LoyaltyCardFullDetailsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        NotificationCenter.default.addObserver(self, selector: #selector(handlePointsScrapingUpdate), name: .webScrapingUtilityDidComplete, object: nil)
    }
    
    @objc private func handlePointsScrapingUpdate() {
        DispatchQueue.main.async {
            self.configureModules()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureModules()
        navigationController?.setNavigationBarVisibility(navigationBarShouldBeVisible, animated: false)
        setNavigationBarAppearanceLight(viewModel.secondaryColourIsDark)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setScreenName(trackedScreen: .loyaltyDetail)
        navigationController?.setNavigationBarVisibility(navigationBarShouldBeVisible, animated: false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarVisibility(true, animated: true)
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        /// We know that if we are dismissing the LCD, we will always be returned to the loyalty wallet
        if PllLoyaltyInAppReviewableJourney.isInProgress {
            requestInAppReview()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        didLayoutSubviews = true
        if didLayoutSubviews {
            animatePadding()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        statusBarStyle
    }

    override func configureForCurrentTheme() {
        super.configureForCurrentTheme()
        navigationController?.setNavigationBarVisibility(navigationBarShouldBeVisible, animated: true)
        showBarcodeButton.setTitleColor(Current.themeManager.color(for: .text), for: .normal)
        separator.backgroundColor = Current.themeManager.color(for: .divider)
        informationTableView.separatorColor = Current.themeManager.color(for: .divider)
        informationTableView.reloadData()
        titleView.configureWithTitle(viewModel.brandName, detail: viewModel.pointsValueText)
        
        guard let plan = viewModel.membershipCard.membershipPlan else { return }
        if viewModel.isMembershipCardAuthorised {
            brandHeader.setImage(forPathType: .membershipPlanTier(card: viewModel.membershipCard), animated: true)
        } else {
            brandHeader.setImage(forPathType: .membershipPlanHero(plan: plan), animated: true)
        }

        let plrVoucherCells = stackScrollView.arrangedSubviews.filter { $0.isKind(of: PLRBaseCollectionViewCell.self) }
        if let voucherCells = plrVoucherCells as? [PLRBaseCollectionViewCell], let vouchers = viewModel.vouchers {
            for index in 0..<voucherCells.count {
                let cellViewModel = PLRCellViewModel(voucher: vouchers[index])
                voucherCells[index].configureWithViewModel(cellViewModel) { [weak self] in
                    self?.viewModel.toVoucherDetailScreen(voucher: vouchers[index])
                }
            }
        }
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
    func configureUI() {
        view.addSubview(stackScrollView)
        stackScrollView.add(arrangedSubview: brandHeader)
        view.insertSubview(secondaryColorView, belowSubview: brandHeader)
        stackScrollView.customPadding(LayoutHelper.LoyaltyCardDetail.headerToBarcodeButtonPadding, after: brandHeader)
        stackScrollView.add(arrangedSubview: brandHeaderBarcodeButtonPadding)
        
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
                    let state = viewModel.state(forVoucher: voucher)
                    switch (state, voucher.earnType) {
                    case (.inProgress, .accumulator), (.issued, .accumulator):
                        setupCellForType(PLRAccumulatorActiveCell.self, voucher: voucher)
                    case (.redeemed, .accumulator), (.expired, .accumulator):
                        setupCellForType(PLRAccumulatorInactiveCell.self, voucher: voucher)
                    case (.inProgress, .stamps), (.issued, .stamps):
                        setupCellForType(PLRStampsActiveCell.self, voucher: voucher)
                    case (.redeemed, .stamps), (.expired, .stamps):
                        setupCellForType(PLRStampsInactiveCell.self, voucher: voucher)
                    default:
                        break
                    }
                }
            }
        }
        
        if viewModel.shouldShowOfferTiles {
            stackScrollView.add(arrangedSubview: offerTilesStackView)
            viewModel.offerTileImages?.forEach { offerTileImage in
                let offerTileView = OfferTileView(offerTileImage: offerTileImage)
                offerTileView.translatesAutoresizingMaskIntoConstraints = false
                offerTilesStackView.addArrangedSubview(offerTileView)
            }
            stackScrollView.customPadding(LayoutHelper.LoyaltyCardDetail.contentPadding, after: offerTilesStackView)
            NSLayoutConstraint.activate([
                offerTilesStackView.leftAnchor.constraint(equalTo: stackScrollView.leftAnchor, constant: LayoutHelper.LoyaltyCardDetail.contentPadding),
                offerTilesStackView.rightAnchor.constraint(equalTo: stackScrollView.rightAnchor, constant: -LayoutHelper.LoyaltyCardDetail.contentPadding)
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
        
        configureSecondaryColorViewLayout()
    }
    
    private func setupCellForType<T: PLRBaseCollectionViewCell>(_ cellType: T.Type, voucher: CD_Voucher) {
        let cell = PLRBaseCollectionViewCell.nibForCellType(cellType)
        let cellViewModel = PLRCellViewModel(voucher: voucher)
        cell.configureWithViewModel(cellViewModel) { [weak self] in
            self?.viewModel.toVoucherDetailScreen(voucher: voucher)
        }
        stackScrollView.add(arrangedSubview: cell)
        cell.widthAnchor.constraint(equalTo: stackScrollView.widthAnchor, constant: -(LayoutHelper.LoyaltyCardDetail.contentPadding * 2)).isActive = true
        stackScrollView.customPadding(Constants.postCellPadding, after: cell)
    }
    
    func configureLayout() {
        NSLayoutConstraint.activate([
            stackScrollView.topAnchor.constraint(equalTo: view.topAnchor),
            stackScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stackScrollView.leftAnchor.constraint(equalTo: view.leftAnchor),
            stackScrollView.rightAnchor.constraint(equalTo: view.rightAnchor),
            brandHeader.leftAnchor.constraint(equalTo: stackScrollView.leftAnchor, constant: LayoutHelper.LoyaltyCardDetail.contentPadding),
            brandHeader.rightAnchor.constraint(equalTo: stackScrollView.rightAnchor, constant: -LayoutHelper.LoyaltyCardDetail.contentPadding),
            brandHeader.heightAnchor.constraint(equalTo: brandHeader.widthAnchor, multiplier: viewModel.brandHeaderAspectRatio),
            contentAnimationSpacerHeightConstraint,
            showBarcodeButton.heightAnchor.constraint(equalToConstant: LayoutHelper.LoyaltyCardDetail.barcodeButtonHeight),
            modulesStackView.heightAnchor.constraint(equalToConstant: LayoutHelper.LoyaltyCardDetail.modulesStackViewHeight),
            modulesStackView.leftAnchor.constraint(equalTo: stackScrollView.leftAnchor, constant: LayoutHelper.LoyaltyCardDetail.contentPadding),
            modulesStackView.rightAnchor.constraint(equalTo: stackScrollView.rightAnchor, constant: -LayoutHelper.LoyaltyCardDetail.contentPadding),
            separator.heightAnchor.constraint(equalToConstant: CGFloat.onePointScaled()),
            separator.widthAnchor.constraint(equalTo: stackScrollView.widthAnchor),
            informationTableView.widthAnchor.constraint(equalTo: stackScrollView.widthAnchor)
        ])
    }
    
    func configureSecondaryColorViewLayout() {
        topConstraint = secondaryColorView.topAnchor.constraint(equalTo: stackScrollView.topAnchor)
        topConstraint?.priority = .almostRequired
        NSLayoutConstraint.activate([
            secondaryColorView.leftAnchor.constraint(equalTo: brandHeader.leftAnchor, constant: -LayoutHelper.LoyaltyCardDetail.contentPadding),
            secondaryColorView.rightAnchor.constraint(equalTo: brandHeader.rightAnchor, constant: LayoutHelper.LoyaltyCardDetail.contentPadding),
            secondaryColorView.bottomAnchor.constraint(equalTo: brandHeader.bottomAnchor, constant: -brandHeader.frame.height / 2)
        ])

        topConstraint?.isActive = true
        view.sendSubviewToBack(secondaryColorView)
    }

    
    private func setNavigationBarAppearanceLight(_ lightAppearance: Bool) {
        switch (lightAppearance, viewModel.secondaryColourIsDark, navigationBarShouldBeVisible, traitCollection.userInterfaceStyle, Current.themeManager.currentTheme.type) {
        case (true, true, false, _, _), (true, _, _, .dark, .dark), (true, _, _, .dark, .system), (_, _, _, _, .dark):
            navigationController?.navigationBar.tintColor = .white
            statusBarStyle = .lightContent
        default:
            navigationController?.navigationBar.tintColor = .black
            statusBarStyle = .darkContent
        }
        setNeedsStatusBarAppearanceUpdate()
    }
    
    func configureModules() {
        pointsModule.configure(moduleType: .points, membershipCard: viewModel.membershipCard, delegate: self)
        linkModule.configure(moduleType: .link, membershipCard: viewModel.membershipCard, paymentCards: viewModel.paymentCards, delegate: self)
    }
    
    @objc func showBarcodeButtonPressed() {
        viewModel.toBarcodeModel()
    }
    
    private func animatePadding() {
        view.layoutIfNeeded()
        self.contentAnimationSpacerHeightConstraint.constant = 0
        UIView.animate(withDuration: 0.4) {
            self.view.layoutIfNeeded()
        }
    }
}

// MARK: - CardDetailInformationRowFactoryDelegate

extension LoyaltyCardFullDetailsViewController: CardDetailInformationRowFactoryDelegate {
    func cardDetailInformationRowFactory(_ factory: WalletCardDetailInformationRowFactory, shouldPerformActionForRowType informationRowType: CardDetailInformationRow.RowType) {
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
        viewModel.goToScreenForAction(action: action, delegate: self)
    }
}

// MARK: - Navigation title scrolling behaviour

extension LoyaltyCardFullDetailsViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard didLayoutSubviews else { return }

        titleView.configureWithTitle(viewModel.brandName, detail: viewModel.pointsValueText)

        let navBarHeight = navigationController?.navigationBar.frame.height ?? 0
        let statusBarHeight = view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        let topBarHeight = navBarHeight + statusBarHeight
        let secondaryColorViewHeight = secondaryColorView.frame.height

        if secondaryColorViewHeight < topBarHeight {
            navigationController?.setNavigationBarVisibility(true)
            navigationBarShouldBeVisible = true
            navigationItem.titleView = titleView

            switch (traitCollection.userInterfaceStyle, Current.themeManager.currentTheme.type) {
            case (.dark, .dark), (.dark, .system), (_, .dark):
                setNavigationBarAppearanceLight(true)
            default:
                setNavigationBarAppearanceLight(false)
            }
        } else if secondaryColorViewHeight > topBarHeight {
            navigationController?.setNavigationBarVisibility(false)
            navigationBarShouldBeVisible = false
            navigationItem.titleView = nil
            
            // When navBar is hidden and in dark mode and secondary background colour is light, set navBar appearance to dark
            if traitCollection.userInterfaceStyle == .dark && !viewModel.secondaryColourIsDark {
                setNavigationBarAppearanceLight(false)
            } else {
                setNavigationBarAppearanceLight(true)
            }
        }
    }
}

// MARK: - Modal Delegate

extension LoyaltyCardFullDetailsViewController: LoyaltyCardFullDetailsModalDelegate {
    func modalWillDismiss() {
        configureModules()
    }
}

extension LayoutHelper {
    enum LoyaltyCardDetail {
        static let animationSpacerHeight: CGFloat = 110
        static let contentPadding: CGFloat = 25
        static let headerToBarcodeButtonPadding: CGFloat = 12
        private static let brandHeaderAspectRatio: CGFloat = 115 / 182
        private static let brandHeaderAspectRatioLink: CGFloat = 25 / 41
        static let modulesStackViewHeight: CGFloat = 128
        static let barcodeButtonHeight: CGFloat = 22
        static let informationTableSeparatorInset = UIEdgeInsets(top: 0, left: 25, bottom: 0, right: 25)
        static func brandHeaderAspectRatio(forMembershipCard card: CD_MembershipCard) -> CGFloat {
            return card.membershipPlan?.featureSet?.planCardType == .link ? brandHeaderAspectRatioLink : brandHeaderAspectRatio
        }
    }
}
