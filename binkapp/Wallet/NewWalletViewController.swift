//
//  NewWalletViewController.swift
//  binkapp
//
//  Created by Nick Farrant on 23/06/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import UIKit

class NewLoyaltyWalletViewController: BinkViewController, WalletLoyaltyCardCollectionViewCellDelegate, UICollectionViewDelegateFlowLayout {
    func cellSwipeBegan(cell: WalletLoyaltyCardCollectionViewCell) {
        //
    }
    
    func cellDidFullySwipe(action: SwipeMode?, cell: WalletLoyaltyCardCollectionViewCell) {
        //
    }
    
    func cellPerform(action: CellAction, cell: WalletLoyaltyCardCollectionViewCell) {
        //
    }
    
    typealias DataSource = UICollectionViewDiffableDataSource<Section, CD_MembershipCard>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, CD_MembershipCard>
    
    enum Section {
        case main
    }
    
    private lazy var dataSource = makeDataSource()
    
    func makeDataSource() -> DataSource {
        let dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, membershipCard in
            let cell: WalletLoyaltyCardCollectionViewCell = collectionView.dequeue(indexPath: indexPath)
            guard let membershipCard = self.viewModel.cards?[indexPath.row] else { return cell }
            let cellViewModel = WalletLoyaltyCardCellViewModel(membershipCard: membershipCard)
            cell.configureUIWithViewModel(viewModel: cellViewModel, indexPath: indexPath, delegate: self)
            return cell
        }
        return dataSource
    }
    
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = .clear
        collectionView.contentInset = LayoutHelper.WalletDimensions.contentInset
        return collectionView
    }()
    
    private lazy var layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = LayoutHelper.WalletDimensions.cardLineSpacing
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        return layout
    }()
    
    let viewModel: LoyaltyWalletViewModel
    
    init(viewModel: LoyaltyWalletViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func applySnapshot(animatingDifferences: Bool = true) {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(Current.wallet.membershipCards ?? [])
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshLocal), name: .didLoadLocalWallet, object: nil)
        configureCollectionView()
        applySnapshot()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            Current.wallet.membershipCards?.remove(at: 0)
            self.applySnapshot()
        }
    }
    
    @objc func refreshLocal() {
        applySnapshot()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func configureCollectionView() {
        collectionView.register(WalletLoyaltyCardCollectionViewCell.self, asNib: true)
        view.addSubview(collectionView)
        
        collectionView.dataSource = dataSource
        collectionView.delegate = self
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leftAnchor.constraint(equalTo: view.leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let card = dataSource.itemIdentifier(for: indexPath) else { return }
        print(card.membershipPlan?.account?.companyName ?? "")
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return LayoutHelper.WalletDimensions.cardSize
    }
    
    @objc func reloadWallet() {
        viewModel.reloadWallet()
    }
    
    @objc private func refresh() {
        viewModel.setupWalletPrompts()
        collectionView.reloadData()
    }
    
    override func configureForCurrentTheme() {
        super.configureForCurrentTheme()
        collectionView.reloadData()
        collectionView.indicatorStyle = Current.themeManager.scrollViewIndicatorStyle(for: traitCollection)
    }
}
