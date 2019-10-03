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

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(WalletLoyaltyCardCollectionViewCell.self, asNib: true)

        refreshControl.addTarget(self, action: #selector(reloadWallet), for: .valueChanged)
        collectionView.addSubview(refreshControl)

        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: .didLoadWallet, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadWallet), name: .didAddMembershipCard, object: nil)
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

 // MARK: - Navigation Bar Blurring

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        guard let bar = navigationController?.navigationBar else { return }
        prepareBarWithBlur(bar: bar, blurBackground: blurBackground)
    }
}

extension LoyaltyWalletViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Current.wallet.membershipCards?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell: WalletLoyaltyCardCollectionViewCell = collectionView.dequeue(indexPath: indexPath)

        guard let membershipCard = Current.wallet.membershipCards?[indexPath.row] else {
            return cell
        }

        let cellViewModel = WalletLoyaltyCardCellViewModel(membershipCard: membershipCard)
        cell.configureUIWithViewModel(viewModel: cellViewModel, delegate: self)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? WalletLoyaltyCardCollectionViewCell else { return }
        
        if cell.swipeState != .closed {
            cell.set(to: .closed)
        } else {
            if let card = Current.wallet.membershipCards?[indexPath.row] {
                viewModel.toFullDetailsCardScreen(membershipCard: card)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? WalletLoyaltyCardCollectionViewCell else { return }
        cell.set(to: .closed)
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
        guard let card = Current.wallet.membershipCards?[index.row] else { return }
                
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
