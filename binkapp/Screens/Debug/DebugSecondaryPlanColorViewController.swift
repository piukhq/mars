//
//  DebugSecondaryPlanColorViewController.swift
//  binkapp
//
//  Created by Nick Farrant on 11/05/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import UIKit

class DebugSecondaryPlanColorViewController: UIViewController {
    @IBOutlet private weak var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(DebugSecondaryPlanColorCell.self, asNib: true)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
}

extension DebugSecondaryPlanColorViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Current.wallet.membershipPlans?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: DebugSecondaryPlanColorCell = collectionView.dequeue(indexPath: indexPath)
        guard let plan = Current.wallet.membershipPlans?[indexPath.row] else { return cell }
        cell.configureWithPlan(plan)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 100)
    }
}
