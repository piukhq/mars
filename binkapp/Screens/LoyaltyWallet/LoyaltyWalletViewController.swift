//
//  LoyaltyWalletViewController.swift
//  binkapp
//
//  Copyright (c) 2019 Bink. All rights reserved.
//

import UIKit
import CoreGraphics
import DeepDiff
import CardScan
import WatchConnectivity

class LoyaltyWalletViewController: WalletViewController<LoyaltyWalletViewModel> {
    var selectedIndexPath: IndexPath?
    
    override func configureCollectionView() {
        super.configureCollectionView()
        collectionView.register(WalletLoyaltyCardCollectionViewCell.self, asNib: true)
        collectionView.register(OnboardingCardCollectionViewCell.self, asNib: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(handlePointsScrapingUpdate), name: .webScrapingUtilityDidUpdate, object: nil)
        
        setupSortBarButton()
    }
    
    func presentOptionsPopover(withOptionItems items: [[OptionItem]], fromBarButtonItem barButtonItem: UIButton) {
        let optionItemListVC = OptionItemListViewController()
        optionItemListVC.title = "Sort Order"
        optionItemListVC.items = items
        optionItemListVC.delegate = self
        
        guard let popoverPresentationController = optionItemListVC.popoverPresentationController else { fatalError("Set Modal presentation style") }
        popoverPresentationController.sourceView = barButtonItem
        let sourceRect = CGRect(x: barButtonItem.bounds.origin.x, y: barButtonItem.bounds.origin.y, width: barButtonItem.bounds.width, height: barButtonItem.bounds.height + 6)
        popoverPresentationController.sourceRect = sourceRect
        popoverPresentationController.delegate = self
        
        self.present(optionItemListVC, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarVisibility(true, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setScreenName(trackedScreen: .loyaltyWallet)
    }
    
    func setupSortBarButton() {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "arrow.up.arrow.down"), for: .normal)
        button.addTarget(self, action: #selector(sortButtonTapped), for: .touchUpInside)
        button.frame = CGRect(x: 0, y: 0, width: 32, height: 22)
        button.tintColor = UIColor.sortBarButton
        
        let label = UILabel(frame: CGRect(x: 0, y: 12, width: 32, height: 20))
        label.font = .tabBarSmall
        label.text = viewModel.getCurrentMembershipCardsSortType()
        label.textAlignment = .center
        label.textColor = UIColor.sortBarButton
        label.backgroundColor = .clear
        button.addSubview(label)
        
        let sortbarButton = UIBarButtonItem(customView: button)
        sortbarButton.accessibilityIdentifier = "sort"
        
        if navigationItem.rightBarButtonItems?.count == 1 {
            navigationItem.rightBarButtonItems?.append(sortbarButton)
        } else {
            navigationItem.rightBarButtonItems?.remove(at: 1)
            navigationItem.rightBarButtonItems?.append(sortbarButton)
        }
    }
    
    @objc private func sortButtonTapped(_ sender: UIButton) {
        let sortType = viewModel.getCurrentMembershipCardsSortType()
        let newestString = MembershipCardsSortState.newest.keyValue
        let customString = MembershipCardsSortState.custom.keyValue
        
        let newestOptionItem = SortOrderOptionItem(text: newestString, font: .walletPromptTitleSmall, isSelected: sortType == newestString, orderType: MembershipCardsSortState.newest)
        let customOptionItem = SortOrderOptionItem(text: customString, font: .walletPromptTitleSmall, isSelected: sortType == customString, orderType: MembershipCardsSortState.custom)
        presentOptionsPopover(withOptionItems: [[newestOptionItem, customOptionItem]], fromBarButtonItem: sender)
    }
    
    @objc private func handlePointsScrapingUpdate() {
        DispatchQueue.main.async {
            self.reloadCollectionView()
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell: WalletLoyaltyCardCollectionViewCell = collectionView.dequeue(indexPath: indexPath)
            guard let membershipCard = viewModel.cards?[safe: indexPath.row] else { return cell }
            let cellViewModel = WalletLoyaltyCardCellViewModel(membershipCard: membershipCard)
            cell.configureUIWithViewModel(viewModel: cellViewModel, indexPath: indexPath, delegate: self)
            
            return cell
        } else {
            // Wallet prompts
            let cell: OnboardingCardCollectionViewCell = collectionView.dequeue(indexPath: indexPath)
            guard let walletPrompt = viewModel.promptCard(forIndexPath: indexPath) else { return cell }
            cell.configureWithWalletPrompt(walletPrompt)
            return cell
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let cell = collectionView.cellForItem(at: indexPath) else {
            if indexPath.section == 0 {
                /// Wallet cards
                return LayoutHelper.WalletDimensions.cardSize
            } else {
                /// Pass wallet prompt to layout helper to calculate size of prompt card based on the amount of merchant cells its collection view will contain
                guard let walletPrompt = viewModel.promptCard(forIndexPath: indexPath) else { return .zero }
                return LayoutHelper.WalletDimensions.sizeForWalletPrompt(walletPrompt: walletPrompt)
            }
        }
        return cell.frame.size
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row < viewModel.cardCount {
            guard let card = viewModel.cards?[indexPath.row] else {
                return
            }
            shouldUseTransition = true
            viewModel.toCardDetail(for: card)
        }
        
        selectedIndexPath = indexPath
        resetAllSwipeStates()
    }
    
    override func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        guard let membershipCard = viewModel.cards?[sourceIndexPath.row] else { return }
        viewModel.setMembershipCardMoved(hasMoved: true)
        viewModel.setMembershipCardsSortingType(sortType: MembershipCardsSortState.custom.keyValue)
        self.setupSortBarButton()
        Current.wallet.reorderMembershipCard(membershipCard, from: sourceIndexPath.row, to: destinationIndexPath.row)
    }
    
    // MARK: - Diffable datasource
    
    /// Disabling pending a review of diffable data source and core data behaviour
    //    override func setSnapshot(_ snapshot: inout WalletDataSourceSnapshot) {
    //        snapshot.appendItems(viewModel.cards ?? [], toSection: .cards)
    //        snapshot.appendItems(viewModel.walletPrompts ?? [], toSection: .prompts)
    //    }
    //
    //    override func cellHandler(for section: WalletDataSourceSection, dataSourceItem: AnyHashable, indexPath: IndexPath) -> UICollectionViewCell {
    //        switch section {
    //        case .cards:
    //            let cell: WalletLoyaltyCardCollectionViewCell = collectionView.dequeue(indexPath: indexPath)
    //            guard let membershipCard = dataSourceItem as? CD_MembershipCard else { return cell }
    //            let cellViewModel = WalletLoyaltyCardCellViewModel(membershipCard: membershipCard)
    //            cell.configureUIWithViewModel(viewModel: cellViewModel, indexPath: indexPath, delegate: self)
    //            return cell
    //        case .prompts:
    //            let cell: OnboardingCardCollectionViewCell = collectionView.dequeue(indexPath: indexPath)
    //            guard let walletPrompt = dataSourceItem as? WalletPrompt else { return cell }
    //            cell.configureWithWalletPrompt(walletPrompt)
    //            return cell
    //        }
    //    }
}

extension LoyaltyWalletViewController: WalletLoyaltyCardCollectionViewCellDelegate {
    func cellPerform(action: CellAction, cell: WalletLoyaltyCardCollectionViewCell) {
        guard let index = collectionView.indexPath(for: cell) else { return }
        
        switch action {
        case .barcode:
            handleBarcodeSwipe(with: index, cell: cell)
        case .delete:
            promptForDelete(with: index, cell: cell)
        case .login:
            UIAlertController.presentFeatureNotImplementedAlert(on: self)
        }
    }
    
