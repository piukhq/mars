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
        collectionView.register(WalletPromptCollectionViewCell.self, asNib: true)
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 1 {
            let cell: WalletPromptCollectionViewCell = collectionView.dequeue(indexPath: indexPath)
            guard let walletPrompt = viewModel.walletPrompts?.first else {
                return cell
            }
            cell.configureWithWalletPrompt(walletPrompt)
            return cell
        } else {
            let cell: PaymentCardCollectionViewCell = collectionView.dequeue(indexPath: indexPath)
            guard let paymentCard = viewModel.cards?[safe: indexPath.row] else {
                return cell
            }

            let cellViewModel = PaymentCardCellViewModel(paymentCard: paymentCard)
            cell.configureWithViewModel(cellViewModel, delegate: self)

            return cell
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return LayoutHelper.WalletDimensions.cardSize
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            guard let card = viewModel.cards?[indexPath.row] else {
                return
            }
            shouldUseTransition = true
            viewModel.toCardDetail(for: card)
        } else {
            guard let joinCard = viewModel.promptCard(forIndexPath: indexPath) else {
                return
            }
            shouldUseTransition = false
            viewModel.didSelectWalletPrompt(joinCard)
        }
        
        resetAllSwipeStates()
    }

    override func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        guard let paymentCard = viewModel.cards?[sourceIndexPath.row] else { return }
        Current.wallet.reorderPaymentCard(paymentCard, from: sourceIndexPath.row, to: destinationIndexPath.row)
    }
    
    // MARK: - Diffable datasource
    
    override func setSnapshot(_ snapshot: inout WalletDataSourceSnapshot) {
        snapshot.appendItems(viewModel.cards ?? [], toSection: .cards)
        snapshot.appendItems(viewModel.walletPrompts ?? [], toSection: .prompts)
    }
    
    override func cellHandler(for section: WalletDataSourceSection, dataSourceItem: AnyHashable, indexPath: IndexPath) -> UICollectionViewCell {
        switch section {
        case .cards:
            let cell: PaymentCardCollectionViewCell = collectionView.dequeue(indexPath: indexPath)
            guard let paymentCard = dataSourceItem as? CD_PaymentCard else { return cell }
            let cellViewModel = PaymentCardCellViewModel(paymentCard: paymentCard)
            cell.configureWithViewModel(cellViewModel, delegate: self)
            return cell
        case .prompts:
            let cell: WalletPromptCollectionViewCell = collectionView.dequeue(indexPath: indexPath)
            guard let walletPrompt = dataSourceItem as? WalletPrompt else { return cell }
            cell.configureWithWalletPrompt(walletPrompt)
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
        indexPathOfCardToDelete = index
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
        // We have to filter the cells based on their type, because otherwise the wallet prompt cells are included, and then we can't cast properly
        let cells = collectionView.visibleCells.filter { $0 != cell }.filter { $0.isKind(of: PaymentCardCollectionViewCell.self) } as? [PaymentCardCollectionViewCell]
        cells?.forEach { $0.set(to: .closed) }
    }

    func resetAllSwipeStates() {
        // We have to filter the cells based on their type, because otherwise the wallet prompt cells are included, and then we can't cast properly
        let cells = collectionView.visibleCells.filter { $0.isKind(of: PaymentCardCollectionViewCell.self) } as? [PaymentCardCollectionViewCell]
        cells?.forEach { $0.set(to: .closed) }
    }
}
