//
//  PaymentWalletViewController.swift
//  binkapp
//
//  Created by Paul Tiriteu on 23/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class PaymentWalletViewController: WalletViewController<PaymentWalletViewModel> {
    override func configureCollectionView() {
        super.configureCollectionView()
        collectionView.register(PaymentCardCollectionViewCell.self, asNib: true)
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row < viewModel.walletPromptsCount {
            let cell: WalletJoinCardCollectionViewCell = collectionView.dequeue(indexPath: indexPath)
            guard let walletPrompt = viewModel.walletPrompts?[indexPath.row] else {
                return cell
            }
            cell.configureWithWalletPrompt(walletPrompt)
            return cell
        } else {
            let cell: PaymentCardCollectionViewCell = collectionView.dequeue(indexPath: indexPath)
            guard let paymentCard = viewModel.card(forIndexPath: indexPath) else {
                return cell
            }

            let cellViewModel = PaymentCardCellViewModel(paymentCard: paymentCard, router: viewModel.router)
            cell.configureWithViewModel(cellViewModel)

            return cell
        }
    }

}
