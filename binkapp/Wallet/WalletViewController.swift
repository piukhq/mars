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

enum WalletDataSourceSection: Int, CaseIterable {
    case cards
    case prompts
}

/// Disabling pending a review of diffable data source and core data behaviour
// typealias WalletDataSourceItem = AnyHashable
// typealias WalletDataSource = UICollectionViewDiffableDataSource<WalletDataSourceSection, WalletDataSourceItem>
// typealias WalletDataSourceSnapshot = NSDiffableDataSourceSnapshot<WalletDataSourceSection, WalletDataSourceItem>

class WalletViewController<T: WalletViewModel>: BinkViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, InAppReviewable, UIPopoverPresentationControllerDelegate, OptionItemListViewControllerDelegate {
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = .clear
        collectionView.contentInset = LayoutHelper.WalletDimensions.contentInset
        return collectionView
    }()
    
    private lazy var layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = LayoutHelper.WalletDimensions.cardLineSpacing
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        return layout
    }()
    
    let refreshControl = UIRefreshControl()
    private var hasSupportUpdates = false
    private let dotView = UIView()
    
    var orderingManager = WalletOrderingManager()
    private var distanceFromCenterOfCell: CGFloat?
    
    // We only want to use transition when tapping a wallet card cell and not when adding a new card
    var shouldUseTransition = false
    var indexPathOfCardToDelete: IndexPath?
    
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
        
        configureCollectionView()
        configureNavigationItem()
        
        /// Disabling pending a review of diffable data source and core data behaviour
