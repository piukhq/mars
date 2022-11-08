//
//  LoyaltyCardFullDetailsViewController.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

// swiftlint:disable force_unwrapping

import SwiftUI

protocol LoyaltyCardFullDetailsModalDelegate: AnyObject {
    func refreshUI()
    func refreshModules()
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
    
    lazy var brandHeader: UIView = {
        let headerView = UIView()
        headerView.isUserInteractionEnabled = true
        headerView.layer.cornerRadius = Constants.cornerRadius
        headerView.clipsToBounds = false
        headerView.layer.applyDefaultBinkShadow()
        headerView.layer.shouldRasterize = true
        headerView.layer.rasterizationScale = UIScreen.main.scale
        headerView.addSubview(brandHeaderImageView)
        return headerView
    }()
    
    lazy var brandHeaderImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = Constants.cornerRadius
        imageView.clipsToBounds = true
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
        let button = UIButton(type: .custom)
        button.titleLabel?.font = .bodyTextLarge
        button.addTarget(self, action: #selector(showBarcodeButtonPressed), for: .touchUpInside)
        button.accessibilityIdentifier = "Show barcode button"
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
    
    private lazy var locationView: UIView = {
        let view = UIView()
        view.isHidden = true
        view.layer.opacity = 0
        view.transform = CGAffineTransform(scaleX: 0, y: 0)
        view.isUserInteractionEnabled = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Current.themeManager.color(for: .walletCardBackground)
        view.layer.cornerRadius = Constants.cornerRadius
        view.clipsToBounds = false
        view.layer.applyDefaultBinkShadow()
        let gestureRecogniser = UITapGestureRecognizer(target: self, action: #selector(showMapLocations))
        view.addGestureRecognizer(gestureRecogniser)
        view.addSubview(locationImage)
        view.addSubview(showLocationsText)
        view.addSubview(nearestStoresText)
        return view
    }()
    
    private lazy var locationImage: UIImageView = {
        let image = UIImage.gifImageWithName("place-marker")
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = Constants.cornerRadius
        imageView.clipsToBounds = true
        imageView.animationImages = image?.images
        imageView.animationRepeatCount = 1
        imageView.animationDuration = 2.5
        imageView.image = image?.images?.last
        imageView.tintColor = Current.themeManager.color(for: .walletCardBackground)
        return imageView
    }()
    
    private lazy var showLocationsText: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = L10n.showLocations
        label.font = .navBar
        label.textAlignment = .left
        label.textColor = Current.themeManager.color(for: .text)
        return label
    }()
    
    private lazy var nearestStoresText: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = L10n.findNearestStore
        label.textAlignment = .left
        label.font = .bodyTextLarge
        label.textColor = Current.themeManager.color(for: .text)
        return label
    }()
    
    lazy var separator: UIView = {
        let separator = UIView()
        separator.translatesAutoresizingMaskIntoConstraints = false
        return separator
    }()
    
    private lazy var cardInformationView: UIView = {
        let rowData = CardInformationView(viewModel: CardInformationViewModel(informationRows: viewModel.informationRows))
        let view = UIHostingController(rootView: rowData).view!
        view.backgroundColor = .clear
        return view
    }()

    
    var viewModel: LoyaltyCardFullDetailsViewModel
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
        NotificationCenter.default.addObserver(self, selector: #selector(handlePointsScrapingUpdate), name: .webScrapingUtilityDidUpdate, object: nil)
        viewModel.storeOpenedTimeForCard()
        fetchGeoData()
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) { [weak self] in
                guard let self = self else { return }
                self.setPadding(animated: self.viewModel.shouldAnimateContent)
            }
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
        titleView.configureWithTitle(viewModel.brandName, detail: viewModel.pointsValueText)

        let plrVoucherCells = stackScrollView.arrangedSubviews.filter { $0.isKind(of: PLRBaseCollectionViewCell.self) }
        if let voucherCells = plrVoucherCells as? [PLRBaseCollectionViewCell], let vouchers = viewModel.vouchers {
            for index in 0..<voucherCells.count {
                if let voucher = vouchers[safe: index] {
                    let cellViewModel = PLRCellViewModel(voucher: voucher)
                    voucherCells[index].configureWithViewModel(cellViewModel) { [weak self] in
                        self?.viewModel.toVoucherDetailScreen(voucher: vouchers[index])
                    }
                }
            }
        }
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
        
        configureShowBarcodeButton()
        
        stackScrollView.customPadding(LayoutHelper.LoyaltyCardDetail.contentPadding, after: showBarcodeButton)
        stackScrollView.add(arrangedSubview: modulesStackView)
        configureModules()
        stackScrollView.customPadding(LayoutHelper.LoyaltyCardDetail.contentPadding, after: modulesStackView)
        configurePLRCells()
        
