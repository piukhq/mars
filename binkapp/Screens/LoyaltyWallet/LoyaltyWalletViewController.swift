//
//  LoyaltyWalletViewController.swift
//  binkapp
//
//  Copyright (c) 2019 Bink. All rights reserved.
//

import UIKit
import CoreGraphics
import DeepDiff

class LoyaltyWalletViewController: WalletViewController<LoyaltyWalletViewModel> {
    override func configureCollectionView() {
        super.configureCollectionView()
        collectionView.register(WalletLoyaltyCardCollectionViewCell.self, asNib: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // still need this?
        NotificationCenter.default.addObserver(self, selector: #selector(reloadWallet), name: .didAddMembershipCard, object: nil)
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row < viewModel.joinCardCount {
            // join card
            let cell: WalletJoinCardCollectionViewCell = collectionView.dequeue(indexPath: indexPath)
            guard let joinCard = viewModel.joinCards?[indexPath.row] else {
                return cell
            }
            cell.configureWithJoinCard(joinCard)
            return cell
        } else {
            let cell: WalletLoyaltyCardCollectionViewCell = collectionView.dequeue(indexPath: indexPath)

            guard let membershipCard = viewModel.card(forIndexPath: indexPath) else {
                return cell
            }

            let cellViewModel = WalletLoyaltyCardCellViewModel(membershipCard: membershipCard)
            cell.configureUIWithViewModel(viewModel: cellViewModel, delegate: self)

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
            toBarcode(with: index, cell: cell)
        case .delete:
            promptForDelete(with: index, cell: cell)
        case .login:
            UIAlertController.presentFeatureNotImplementedAlert(on: self)
        }
    }
    
    func toBarcode(with index: IndexPath, cell: WalletLoyaltyCardCollectionViewCell) {
        viewModel.toBarcodeViewController(item: index.item) {
            cell.set(to: .closed, as: .barcode)
        }
    }
    
    func promptForDelete(with index: IndexPath, cell: WalletLoyaltyCardCollectionViewCell) {
        guard let card = viewModel.card(forIndexPath: index) else { return }
                
        viewModel.showDeleteConfirmationAlert(card: card, yesCompletion: { [weak self] in
            self?.viewModel.refreshLocalWallet()
        }, noCompletion: {
            cell.set(to: .closed)
        })
    }
    
    func cellDidFullySwipe(action: SwipeMode?, cell: WalletLoyaltyCardCollectionViewCell) {
        guard let index = collectionView.indexPath(for: cell) else { return }
        
        if action == .barcode {
            toBarcode(with: index, cell: cell)
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
