//
//  WalletViewController.swift
//  binkapp
//
//  Created by Nick Farrant on 15/10/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

enum WalletViewControllerConstants {
    static let dotViewHeightWidth: CGFloat = 10
    static let dotViewRightPadding: CGFloat = 18
    static let dotViewTopPadding: CGFloat = 3
}

class WalletViewController<T: WalletViewModel>: BinkViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, BarBlurring, InAppReviewable {
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = .white
        collectionView.contentInset = LayoutHelper.WalletDimensions.contentInset

        return collectionView
    }()

    private lazy var layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = LayoutHelper.WalletDimensions.cardLineSpacing
        layout.estimatedItemSize = LayoutHelper.WalletDimensions.cardSize
        return layout
    }()

    internal lazy var blurBackground = defaultBlurredBackground()

    let refreshControl = UIRefreshControl()
    private var hasSupportUpdates = false
    private let dotView = UIView()

    var orderingManager = WalletOrderingManager()
    var cellToBeMoved: UICollectionViewCell?

    let viewModel: T

    init(viewModel: T) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongGesture(gesture:)))
        collectionView.addGestureRecognizer(longPressGesture)
        
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: .didLoadWallet, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshLocal), name: .didLoadLocalWallet, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshPostClear), name: .shouldTrashLocalWallets, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(stopRefreshing), name: .noInternetConnection, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(stopRefreshing), name: .outageError, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(stopRefreshing), name: .outageSilentFail, object: nil)

        refreshControl.addTarget(self, action: #selector(reloadWallet), for: .valueChanged)
        
        navigationItem.titleView = UIImageView(image: UIImage(named: "bink_top_logo"))

        configureCollectionView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        // We are doing this because the loading indicator is getting stuck when quickly switching between tabs
        // May need to change the approach
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.refreshControl.beginRefreshing()
            self.refreshControl.endRefreshing()
        }
        
        Current.wallet.reloadWalletsIfNecessary { willPerformRefresh in
            if willPerformRefresh, InAppReviewUtility.canRequestReviewBasedOnUsage {
                TimeAndUsageBasedInAppReviewableJourney().begin()
                requestInAppReview()
            }
        }
        configureLoadingIndicator()
        
        /// In case the Zendesk SDK is slow to return a state, we should configure the navigation item to a default state
        configureNavigationItem(hasSupportUpdates: false)
        checkForZendeskUpdates()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.refreshControl.endRefreshing()
        }
        // We don't want to see it on non-wallet view controllers
        dotView.removeFromSuperview()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        guard let bar = navigationController?.navigationBar else { return }
        prepareBarWithBlur(bar: bar, blurBackground: blurBackground)
    }
    
    private func configureNavigationItem(hasSupportUpdates: Bool) {
        self.hasSupportUpdates = hasSupportUpdates
        let settingsIcon = UIImage(named: "settings")?.withRenderingMode(.alwaysOriginal)
        let settingsBarButton = UIBarButtonItem(image: settingsIcon, style: .plain, target: self, action: #selector(settingsButtonTapped))
        navigationItem.rightBarButtonItem = settingsBarButton
        
        var rightInset: CGFloat = 0
        switch UIDevice.current.width {
        case .iPhone5Size:
            rightInset = 9
        case .iPhone6Size:
            rightInset = 9
        case .iPhonePlusSize:
            rightInset = 6
        default:
            rightInset = 7
        }
        settingsBarButton.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: rightInset)
        
        guard hasSupportUpdates else {
            dotView.removeFromSuperview()
            return
        }
        if let navBar = navigationController?.navigationBar {
            dotView.translatesAutoresizingMaskIntoConstraints = false
            dotView.backgroundColor = .systemRed
            dotView.layer.cornerRadius = 5
            navBar.addSubview(dotView)
            NSLayoutConstraint.activate([
                dotView.widthAnchor.constraint(equalToConstant: WalletViewControllerConstants.dotViewHeightWidth),
                dotView.heightAnchor.constraint(equalToConstant: WalletViewControllerConstants.dotViewHeightWidth),
                dotView.rightAnchor.constraint(equalTo: navBar.rightAnchor, constant: -WalletViewControllerConstants.dotViewRightPadding),
                dotView.topAnchor.constraint(equalTo: navBar.topAnchor, constant: WalletViewControllerConstants.dotViewTopPadding)
            ])
        }
    }
    
    @objc func settingsButtonTapped() {
        var actionRequiredSettings: [SettingsRow.RowType] = []
        if hasSupportUpdates {
            actionRequiredSettings.append(.contactUs)
        }
        viewModel.toSettings(rowsWithActionRequired: actionRequiredSettings)
    }
    
    private func checkForZendeskUpdates() {
        ZendeskService.getIdentityRequestUpdates { hasUpdates in
            self.configureNavigationItem(hasSupportUpdates: hasUpdates)
        }
    }

    func configureCollectionView() {
        collectionView.register(WalletPromptCollectionViewCell.self, asNib: true)
        view.addSubview(collectionView)
        collectionView.addSubview(refreshControl)

        collectionView.dataSource = self
        collectionView.delegate = self

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leftAnchor.constraint(equalTo: view.leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
    }

    func configureLoadingIndicator() {
        if Current.wallet.shouldDisplayLoadingIndicator {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.refreshControl.programaticallyBeginRefreshing(in: self.collectionView)
            }
        }
    }

    @objc func reloadWallet() {
        viewModel.reloadWallet()
    }

    @objc private func refresh() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.refreshControl.endRefreshing()
        }
        collectionView.reloadData()
    }
    
    @objc private func refreshPostClear() {
        viewModel.refreshLocalWallet()
    }

    @objc private func refreshLocal() {
        collectionView.reloadData()
    }
    
    @objc private func stopRefreshing() {
        if let navigationBar = self.navigationController?.navigationBar {
            refreshControl.programaticallyEndRefreshing(in: self.collectionView, with: navigationBar)
            collectionView.reloadData()
        }
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.cardCount + viewModel.walletPromptsCount
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let cell = collectionView.cellForItem(at: indexPath) else {
            if indexPath.row < viewModel.cardCount {
                return LayoutHelper.WalletDimensions.cardSize
            } else {
                return LayoutHelper.WalletDimensions.walletPromptSize
            }
        }

        return cell.frame.size
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        fatalError("Subclasses should override this method")
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row < viewModel.cardCount {
            guard let card = viewModel.cards?[indexPath.row] else {
                return
            }
            viewModel.toCardDetail(for: card)
        } else {
            guard let joinCard = viewModel.promptCard(forIndexPath: indexPath) else {
                return
            }
            viewModel.didSelectWalletPrompt(joinCard)
        }
    }

    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        fatalError("Subclass should override this.")
    }

    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        guard let cell = collectionView.cellForItem(at: indexPath) else { return false }
        return !cell.isKind(of: WalletPromptCollectionViewCell.self)
    }

    func collectionView(_ collectionView: UICollectionView, targetIndexPathForMoveFromItemAt originalIndexPath: IndexPath, toProposedIndexPath proposedIndexPath: IndexPath) -> IndexPath {
        guard let cell = collectionView.cellForItem(at: proposedIndexPath) else { return proposedIndexPath }

        if cell.isKind(of: WalletPromptCollectionViewCell.self) {
            return originalIndexPath
        }

        return proposedIndexPath
    }

    @objc func handleLongGesture(gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            guard let selectedIndexPath = collectionView.indexPathForItem(at: gesture.location(in: collectionView)) else {
                break
            }
            orderingManager.start()
            collectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
            cellToBeMoved = collectionView.cellForItem(at: selectedIndexPath)
        case .changed:
            collectionView.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view))
        case .ended:
            orderingManager.stop()
            collectionView.performBatchUpdates {
                collectionView.endInteractiveMovement()
            } completion: { _ in
                self.cellToBeMoved = nil
            }
        default:
            orderingManager.stop()
            collectionView.cancelInteractiveMovement()
        }
    }
}

struct WalletOrderingManager {
    var isReordering = false

    mutating func start() {
        isReordering = true
        // TODO: Disable wallet refresh timer
    }

    mutating func stop() {
        isReordering = false
        // TODO: Enable wallet refresh timer
    }
}
