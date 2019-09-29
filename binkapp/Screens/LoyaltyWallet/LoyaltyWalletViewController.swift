//
//  LoyaltyWalletViewController.swift
//  binkapp
//
//  Copyright (c) 2019 Bink. All rights reserved.
//

import UIKit
import CoreGraphics
import DeepDiff

class LoyaltyWalletViewController: UIViewController, BarBlurring {
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = .white
        collectionView.contentInset = LayoutHelper.WalletDimensions.contentInset
        
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leftAnchor.constraint(equalTo: view.leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
        
        return collectionView
    }()
    
    internal lazy var blurBackground = defaultBlurredBackground()
    
    private lazy var layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = LayoutHelper.WalletDimensions.cardSize
        layout.minimumLineSpacing = LayoutHelper.WalletDimensions.cardLineSpacing
        return layout
    }()
    
    private let viewModel: LoyaltyWalletViewModel
    private let refreshControl = UIRefreshControl()
    
    init(viewModel: LoyaltyWalletViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(UINib(nibName: "WalletLoyaltyCardCollectionViewCell", bundle: Bundle(for: WalletLoyaltyCardCollectionViewCell.self)), forCellWithReuseIdentifier: "WalletLoyaltyCardCollectionViewCell")
        refreshControl.addTarget(self, action: #selector(refreshWallet), for: .valueChanged)
        collectionView.addSubview(refreshControl)
        
        loadLocalWallet()
        refreshWallet()
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadLocalWallet), name: .didAddMembershipCard, object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        refreshControl.endRefreshing()
        super.viewWillDisappear(animated)
    }

    @objc private func loadLocalWallet() {
        loadWallet()
    }

    @objc private func refreshWallet() {
        loadWallet(forceRefresh: true)
    }

    @objc private func loadWallet(forceRefresh: Bool = false) {
        viewModel.getWallet(forceRefresh: forceRefresh) { [weak self] in
            DispatchQueue.main.async {
                self?.refreshControl.endRefreshing()
                self?.collectionView.reloadData()
            }
        }
    }

 // MARK: - Navigation Bar Blurring

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        guard let bar = navigationController?.navigationBar else { return }
        prepareBarWithBlur(bar: bar, blurBackground: blurBackground)
    }
}

extension LoyaltyWalletViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    //TO DO: ADD GRADIENT COLOR TO SWIPE ACTION
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.membershipCardsCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WalletLoyaltyCardCollectionViewCell", for: indexPath) as! WalletLoyaltyCardCollectionViewCell
        
        if let card = viewModel.membershipCard(forIndexPath: indexPath) {
            cell.configureUIWithMembershipCard(card: card, delegate: self)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? WalletLoyaltyCardCollectionViewCell else { return }
        
        if cell.swipeState != .closed {
            cell.set(to: .closed)
        } else {
            // Move to LCD
            if let card = viewModel.membershipCard(forIndexPath: indexPath) {
                viewModel.toFullDetailsCardScreen(membershipCard: card)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? WalletLoyaltyCardCollectionViewCell else { return }
        cell.set(to: .closed)
    }
}

// MARK: - View model delegate

extension LoyaltyWalletViewController: LoyaltyWalletViewModelDelegate {
    func loyaltyWalletViewModelDidFetchData(_ viewModel: LoyaltyWalletViewModel) {
        DispatchQueue.main.async { [weak self] in
            self?.refreshControl.endRefreshing()
            self?.collectionView.reloadData()
        }
    }
}

extension LoyaltyWalletViewController: WalletLoyaltyCardCollectionViewCellDelegate {
    func cellPerform(action: CellAction, cell: WalletLoyaltyCardCollectionViewCell) {
        guard let index = collectionView.indexPath(for: cell) else { return }

        switch action {
        case .barcode:
            toBarcode(with: index, cell: cell)
        case .delete:
            promptForDelete(with: index, cell: cell)
        case .login:
            UIAlertController.presentFeatureNotImplementedAlert(on: self)
        }
    }
    
    func toBarcode(with index: IndexPath, cell: WalletLoyaltyCardCollectionViewCell) {
        viewModel.toBarcodeViewController(item: index.item) {
            cell.set(to: .closed, as: .barcode)
        }
    }
    
    func promptForDelete(with index: IndexPath, cell: WalletLoyaltyCardCollectionViewCell) {
        guard let card = viewModel.membershipCard(forIndexPath: index) else { return }
                
        viewModel.showDeleteConfirmationAlert(card: card, yesCompletion: { [weak self] in
            self?.collectionView.reloadData()
        }, noCompletion: {
            cell.set(to: .closed)
        })
    }
    
    func cellDidFullySwipe(action: SwipeMode?, cell: WalletLoyaltyCardCollectionViewCell) {
        guard let index = collectionView.indexPath(for: cell) else { return }
        
        if action == .barcode {
            toBarcode(with: index, cell: cell)
        } else {
            promptForDelete(with: index, cell: cell)
        }
    }
    
    func cellSwipeBegan(cell: WalletLoyaltyCardCollectionViewCell) {
        let cells = collectionView.visibleCells.filter { $0 != cell }
        guard let walletCells = cells as? [WalletLoyaltyCardCollectionViewCell] else { return }
        walletCells.forEach { $0.set(to: .closed) }
    }
}