    func handleBarcodeSwipe(with indexPath: IndexPath, cell: WalletLoyaltyCardCollectionViewCell) {
        guard let card = viewModel.cards?[indexPath.row] else {
            cell.set(to: .closed)
            return
        }
        
        if card.card?.barcode == nil && card.card?.membershipId == nil {
            viewModel.showNoBarcodeAlert {
                cell.set(to: .closed)
            }
        } else {
            toBarcode(with: indexPath, cell: cell)
        }
    }
    
    func toBarcode(with index: IndexPath, cell: WalletLoyaltyCardCollectionViewCell) {
        viewModel.toBarcodeViewController(indexPath: index) {
            cell.set(to: .closed, as: .barcode)
        }
    }
    
    func promptForDelete(with index: IndexPath, cell: WalletLoyaltyCardCollectionViewCell) {
        guard let card = viewModel.cards?[index.row] else { return }
        indexPathOfCardToDelete = index
        viewModel.showDeleteConfirmationAlert(card: card) {
            cell.set(to: .closed)
        }
    }
    
    func cellDidFullySwipe(action: SwipeMode?, cell: WalletLoyaltyCardCollectionViewCell) {
        guard let index = collectionView.indexPath(for: cell) else { return }
        
        if action == .barcode {
            handleBarcodeSwipe(with: index, cell: cell)
        } else {
            promptForDelete(with: index, cell: cell)
        }
    }
    
