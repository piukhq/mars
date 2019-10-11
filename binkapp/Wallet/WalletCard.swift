//
//  WalletCard.swift
//  binkapp
//
//  Created by Nick Farrant on 11/10/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit
import CoreData

enum WalletCardType {
    case loyalty
    case payment
    case join
}

typealias WalletCard = WalletCardProtocol & NSManagedObject

protocol WalletCardProtocol {
    var id: String! { get }
    var type: WalletCardType { get }
}

class WalletViewController<T: WalletViewModel>: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var collectionView: UICollectionView!

    let refreshControl = UIRefreshControl()

    let viewModel: T

    init(viewModel: T) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: .didLoadWallet, object: nil)

        refreshControl.addTarget(self, action: #selector(reloadWallet), for: .valueChanged)
        collectionView.addSubview(refreshControl)
        collectionView.alwaysBounceVertical = true

        collectionView.dataSource = self
        collectionView.delegate = self

        configureCollectionView()
    }

    override func viewWillDisappear(_ animated: Bool) {
        refreshControl.endRefreshing()
        super.viewWillDisappear(animated)
    }

    func configureCollectionView() {
        collectionView.contentInset = LayoutHelper.WalletDimensions.contentInset
        guard let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        flowLayout.minimumLineSpacing = LayoutHelper.WalletDimensions.cardLineSpacing
    }

    @objc private func reloadWallet() {
        viewModel.reloadWallet()
    }

    @objc private func refresh() {
        refreshControl.endRefreshing()
        collectionView.reloadData()
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.cardCount
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return LayoutHelper.WalletDimensions.cardSize
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        fatalError("Should be implemented by subclass")
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let card = viewModel.card(forIndexPath: indexPath) else {
            return
        }

        viewModel.toCardDetail(for: card)
    }
}
