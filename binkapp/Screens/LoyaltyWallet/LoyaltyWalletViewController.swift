//
//  LoyaltyWalletViewController.swift
//  binkapp
//
//  Copyright (c) 2019 Bink. All rights reserved.
//

import UIKit
import CoreGraphics

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

        NotificationCenter.default.addObserver(self, selector: #selector(refreshScreen(_:)), name: .didDeleteMemebershipCard, object: nil)
    }

    // MARK: - Navigation Bar Blurring
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard let bar = navigationController?.navigationBar else { return }
        
        prepareBarWithBlur(bar: bar, blurBackground: blurBackground)
    }
}

// MARK: - Private methods
private extension LoyaltyWalletViewController {
@objc func refreshScreen(_: Notification) {
viewModel.refreshScreen()
}
}

extension LoyaltyWalletViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    //TO DO: ADD GRADIENT COLOR TO SWIPE ACTION
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.membershipCardsCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let membershipPlan = viewModel.getMembershipCards()[indexPath.item].membershipPlan

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WalletLoyaltyCardCollectionViewCell", for: indexPath) as! WalletLoyaltyCardCollectionViewCell
        if let cardPlan = viewModel.getMembershipPlans().first(where: {($0.id == membershipPlan)}) {
            
            
            
            
            cell.configureUIWithMembershipCard(card: viewModel.getMembershipCards()[indexPath.item], andMemebershipPlan: cardPlan)
        }
        
        return cell
    }
    
//    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//        let action = UIContextualAction(style: .destructive, title: "barcode_swipe_title".localized, handler: { _,_,_  in
//            self.viewModel.toBarcodeViewController()
//            self.collectionView.reloadData()
//        })
//
//        action.image = UIImage(named: "swipeBarcode")
//        action.backgroundColor = UIColor(red: 99/255, green: 159/255, blue: 255/255, alpha: 1)
//        let configuration = UISwipeActionsConfiguration(actions: [action])
//        return configuration
//    }
//
//    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//        let action = UIContextualAction(style: .normal, title: "delete_swipe_title".localized) { _, _, completion in
//            self.viewModel.showDeleteConfirmationAlert(index: indexPath.row, yesCompletion: {
//                tableView.deleteRows(at: [indexPath], with: .automatic)
//                tableView.reloadData()
//            }, noCompletion: {
//                tableView.setEditing(false, animated: true)
//            })
//        }
//
//        action.image = UIImage(named: "trashIcon")
//        action.backgroundColor = UIColor.red
//        let configuration = UISwipeActionsConfiguration(actions: [action])
//
//        return configuration
//    }
    
//    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        return 12
//    }
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let alert = UIAlertController(title: "Error", message: "To be implemented", preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//        present(alert, animated: true)
//    }
}

// MARK: - View model delegate

extension LoyaltyWalletViewController: LoyaltyWalletViewModelDelegate {
    func didFetchMembershipPlans() {
        collectionView.reloadData()
    }
    
    func didFetchCards() {
        collectionView.reloadData()
    }
}
