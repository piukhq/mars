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
        collectionView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
        
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leftAnchor.constraint(equalTo: view.leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
        
        return collectionView
    }()
    
    private lazy var layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 375 - 28, height: 120)
        layout.minimumLineSpacing = 28.0
        return layout
    }()
    
    private let viewModel: LoyaltyWalletViewModel
    internal lazy var blurBackground = defaultBlurredBackground()
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
//        NotificationCenter.default.addObserver(self, selector: #selector(refreshScreen), name: .didDeleteMemebershipCard, object: nil)
        refreshControl.addTarget(self, action: #selector(refreshWallet), for: .valueChanged)
        collectionView.addSubview(refreshControl)
        
        loadLocalWallet()
        refreshWallet()
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
//            cell.configureUIWithMembershipCard(
//                card: <#T##MembershipCardModel#>,
//                andMemebershipPlan: <#T##MembershipPlanModel#>,
//                delegate: self
//            )
        }
//        if let cardPlan = viewModel.getMembershipPlans().first(where: {($0.id == membershipPlan)}) {
//        }
        
//        cell.configureUIWithMembershipCard(card: viewModel.getMembershipCards()[indexPath.item], andMemebershipPlan: cardPlan)
        return cell
    }

    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCellWithClass(WalletLoyaltyCardTableViewCell.self, forIndexPath: indexPath)
//
//        guard let card = viewModel.membershipCard(forIndexPath: indexPath) else {
//            return cell
//        }
//
//        guard let plan = viewModel.membershipPlanForCard(card: card) else {
//            return cell
//        }
//
//        cell.configureUIWithMembershipCard(card: card, membershipPlan: plan)
//
//        return cell
//    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? WalletLoyaltyCardCollectionViewCell else { return }
        
        if cell.swipeState != .closed {
            cell.set(to: .closed)
        } else {
            // Move to LCD
            let card = viewModel.membershipCard(forIndexPath: indexPath)
//            if let membershipPlan = viewModel.membershipPlanForCard(card: card) {
//                viewModel.toFullDetailsCardScreen(membershipCard: card, membershipPlan: membershipPlan)
//            }

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
        
//        let old = viewModel.getMembershipCards()
//
//        viewModel.showDeleteConfirmationAlert(index: index.item, yesCompletion: { [weak self] newCards in
//            let changes = diff(old: old, new: newCards)
//
//            self?.collectionView.reload(changes: changes, updateData: {
//                self?.viewModel.updateMembershipCards(new: newCards)
//            })
//        }, noCompletion: {
//            cell.set(to: .closed)
//        })
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
