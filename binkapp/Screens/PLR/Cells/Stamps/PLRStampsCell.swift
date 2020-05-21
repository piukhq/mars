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

    @IBOutlet private weak var stampsCollectionView: NestedCollectionView!
    private var viewModel: PLRCellViewModel!
    
    override func configureWithViewModel(_ viewModel: PLRCellViewModel, tapAction: PLRBaseCollectionViewCell.CellTapAction?) {
        super.configureWithViewModel(viewModel, tapAction: tapAction)

        self.viewModel = viewModel
        stampsCollectionView.register(PLRStampViewCell.self, asNib: true)
        
        let layout = LeftAlignedCollectionViewFlowLayout()
        layout.minimumInteritemSpacing = Constants.interimSpacing
        stampsCollectionView.collectionViewLayout = layout
        stampsCollectionView.invalidateIntrinsicContentSize()
        stampsCollectionView.collectionViewLayout.invalidateLayout()
        stampsCollectionView.translatesAutoresizingMaskIntoConstraints = false
        stampsCollectionView.dataSource = self
        stampsCollectionView.isScrollEnabled = false
        stampsCollectionView.delegate = self
        stampsCollectionView.backgroundColor = .clear
        stampsCollectionView.clipsToBounds = false
        stampsCollectionView.isUserInteractionEnabled = false
        
        /// Do a layout pass of the cell and the stamps collection view to ensure everything is laid out correctly
        /// Removing this can cause the number of stamps in the collection view to be incorrect
        invalidateIntrinsicContentSize()
        layoutIfNeeded()
        stampsCollectionView.collectionViewLayout.invalidateLayout()
        stampsCollectionView.invalidateIntrinsicContentSize()
        stampsCollectionView.layoutIfNeeded()
    }
}

extension PLRStampsCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 100
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
