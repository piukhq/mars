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
        NotificationCenter.default.addObserver(self, selector: #selector(handlePointsScrapingUpdate), name: .webScrapingUtilityDidComplete, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(setupWalletPrompts), name: .didLoadLocalWallet, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(setupWalletPrompts), name: .didLoadWallet, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(deleteCard), name: .didDeleteWalletCard, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarVisibility(true, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setScreenName(trackedScreen: .loyaltyWallet)
    }
    
    @objc private func handlePointsScrapingUpdate() {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    @objc func setupWalletPrompts() {
        viewModel.walletPrompts = WalletPromptFactory.makeWalletPrompts(forWallet: .loyalty)
    }
    
    @objc func deleteCard() {
        self.collectionView.performBatchUpdates({ [weak self] in
            if let indexPath = viewModel.indexPathOfCardToDelete {
                self?.collectionView.deleteItems(at: indexPath)
            }
        }) { [weak self] _ in
            let previousWalletPrompts = self?.viewModel.walletPrompts
            self?.setupWalletPrompts()
            
            let walletPrompts = self?.viewModel.walletPrompts ?? []
            if let newWalletPrompt = previousWalletPrompts?.difference(from: walletPrompts).first {
                var insertIndex = 0
                
                if case .see = newWalletPrompt.type {
                    insertIndex = walletPrompts.contains(where: { $0.index == 0 }) ? 1 : 0
                }
                
                if case .store = newWalletPrompt.type {
                    insertIndex = walletPrompts.count == 1 ? 0 : walletPrompts.count - 1
                }
                
                self?.collectionView.performBatchUpdates {
                    self?.collectionView.insertItems(at: [IndexPath(item: insertIndex, section: 1)])
                } completion: { _ in
                    /// Reload required to update cell size for link prompt
                    self?.collectionView.reloadData()
                }
            }

            self?.viewModel.indexPathOfCardToDelete = nil
        }
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell: WalletLoyaltyCardCollectionViewCell = collectionView.dequeue(indexPath: indexPath)
            guard let membershipCard = viewModel.cards?[indexPath.row] else { return cell }
            let cellViewModel = WalletLoyaltyCardCellViewModel(membershipCard: membershipCard)
            cell.configureUIWithViewModel(viewModel: cellViewModel, delegate: self)
            
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
        Current.wallet.reorderMembershipCard(membershipCard, from: sourceIndexPath.row, to: destinationIndexPath.row)
    }
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
        viewModel.indexPathOfCardToDelete = [index]
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
