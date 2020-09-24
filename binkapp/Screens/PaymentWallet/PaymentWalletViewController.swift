//
//  PaymentWalletViewController.swift
//  binkapp
//
//  Created by Paul Tiriteu on 23/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit
import CardScan

class PaymentWalletViewController: WalletViewController<PaymentWalletViewModel> {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setScreenName(trackedScreen: .paymentWallet)
    }
    
    override func configureCollectionView() {
        super.configureCollectionView()
        collectionView.register(PaymentCardCollectionViewCell.self, asNib: true)
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row < viewModel.walletPromptsCount {
            let cell: WalletPromptCollectionViewCell = collectionView.dequeue(indexPath: indexPath)
            guard let walletPrompt = viewModel.walletPrompts?[indexPath.row] else {
                return cell
            }
            cell.configureWithWalletPrompt(walletPrompt)
            return cell
        } else {
            let cell: PaymentCardCollectionViewCell = collectionView.dequeue(indexPath: indexPath)
            guard let paymentCard = viewModel.cards?[indexPath.row] else {
                return cell
            }

            let cellViewModel = PaymentCardCellViewModel(paymentCard: paymentCard)
            cell.configureWithViewModel(cellViewModel, delegate: self)

            return cell
        }
    }

}

extension PaymentWalletViewController: WalletPaymentCardCollectionViewCellDelegate {
    func cellPerform(action: CellAction, cell: PaymentCardCollectionViewCell) {
        guard let index = collectionView.indexPath(for: cell) else { return }

        switch action {
        case .delete:
            promptForDelete(with: index, cell: cell)
        case .barcode:
            break
        default:
            return
        }
    }

    func promptForDelete(with index: IndexPath, cell: PaymentCardCollectionViewCell) {
        guard let card = viewModel.cards?[index.row] else { return }
        viewModel.showDeleteConfirmationAlert(card: card) {
            cell.set(to: .closed)
        }
    }

    func cellDidFullySwipe(action: SwipeMode?, cell: PaymentCardCollectionViewCell) {
        guard let index = collectionView.indexPath(for: cell) else { return }

        if action == .delete {
            promptForDelete(with: index, cell: cell)
        }
    }

    func cellSwipeBegan(cell: PaymentCardCollectionViewCell) {
        let cells = collectionView.visibleCells.filter { $0 != cell }
        guard let walletCells = cells as? [PaymentCardCollectionViewCell] else { return }
        walletCells.forEach { $0.set(to: .closed) }
    }
}
