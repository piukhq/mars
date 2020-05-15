//
//  PLRStampsCell.swift
//  binkapp
//
//  Created by Nick Farrant on 14/11/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class PLRStampsCell: PLRBaseCollectionViewCell {
    struct Constants {
        static let stampViewWidth: CGFloat = 24
        static let interimSpacing: CGFloat = 12
    }

    @IBOutlet private weak var stampsCollectionView: UICollectionView!
    private var viewModel: PLRCellViewModel!

    override func configureWithViewModel(_ viewModel: PLRCellViewModel) {
        super.configureWithViewModel(viewModel)

        self.viewModel = viewModel
        stampsCollectionView.delegate = self
        stampsCollectionView.dataSource = self
        stampsCollectionView.register(PLRStampViewCell.self, asNib: true)
        stampsCollectionView.isScrollEnabled = false
        if let layout = stampsCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.minimumInteritemSpacing = Constants.interimSpacing
        }
    }
}

extension PLRStampsCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.stampsAvailable
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: PLRStampViewCell = collectionView.dequeue(indexPath: indexPath)
        cell.configure(index: indexPath.row, stampsCollected: viewModel.stampsCollected, state: viewModel.voucherState)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: Constants.stampViewWidth, height: Constants.stampViewWidth)
    }
}
