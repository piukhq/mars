//
//  PaymentWalletViewController.swift
//  binkapp
//
//  Created by Paul Tiriteu on 23/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class PaymentWalletViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!

    private let refreshControl = UIRefreshControl()
    private let viewModel: PaymentWalletViewModel
    
    init(viewModel: PaymentWalletViewModel) {
        self.viewModel = viewModel
        super.init(nibName: "PaymentWalletViewController", bundle: Bundle(for: PaymentWalletViewController.self))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: .didLoadWallet, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadWallet), name: .didAddPaymentCard, object: nil)

        refreshControl.addTarget(self, action: #selector(reloadWallet), for: .valueChanged)
        collectionView.addSubview(refreshControl)
        collectionView.alwaysBounceVertical = true
        
        collectionView.dataSource = self
        collectionView.delegate = self

        configureCollectionView()
    }

    private func configureCollectionView() {
        collectionView.register(PaymentCardCollectionViewCell.self, asNib: true)
        collectionView.contentInset = LayoutHelper.WalletDimensions.contentInset
        guard let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        flowLayout.minimumLineSpacing = LayoutHelper.WalletDimensions.cardLineSpacing
    }

    override func viewWillDisappear(_ animated: Bool) {
        refreshControl.endRefreshing()
        super.viewWillDisappear(animated)
    }

    @objc private func reloadWallet() {
        Current.wallet.load()
    }

    @objc private func refresh() {
        refreshControl.endRefreshing()
        collectionView.reloadData()
    }
    
}

extension PaymentWalletViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Current.wallet.paymentCards?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: PaymentCardCollectionViewCell = collectionView.dequeue(indexPath: indexPath)

        // TODO: All calls to current.wallet should be abstracted by the viewmodel
        guard let paymentCard = Current.wallet.paymentCards?[indexPath.row] else {
            return cell
        }
        
        let cellViewModel = PaymentCardCellViewModel(paymentCard: paymentCard, router: viewModel.router)
        cell.configureWithViewModel(cellViewModel)

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return LayoutHelper.WalletDimensions.cardSize
    }
}
