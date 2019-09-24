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
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        viewModel.delegate = self
        viewModel.getPaymentCards()
    }
    
}

extension PaymentWalletViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.paymentCards.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return UICollectionViewCell()
    }
    
    
}

extension PaymentWalletViewController: UICollectionViewDelegate {
    
}

extension PaymentWalletViewController: PaymentWalletViewModelDelegate {
    func paymentWalletViewModelDidLoadData(_ viewModel: PaymentWalletViewModel) {
        
    }
}
