//
//  LoyaltyWalletViewController.swift
//  binkapp
//
//  Copyright (c) 2019 Bink. All rights reserved.
//

import UIKit
import CoreGraphics
import DeepDiff
import CardScan

class LoyaltyWalletViewController: WalletViewController<LoyaltyWalletViewModel> {
    let transition = WalletAnimator()
    var selectedIndexPath: IndexPath!
    
    override func configureCollectionView() {
        super.configureCollectionView()
        collectionView.register(WalletLoyaltyCardCollectionViewCell.self, asNib: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(handlePointsScrapingUpdate), name: .webScrapingUtilityDidComplete, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarVisibility(true, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setScreenName(trackedScreen: .loyaltyWallet)
    }
    
    @objc private func handlePointsScrapingUpdate() {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row < viewModel.cardCount {
            let cell: WalletLoyaltyCardCollectionViewCell = collectionView.dequeue(indexPath: indexPath)
            
            guard let membershipCard = viewModel.cards?[indexPath.row] else {
                return cell
            }
            
            let cellViewModel = WalletLoyaltyCardCellViewModel(membershipCard: membershipCard)
            cell.configureUIWithViewModel(viewModel: cellViewModel, delegate: self)
            
            return cell
        } else {
            // join card
            let cell: WalletPromptCollectionViewCell = collectionView.dequeue(indexPath: indexPath)
            guard let walletPrompt = viewModel.promptCard(forIndexPath: indexPath) else {
                return cell
            }
            cell.configureWithWalletPrompt(walletPrompt)
            return cell
        }
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        super.collectionView(collectionView, didSelectItemAt: indexPath)
        self.selectedIndexPath = indexPath
        resetAllSwipeStates()
    }

    override func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        guard let membershipCard = viewModel.cards?[sourceIndexPath.row] else { return }
        Current.wallet.reorderMembershipCard(membershipCard, from: sourceIndexPath.row, to: destinationIndexPath.row)
    }
}

extension LoyaltyWalletViewController: WalletLoyaltyCardCollectionViewCellDelegate {
    func cellPerform(action: CellAction, cell: WalletLoyaltyCardCollectionViewCell) {
        guard let index = collectionView.indexPath(for: cell) else { return }

        switch action {
        case .barcode:
            handleBarcodeSwipe(with: index, cell: cell)
        case .delete:
            promptForDelete(with: index, cell: cell)
        case .login:
            UIAlertController.presentFeatureNotImplementedAlert(on: self)
        }
    }
    
    func handleBarcodeSwipe(with indexPath: IndexPath, cell: WalletLoyaltyCardCollectionViewCell) {
        guard let card = viewModel.cards?[indexPath.row] else {
            cell.set(to: .closed)
            return
        }
        
        if card.card?.barcode == nil && card.card?.membershipId == nil {
            viewModel.showNoBarcodeAlert {
                cell.set(to: .closed)
            }
        } else {
            toBarcode(with: indexPath, cell: cell)
        }
    }
    
    func toBarcode(with index: IndexPath, cell: WalletLoyaltyCardCollectionViewCell) {
        viewModel.toBarcodeViewController(indexPath: index) {
            cell.set(to: .closed, as: .barcode)
        }
    }
    
    func promptForDelete(with index: IndexPath, cell: WalletLoyaltyCardCollectionViewCell) {
        guard let card = viewModel.cards?[index.row] else { return }
                
        viewModel.showDeleteConfirmationAlert(card: card) {
            cell.set(to: .closed)
        }
    }
    
    func cellDidFullySwipe(action: SwipeMode?, cell: WalletLoyaltyCardCollectionViewCell) {
        guard let index = collectionView.indexPath(for: cell) else { return }
        
        if action == .barcode {
            handleBarcodeSwipe(with: index, cell: cell)
        } else {
            promptForDelete(with: index, cell: cell)
        }
    }

