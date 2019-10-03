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

        NotificationCenter.default.addObserver(self, selector: #selector(refreshWallet), name: .didAddPaymentCard, object: nil)

        refreshControl.addTarget(self, action: #selector(refreshWallet), for: .valueChanged)
        collectionView.addSubview(refreshControl)
        collectionView.alwaysBounceVertical = true
        
        collectionView.dataSource = self
        collectionView.delegate = self

        configureCollectionView()

        loadLocalWallet()
        refreshWallet()
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

    private func loadLocalWallet() {
        loadWallet()
    }

    @objc private func refreshWallet() {
        loadWallet(forceRefresh: true)
    }

    @objc private func loadWallet(forceRefresh: Bool = false) {
        viewModel.getWallet(forceRefresh: forceRefresh) {
            DispatchQueue.main.async { [weak self] in
                self?.refreshControl.endRefreshing()
                self?.collectionView.reloadData()
            }
        }
    }
    
}

extension PaymentWalletViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.paymentCardCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: PaymentCardCollectionViewCell = collectionView.dequeue(indexPath: indexPath)

        guard let paymentCard = viewModel.paymentCardAtIndexPath(indexPath) else {
            return cell
        }
        
        let cellViewModel = PaymentCardCellViewModel(paymentCard: paymentCard, router: viewModel.router)
        cell.configureWithViewModel(cellViewModel)

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let paymentCard = viewModel.paymentCardAtIndexPath(indexPath) else {
            return
        }
        viewModel.toPaymentCardDetail(for: paymentCard)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return LayoutHelper.WalletDimensions.cardSize
    }
}