        // Build locations
        stackScrollView.add(arrangedSubview: locationView)
        stackScrollView.customPadding(LayoutHelper.LoyaltyCardDetail.contentPadding, after: locationView)
        
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
        stackScrollView.add(arrangedSubview: cardInformationView)
        
        configureLayout()
        
        guard let plan = viewModel.membershipCard.membershipPlan else { return }
        
        // Build Placeholder
        if viewModel.isMembershipCardPLL, let hexStringColor = viewModel.membershipCard.card?.colour {
            brandHeaderImageView.backgroundColor = UIColor(hexString: hexStringColor)
            brandHeaderImageView.layoutIfNeeded()
            let placeholderName = plan.account?.planNameCard ?? plan.account?.planName ?? ""
            let placeholder = LCDPlaceholderGenerator.generate(with: hexStringColor, planName: placeholderName, destSize: brandHeaderImageView.frame.size)
            brandHeaderImageView.backgroundColor = UIColor(patternImage: placeholder)
        }
        
        brandHeader.layoutIfNeeded()
        configureBrandHeader(with: plan)
        configureSecondaryColorViewLayout()
    }
    
    private func configureBrandHeader(with membershipPlan: CD_MembershipPlan) {
        switch (viewModel.isMembershipCardAuthorised, viewModel.shouldShowBarcode, viewModel.isMembershipCardPLL) {
        case (true, false, true):
            brandHeaderImageView.setImage(forPathType: .membershipPlanTier(card: viewModel.membershipCard), animated: true)
        case (false, false, true):
            brandHeaderImageView.setImage(forPathType: .membershipPlanHero(plan: membershipPlan), animated: true)
        default:
            configureBarcodeViewForBrandHeader()
        }
    }
    
    private func configureBarcodeViewForBrandHeader() {
        var barcode: BarcodeView
        
        if !viewModel.shouldShowBarcode {
            let barcodeView: BarcodeViewNoBarcode = .fromNib()
            barcode = barcodeView
            barcodeView.configure(viewModel: viewModel)
        } else {
            switch (viewModel.barcodeViewModel.barcodeType, viewModel.barcodeViewModel.barcodeIsMoreSquareThanRectangle) {
            case (.aztec, _), (.qr, _), (.dataMatrix, _), (_, true):
                let barcodeView: BarcodeViewCompact = .fromNib()
                barcode = barcodeView
                barcodeView.configure(viewModel: viewModel)
            default:
                let barcodeView: BarcodeViewWide = .fromNib()
                barcode = barcodeView
                barcodeView.configure(viewModel: viewModel)
            }
        }
        
        barcode.translatesAutoresizingMaskIntoConstraints = false
        brandHeader.addSubview(barcode)
        barcode.heightAnchor.constraint(equalTo: brandHeader.heightAnchor).isActive = true
        barcode.widthAnchor.constraint(equalTo: brandHeader.widthAnchor).isActive = true
        barcode.layoutIfNeeded()
    }
    
    private func configureShowBarcodeButton(insertAt index: Int? = nil) {
        if viewModel.shouldShowBarcodeButton {
            showBarcodeButton.setTitle(viewModel.barcodeButtonTitle, for: .normal)
            if let index = index {
                stackScrollView.insert(arrangedSubview: showBarcodeButton, atIndex: index)
            } else {
                stackScrollView.add(arrangedSubview: showBarcodeButton)
            }
            let gestureRecogniser = UITapGestureRecognizer(target: self, action: #selector(showBarcodeButtonPressed))
            brandHeader.addGestureRecognizer(gestureRecogniser)
        }
    }
    
    private func setupCellForType<T: PLRBaseCollectionViewCell>(_ cellType: T.Type, voucher: CD_Voucher) {
        let cell = PLRBaseCollectionViewCell.nibForCellType(cellType)
        let cellViewModel = PLRCellViewModel(voucher: voucher)
        cell.configureWithViewModel(cellViewModel) { [weak self] in
            self?.viewModel.toVoucherDetailScreen(voucher: voucher)
        }

        stackScrollView.insert(arrangedSubview: cell, atIndex: viewModel.indexToInsertVoucherCell)
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
            cardInformationView.widthAnchor.constraint(equalTo: stackScrollView.widthAnchor),
            brandHeaderImageView.heightAnchor.constraint(equalTo: brandHeader.heightAnchor),
            brandHeaderImageView.widthAnchor.constraint(equalTo: brandHeader.widthAnchor),
            locationView.leftAnchor.constraint(equalTo: stackScrollView.leftAnchor, constant: LayoutHelper.LoyaltyCardDetail.contentPadding),
            locationView.rightAnchor.constraint(equalTo: stackScrollView.rightAnchor, constant: -LayoutHelper.LoyaltyCardDetail.contentPadding),
            locationView.heightAnchor.constraint(equalToConstant: LayoutHelper.GeoLocationCallout.locationViewHeight),
            showLocationsText.rightAnchor.constraint(equalTo: locationView.rightAnchor, constant: -LayoutHelper.GeoLocationCallout.locationsTextRightOffset),
            showLocationsText.topAnchor.constraint(equalTo: locationView.topAnchor, constant: LayoutHelper.GeoLocationCallout.locationsTextTopOffset),
            showLocationsText.leftAnchor.constraint(equalTo: locationView.leftAnchor, constant: LayoutHelper.GeoLocationCallout.locationsTextLeftOffset),
            nearestStoresText.rightAnchor.constraint(equalTo: locationView.rightAnchor, constant: -LayoutHelper.GeoLocationCallout.nearestStoresTextRightOffset),
            nearestStoresText.bottomAnchor.constraint(equalTo: locationView.bottomAnchor, constant: -LayoutHelper.GeoLocationCallout.nearestStoresTextBottomOffset),
            nearestStoresText.leftAnchor.constraint(equalTo: locationView.leftAnchor, constant: LayoutHelper.GeoLocationCallout.locationsTextLeftOffset),
            locationImage.leftAnchor.constraint(equalTo: locationView.leftAnchor, constant: LayoutHelper.GeoLocationCallout.locationImageHorizontalOffset),
            locationImage.topAnchor.constraint(equalTo: locationView.topAnchor, constant: LayoutHelper.GeoLocationCallout.locationImageVerticalOffset),
            locationImage.bottomAnchor.constraint(equalTo: locationView.bottomAnchor, constant: -LayoutHelper.GeoLocationCallout.locationImageVerticalOffset),
            locationImage.rightAnchor.constraint(equalTo: nearestStoresText.leftAnchor, constant: -LayoutHelper.GeoLocationCallout.locationImageHorizontalOffset)
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
        pointsModule.configure(with: BinkModuleViewModel(type: .points(membershipCard: viewModel.membershipCard)), delegate: self)
        linkModule.configure(with: BinkModuleViewModel(type: .link(membershipCard: viewModel.membershipCard, paymentCards: viewModel.paymentCards)), delegate: self)
    }
    
    func configurePLRCells() {
        stackScrollView.arrangedSubviews.forEach { subview in
            if subview.isKind(of: PLRBaseCollectionViewCell.self) {
                stackScrollView.remove(arrangedSubview: subview)
            }
        }
        
        if viewModel.shouldShowPLR {
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
    }
    
    @objc func showBarcodeButtonPressed() {
        viewModel.toBarcodeModel()
    }
    
    @objc func showMapLocations() {
        viewModel.toGeoLocations()
    }
    
    private func setPadding(animated: Bool = true) {
        self.contentAnimationSpacerHeightConstraint.constant = 0
        UIView.animate(withDuration: animated ? 0.4 : 0) {
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
    func binkModuleViewWasTapped(moduleView: BinkModuleView, withState state: ModuleState) {
        if Current.pointsScrapingManager.canAttemptRetry(for: viewModel.membershipCard) {
            Current.pointsScrapingManager.processRetry(for: viewModel.membershipCard)
        } else {
            viewModel.goToScreenForState(state: state, delegate: self)
        }
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
    func refreshModules() {
        configureModules()
    }
    
    func refreshUI() {
        Current.wallet.reload { [weak self] in
            guard let self = self else { return }
            if let updatedMembershipCard = Current.wallet.membershipCards?.first(where: { $0.id == self.viewModel.membershipCard.id }) {
                self.viewModel.membershipCard = updatedMembershipCard
                self.configureShowBarcodeButton(insertAt: 2)
                self.stackScrollView.customPadding(LayoutHelper.LoyaltyCardDetail.contentPadding, after: self.showBarcodeButton)
                self.configureModules()
                self.configurePLRCells()
            }
        }
    }
}

// MARK: - Fetch geo data - update UI

extension LoyaltyCardFullDetailsViewController {
    func fetchGeoData() {
        viewModel.fetchGeoData(completion: { geoDataIsAvailable, animated in
            guard geoDataIsAvailable else { return }
            
            if animated {
                self.locationView.isHidden = false
                UIView.animate(withDuration: 0.8) {
                    self.locationView.layer.opacity = 1.0
                    self.locationView.transform = CGAffineTransform(scaleX: 1, y: 1)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                    self.locationImage.startAnimating()
                }
            } else {
                self.locationView.isHidden = false
                self.locationView.layer.opacity = 1.0
                self.locationView.transform = CGAffineTransform(scaleX: 1, y: 1)
                self.locationImage.startAnimating()
            }
        })
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