    func cellSwipeBegan(cell: WalletLoyaltyCardCollectionViewCell) {
        // We have to filter the cells based on their type, because otherwise the wallet prompt cells are included, and then we can't cast properly
        let cells = collectionView.visibleCells.filter { $0 != cell }.filter { $0.isKind(of: WalletLoyaltyCardCollectionViewCell.self) } as? [WalletLoyaltyCardCollectionViewCell]
        cells?.forEach { $0.set(to: .closed) }
    }
    
    func resetAllSwipeStates() {
        // We have to filter the cells based on their type, because otherwise the wallet prompt cells are included, and then we can't cast properly
        let cells = collectionView.visibleCells.filter { $0.isKind(of: WalletLoyaltyCardCollectionViewCell.self) } as? [WalletLoyaltyCardCollectionViewCell]
        cells?.forEach { $0.set(to: .closed) }
    }
}

extension LoyaltyWalletViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        navigationController.interactivePopGestureRecognizer?.delegate = nil
        
        // Check whether we have tapped a cell or added a new card
        guard shouldUseTransition else { return nil }
        if let _ = fromVC as? LoyaltyWalletViewController {
            shouldUseTransition = false
            return operation == .push ? LoyaltyWalletAnimator() : nil
        }
        return nil
    }
}

extension LoyaltyWalletViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}

extension LoyaltyWalletViewController: OptionItemListViewControllerDelegate {
    func optionItemListViewController(_ controller: OptionItemListViewController, didSelectOptionItem item: OptionItem) {
        controller.dismiss(animated: true)
        let previousSortType = viewModel.getCurrentMembershipCardsSortType()
        
        if item.isSelected {
            if item.text == previousSortType {
                return
            }
            
            if viewModel.hasMembershipCardMoved() && previousSortType == MembershipCardsSortState.custom.keyValue && item.text == MembershipCardsSortState.newest.keyValue {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: {
                    self.viewModel.showSortOrderChangeAlert() {
                        self.viewModel.setMembershipCardsSortingType(sortType: item.text)
                        self.setupSortBarButton()
                        self.viewModel.clearLocalWalletSortedCardsKey()
                        Current.wallet.launch()
                    }
                })
            } else {
                print(item.text)
                viewModel.setMembershipCardsSortingType(sortType: item.text)
                setupSortBarButton()
            }
        }
        
        viewModel.setMembershipCardMoved(hasMoved: false)
    }
}
