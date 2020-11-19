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
    override func configureCollectionView() {
        super.configureCollectionView()
        collectionView.register(WalletLoyaltyCardCollectionViewCell.self, asNib: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handlePointsScrapingUpdate), name: .webScrapingUtilityDidComplete, object: nil)
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

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row < viewModel.cardCount {
            let cell: WalletLoyaltyCardCollectionViewCell = collectionView.dequeue(indexPath: indexPath)
            
            guard let membershipCard = viewModel.cards?[indexPath.row] else {
                return cell
            }
            
            let cellViewModel = WalletLoyaltyCardCellViewModel(membershipCard: membershipCard)
            cell.configureUIWithViewModel(viewModel: cellViewModel, delegate: self)
            
            return cell
        } else {
            // join card
            let cell: WalletPromptCollectionViewCell = collectionView.dequeue(indexPath: indexPath)
            guard let walletPrompt = viewModel.promptCard(forIndexPath: indexPath) else {
                return cell
            }
            cell.configureWithWalletPrompt(walletPrompt)
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? WalletLoyaltyCardCollectionViewCell else { return }
        cell.set(to: .closed)
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
        let cells = collectionView.visibleCells.filter { $0 != cell }
        guard let walletCells = cells as? [WalletLoyaltyCardCollectionViewCell] else { return }
        walletCells.forEach { $0.set(to: .closed) }
    }
}