//        if #available(iOS 14.0, *) {
//            applySnapshot()
//            configureDiffableDataSourceHandlers()
//        }
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
        
        configureLoadingIndicator()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Current.wallet.reloadWalletsIfNecessary { willPerformRefresh in
            if willPerformRefresh, InAppReviewUtility.canRequestReviewBasedOnUsage {
                TimeAndUsageBasedInAppReviewableJourney().begin()
                requestInAppReview()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.refreshControl.endRefreshing()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // We don't want to see it on non-wallet view controllers
        dotView.removeFromSuperview()
    }
    
    private func configureNavigationItem() {
        let settingsIcon = Asset.settings.image.withRenderingMode(.alwaysOriginal)
        let settingsBarButton = UIBarButtonItem(image: settingsIcon, style: .plain, target: self, action: #selector(settingsButtonTapped))

        settingsBarButton.accessibilityIdentifier = "settings"
        navigationItem.rightBarButtonItems = [settingsBarButton, setupSortBarButton()]
        
        var rightInset: CGFloat = 0
        switch UIDevice.current.width {
        case .iPhone5Size:
            rightInset = 9
        case .iPhoneSESize:
            rightInset = 9
        case .iPhonePlusSize:
            rightInset = 6
        default:
            rightInset = 7
        }
        settingsBarButton.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: rightInset)
    }
    
    func setupSortBarButton() -> UIBarButtonItem {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "arrow.up.arrow.down"), for: .normal)
        button.addTarget(self, action: #selector(sortButtonTapped), for: .touchUpInside)
        button.frame = CGRect(x: 0, y: 0, width: 32, height: 22)
        let label = UILabel(frame: CGRect(x: 0, y: 12, width: 32, height: 20))
        label.font = .tabBarSmall
        label.text = "Newest"
        label.textAlignment = .center
        label.textColor = Current.themeManager.color(for: .text)
        label.backgroundColor = .clear
        button.addSubview(label)
        let sortbarButton = UIBarButtonItem(customView: button)
        sortbarButton.accessibilityIdentifier = "sort"
        return sortbarButton
    }
    
    @objc func settingsButtonTapped() {
        var actionRequiredSettings: [SettingsRow.RowType] = []
        if hasSupportUpdates {
            actionRequiredSettings.append(.contactUs)
        }
        viewModel.toSettings(rowsWithActionRequired: actionRequiredSettings)
    }
    
    @objc func sortButtonTapped(_ sender: UIButton) {
        let newestOptionItem = SortOrderOptionItem(text: "Newest", font: UIFont.systemFont(ofSize: 15), isSelected: true, orderType: .newest)
        let customOptionItem = SortOrderOptionItem(text: "Custom", font: UIFont.systemFont(ofSize: 15), isSelected: false, orderType: .custom)
        presentOptionsPopover(withOptionItems: [[newestOptionItem, customOptionItem]], fromBarButtonItem: sender)
    }
    
    func presentOptionsPopover(withOptionItems items: [[OptionItem]], fromBarButtonItem barButtonItem: UIButton) {
        let optionItemListVC = OptionItemListViewController()
        optionItemListVC.items = items
        optionItemListVC.delegate = self
        
        guard let popoverPresentationController = optionItemListVC.popoverPresentationController else { fatalError("Set Modal presentation style") }
        popoverPresentationController.sourceView = barButtonItem
        popoverPresentationController.sourceRect = barButtonItem.bounds
        popoverPresentationController.delegate = self
        self.present(optionItemListVC, animated: true, completion: nil)
    }
    
    func configureCollectionView() {
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
        
        /// Disabling pending a review of diffable data source and core data behaviour
//        if #available(iOS 14.0, *) {
//            collectionView.dataSource = diffableDataSource
//        } else {
//            collectionView.dataSource = self
//        }
    }
    
    func reloadCollectionView(animated: Bool = true) {
        viewModel.setupWalletPrompts()
        collectionView.reloadData()
        
        /// Disabling pending a review of diffable data source and core data behaviour
//        if #available(iOS 14.0, *) {
//            applySnapshot(animatingDifferences: animated)
//        } else {
//            collectionView.reloadData()
//        }
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
        reloadCollectionView()
    }
    
    @objc private func refreshPostClear() {
        viewModel.refreshLocalWallet()
    }
    
    @objc private func refreshLocal() {
        if let indexPath = indexPathOfCardToDelete {
            deleteCard(at: indexPath)
        } else {
            reloadCollectionView()
        }
        
        /// Disabling pending a review of diffable data source and core data behaviour
//        if #available(iOS 14.0, *) {
//            reloadCollectionView()
//        } else {
//            if let indexPath = indexPathOfCardToDelete {
//                deleteCard(at: indexPath)
//            } else {
//                reloadCollectionView()
//            }
//        }
    }
    
    @objc private func stopRefreshing() {
        if let navigationBar = self.navigationController?.navigationBar {
            refreshControl.programaticallyEndRefreshing(in: self.collectionView, with: navigationBar)
            reloadCollectionView()
        }
    }
    
    private func deleteCard(at indexPath: IndexPath) {
        if self.collectionView.numberOfItems(inSection: indexPath.section) > 0 {
            self.collectionView.performBatchUpdates({ [weak self] in
                self?.collectionView.deleteItems(at: [indexPath])
            }) { [weak self] _ in
                self?.reloadCollectionView()
                self?.indexPathOfCardToDelete = nil
            }
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 0 ? viewModel.cardCount : viewModel.walletPromptsCount
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return section == 0 ? .zero : UIEdgeInsets(top: 15.0, left: 0.0, bottom: 0.0, right: 0.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        fatalError("Subclasses should override this method")
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        fatalError("Subclasses should override this method")
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        fatalError("Subclasses should override this method.")
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        fatalError("Subclass should override this.")
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        guard let cell = collectionView.cellForItem(at: indexPath) else { return false }
        return !cell.isKind(of: WalletPromptCollectionViewCell.self) && !cell.isKind(of: OnboardingCardCollectionViewCell.self)
    }
    
    func collectionView(_ collectionView: UICollectionView, targetIndexPathForMoveFromItemAt originalIndexPath: IndexPath, toProposedIndexPath proposedIndexPath: IndexPath) -> IndexPath {
        guard let cell = collectionView.cellForItem(at: proposedIndexPath) else { return proposedIndexPath }
        
        if cell.isKind(of: WalletPromptCollectionViewCell.self) || cell.isKind(of: OnboardingCardCollectionViewCell.self) {
            return originalIndexPath
        }
        
        return proposedIndexPath
    }
    
    @objc func handleLongGesture(gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            guard let selectedIndexPath = collectionView.indexPathForItem(at: gesture.location(in: collectionView)) else { break }
            let selectedCell = collectionView.cellForItem(at: selectedIndexPath)
            let centerY = (selectedCell?.bounds.size.height ?? 0) / 2
            let gestureLocationInCell = gesture.location(in: selectedCell)
            distanceFromCenterOfCell = centerY - gestureLocationInCell.y
            
            orderingManager.start()
            collectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
        case .changed:
            if let bounds = gesture.view?.bounds {
                let gestureLocation = gesture.location(in: gesture.view)
                let centerX: CGFloat = bounds.size.width / 2
                let updatedLocation = CGPoint(x: centerX, y: gestureLocation.y + (distanceFromCenterOfCell ?? 0))
                collectionView.updateInteractiveMovementTargetPosition(updatedLocation)
            }
        case .ended:
            orderingManager.stop()
            collectionView.endInteractiveMovement()
            distanceFromCenterOfCell = nil
        default:
            orderingManager.stop()
            collectionView.cancelInteractiveMovement()
        }
    }
    
    override func configureForCurrentTheme() {
        super.configureForCurrentTheme()
        refreshControl.tintColor = Current.themeManager.color(for: .text)
        reloadCollectionView()
        collectionView.indicatorStyle = Current.themeManager.scrollViewIndicatorStyle(for: traitCollection)
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    func optionItemListViewController(_ controller: OptionItemListViewController, didSelectOptionItem item: OptionItem) {
        controller.dismiss(animated: true)
        if item.isSelected {
            print(item.text)
        }
    }
    
    // MARK: - Diffable data source
    
    /// Disabling pending a review of diffable data source and core data behaviour
//    private lazy var diffableDataSource = makeDataSource()
//
//    private func makeDataSource() -> WalletDataSource {
//        let dataSource = WalletDataSource(collectionView: collectionView) { [weak self] _, indexPath, dataSourceItem in
//            guard let self = self else { fatalError("Failed to get self") }
//            guard let section = WalletDataSourceSection(rawValue: indexPath.section) else { fatalError("Failed to get section") }
//            return self.cellHandler(for: section, dataSourceItem: dataSourceItem, indexPath: indexPath)
//        }
//        return dataSource
//    }
//
//    func cellHandler(for section: WalletDataSourceSection, dataSourceItem: AnyHashable, indexPath: IndexPath) -> UICollectionViewCell {
//        fatalError("Each wallet subclass should override this to provide specific behaviours.")
//    }
//
//    func setSnapshot(_ snapshot: inout WalletDataSourceSnapshot) {
//        fatalError("Each wallet subclass should override this to append specific wallet items")
//    }
//
//    func applySnapshot(animatingDifferences: Bool = false) {
//        var snapshot = WalletDataSourceSnapshot()
//        snapshot.appendSections(WalletDataSourceSection.allCases)
//        setSnapshot(&snapshot)
//        DispatchQueue.main.async { [weak self] in
//            self?.diffableDataSource.apply(snapshot, animatingDifferences: animatingDifferences)
//        }
//    }
//
//    @available(iOS 14.0, *)
//    private func configureDiffableDataSourceHandlers() {
//        diffableDataSource.reorderingHandlers.canReorderItem = { [weak self] item in
//            return self?.diffableDataSource.indexPath(for: item)?.section == WalletDataSourceSection.cards.rawValue
//        }
//
//        diffableDataSource.reorderingHandlers.didReorder = { [weak self] transaction in
//            /// Looks a little hacky, but this is the only way to pull out a single element from a reorder transaction
//            /// We need a single element because we want to be able to use our existing reorder mechanism
//            /// Because we are only reordering a single card at a time, we know the first insertion here is the correct one
//            /// We can then use the insertion's associated enum values to access the element that has been moved, and cast it correctly
//            /// We then get the start and end index of this element from the transaction, and use our existing reorder mechanism
//            let insertion = transaction.difference.insertions.first
//            switch insertion {
//            case .insert(_, let element, _):
//                guard let startIndex = transaction.initialSnapshot.indexOfItem(element) else { return }
//                guard let endIndex = transaction.finalSnapshot.indexOfItem(element) else { return }
//
//                if let membershipCard = element as? CD_MembershipCard {
//                    Current.wallet.reorderMembershipCard(membershipCard, from: startIndex, to: endIndex)
//                } else if let paymentCard = element as? CD_PaymentCard {
//                    Current.wallet.reorderPaymentCard(paymentCard, from: startIndex, to: endIndex)
//                }
//
//                self?.applySnapshot()
//            default: return
//            }
//        }
//    }
}

struct WalletOrderingManager {
    var isReordering = false
    
    mutating func start() {
        isReordering = true
    }
    
    mutating func stop() {
        isReordering = false
    }
}
