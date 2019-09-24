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

        refreshControl.addTarget(self, action: #selector(refreshWallet), for: .valueChanged)
        collectionView.addSubview(refreshControl)
        collectionView.alwaysBounceVertical = true
        
        collectionView.dataSource = self
        collectionView.delegate = self

        configureCollectionView()

        // Reimplement when we bring core data into this view controller
//        loadLocalWallet()
        refreshWallet()
    }

    private func configureCollectionView() {
        collectionView.registerCellForClass(PaymentCardCollectionViewCell.self, asNib: true)
        guard let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        flowLayout.sectionInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
        flowLayout.minimumLineSpacing = 12
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
        return viewModel.paymentCards?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithClass(PaymentCardCollectionViewCell.self, forIndexPath: indexPath)

        guard let paymentCard = viewModel.paymentCards?[indexPath.row] else {
            return cell
        }

        cell.configureWithPaymentCard(paymentCard)

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenWidth = UIScreen.main.bounds.width
        return CGSize(width: screenWidth - 50, height: 120)
    }
}