    func cellSwipeBegan(cell: WalletLoyaltyCardCollectionViewCell) {
        // We have to filter the cells based on their type, because otherwise the wallet prompt cells are included, and then we can't cast properly
        let cells = collectionView.visibleCells.filter { $0 != cell }.filter { $0.isKind(of: WalletLoyaltyCardCollectionViewCell.self) } as? [WalletLoyaltyCardCollectionViewCell]
        cells?.forEach { $0.set(to: .closed) }
    }

    func resetAllSwipeStates() {
        // We have to filter the cells based on their type, because otherwise the wallet prompt cells are included, and then we can't cast properly
        let cells = collectionView.visibleCells.filter { $0.isKind(of: WalletLoyaltyCardCollectionViewCell.self) } as? [WalletLoyaltyCardCollectionViewCell]
        cells?.forEach { $0.set(to: .closed) }
    }
}

extension LoyaltyWalletViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        switch operation {
        case .push:
            transition.operation = .push
            return transition
        case .pop:
            return nil
        default:
            return nil
        }
    }
}

class WalletAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    let duration = 4.0
    var operation: UINavigationController.Operation = .push
//    var membershipCard: CD_MembershipCard!
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let fromViewController = transitionContext.viewController(forKey: .from),
            let toViewController = transitionContext.viewController(forKey: .to)
        else {
            transitionContext.completeTransition(false)
            return
        }

        guard let loyaltyWalletViewController = fromViewController as? LoyaltyWalletViewController else { return }
        guard let LCDViewController = toViewController as? LoyaltyCardFullDetailsViewController else { return }
        
        let containerView = transitionContext.containerView
        let primaryCard = UIView()
        let cellFrame = loyaltyWalletViewController.collectionView.layoutAttributesForItem(at: loyaltyWalletViewController.selectedIndexPath)?.frame
        print(cellFrame as Any)
        
        let actualCellPosition = loyaltyWalletViewController.collectionView.convert(cellFrame ?? CGRect.zero, to: loyaltyWalletViewController.collectionView.superview)
        print(actualCellPosition as Any)
        
        primaryCard.frame = CGRect(x: 134 + (actualCellPosition.minX) + 7.5, y: (actualCellPosition.minY) - LayoutHelper.WalletDimensions.cardLineSpacing, width: 514.29 / 2, height: 370.52 / 2)

//        primaryCard.frame = CGRect(x: 134 + (cellFrame?.minX ?? 25) + 7.5, y: (cellFrame?.minY ?? 0) + 38.72 + topBarHeight - LayoutHelper.WalletDimensions.cardLineSpacing - LayoutHelper.WalletDimensions.contentInset.top, width: 514.29 / 2, height: 370.52 / 2)
        primaryCard.transform = CGAffineTransform(rotationAngle: -20 * CGFloat.pi / 180)
//        let membershipCard = loyaltyWalletViewController.viewModel.cards?[loyaltyWalletViewController.selectedIndexPath.row]
//        primaryCard.backgroundColor = UIColor(hexString: membershipCard?.card?.colour ?? "")
        primaryCard.backgroundColor = .black

        primaryCard.layer.cornerRadius = 12
        
        containerView.addSubview(LCDViewController.view)
        containerView.addSubview(loyaltyWalletViewController.view)
        containerView.addSubview(primaryCard)

        loyaltyWalletViewController.view.isHidden = false
        LCDViewController.view.isHidden = false
        
        UIView.animate(withDuration: duration / 2, delay: duration / 2, options: .curveEaseIn) {
            primaryCard.alpha = 0
        } completion: { _ in
        }

        
        UIView.animate(withDuration: duration) {
//            primaryCard.transform = CGAffineTransform(rotationAngle: 0)
//            primaryCard.frame = CGRect(x: LayoutHelper.LoyaltyCardDetail.contentPadding, y: LCDViewController.brandHeader.frame.maxY - 5, width: LCDViewController.brandHeader.frame.width, height: LCDViewController.brandHeader.frame.height)
            loyaltyWalletViewController.view.alpha = 0
        } completion: { _ in
            loyaltyWalletViewController.view.alpha = 1
            loyaltyWalletViewController.view.isHidden = false
            LCDViewController.view.isHidden = false
            primaryCard.removeFromSuperview()
            transitionContext.completeTransition(true)
        }
    }
}
