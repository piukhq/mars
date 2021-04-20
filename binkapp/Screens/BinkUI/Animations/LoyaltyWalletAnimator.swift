//
//  LoyaltyWalletAnimator.swift
//  binkapp
//
//  Created by Sean Williams on 12/01/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import UIKit

class LoyaltyWalletAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    private let duration = 0.4
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let loyaltyWalletViewController = transitionContext.viewController(forKey: .from) as? LoyaltyWalletViewController,
            let lcdViewController = transitionContext.viewController(forKey: .to) as? LoyaltyCardFullDetailsViewController,
            let selectedIndexPath = loyaltyWalletViewController.selectedIndexPath,
            let membershipCard = loyaltyWalletViewController.viewModel.cards?[safe: selectedIndexPath.row],
            let membershipPlan = membershipCard.membershipPlan
        else {
            transitionContext.completeTransition(false)
            return
        }
        
        let collectionViewCellFrame = loyaltyWalletViewController.collectionView.layoutAttributesForItem(at: selectedIndexPath)?.frame
        let cellFrame = loyaltyWalletViewController.collectionView.convert(collectionViewCellFrame ?? CGRect.zero, to: loyaltyWalletViewController.collectionView.superview)
        let navBarHeight = lcdViewController.navigationController?.navigationBar.frame.height ?? 0
        let statusBarHeight = loyaltyWalletViewController.view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        let topBarHeight = navBarHeight + statusBarHeight
        
        /// Primary Card
        let primaryCard = UIImageView()
        primaryCard.frame = CGRect(x: cellFrame.minX + LayoutHelper.RectangleView.primaryRectX + 7.5, y: cellFrame.minY - LayoutHelper.WalletDimensions.cardLineSpacing, width: LayoutHelper.RectangleView.primaryRectWidth / 2, height: LayoutHelper.RectangleView.primaryRectHeight / 2)
        primaryCard.transform = CGAffineTransform(rotationAngle: LayoutHelper.RectangleView.primaryRectRotation)

        let barcodeView = UIView()
        let brandHeaderRect = CGRect(x: LayoutHelper.LoyaltyCardDetail.contentPadding, y: topBarHeight + LayoutHelper.PaymentCardDetail.stackScrollViewContentInsets.top, width: lcdViewController.brandHeader.frame.width, height: lcdViewController.brandHeader.frame.height)
        var barcodeTransitionView = BarcodeView(frame: .zero)

        if lcdViewController.viewModel.shouldShowBarcode {
            /// Barcode View
            barcodeView.layer.cornerRadius = LayoutHelper.RectangleView.cornerRadius
            barcodeView.frame = brandHeaderRect
            barcodeView.alpha = 0
            
            var barcode: BarcodeView
            switch (lcdViewController.viewModel.barcodeViewModel.barcodeType, lcdViewController.viewModel.barcodeViewModel.barcodeIsMoreSquareThanRectangle) {
            case (.aztec, _), (.qr, _), (_, true):
                let barcodeView: BarcodeViewCompact = .fromNib()
                barcode = barcodeView
                barcodeView.configure(viewModel: lcdViewController.viewModel)
                
                let transitionView: BarcodeViewCompact = .fromNib()
                barcodeTransitionView = transitionView
                transitionView.configure(viewModel: lcdViewController.viewModel)
            default:
                let barcodeView: BarcodeViewWide = .fromNib()
                barcode = barcodeView
                barcodeView.configure(viewModel: lcdViewController.viewModel)
                
                let transitionView: BarcodeViewWide = .fromNib()
                barcodeTransitionView = transitionView
                transitionView.configure(viewModel: lcdViewController.viewModel)
            }
            
            barcodeView.addSubview(barcode)
            barcode.heightAnchor.constraint(equalTo: barcodeView.heightAnchor).isActive = true
            barcode.widthAnchor.constraint(equalTo: barcodeView.widthAnchor).isActive = true
            barcode.translatesAutoresizingMaskIntoConstraints = false
            
            primaryCard.addSubview(barcodeTransitionView)
            barcodeTransitionView.heightAnchor.constraint(equalTo: primaryCard.heightAnchor).isActive = true
            barcodeTransitionView.widthAnchor.constraint(equalTo: primaryCard.widthAnchor).isActive = true
            barcodeTransitionView.translatesAutoresizingMaskIntoConstraints = false
            barcodeTransitionView.alpha = 0
        } else {
            /// Primary card / brand header art
            primaryCard.layer.cornerRadius = LayoutHelper.RectangleView.cornerRadius
            primaryCard.clipsToBounds = true
            if let hexStringColor = membershipCard.card?.colour {
                primaryCard.backgroundColor = UIColor(hexString: hexStringColor)
                primaryCard.layoutIfNeeded()
                let placeholderName = membershipPlan.account?.planNameCard ?? membershipPlan.account?.planName ?? ""
                let placeholder = LCDPlaceholderGenerator.generate(with: hexStringColor, planName: placeholderName, destSize: primaryCard.frame.size)
                primaryCard.backgroundColor = UIColor(patternImage: placeholder)
            }
            primaryCard.image = lcdViewController.brandHeaderImageView.image
            primaryCard.alpha = 0
        }
        
        /// Secondary Card
        let secondaryCard = UIView()
        secondaryCard.frame = CGRect(x: cellFrame.minX + LayoutHelper.RectangleView.secondaryRectX + 7.5, y: cellFrame.minY - LayoutHelper.WalletDimensions.cardLineSpacing, width: LayoutHelper.RectangleView.secondaryRectWidth / 2, height: LayoutHelper.RectangleView.secondaryRectHeight / 2)
        secondaryCard.transform = CGAffineTransform(rotationAngle: LayoutHelper.RectangleView.secondaryRectRotation)
        secondaryCard.backgroundColor = membershipCard.membershipPlan?.secondaryBrandColor
        secondaryCard.layer.cornerRadius = LayoutHelper.RectangleView.cornerRadius
        secondaryCard.alpha = 0
        
        let containerView = transitionContext.containerView
        containerView.addSubview(lcdViewController.view)
        containerView.addSubview(loyaltyWalletViewController.view)
        containerView.addSubview(secondaryCard)
        if lcdViewController.viewModel.shouldShowBarcode {
            containerView.addSubview(barcodeView)
        }
        containerView.addSubview(primaryCard)
        
        /// Animations
        lcdViewController.secondaryColorView.alpha = 0
        lcdViewController.brandHeader.alpha = 0
        
        UIView.animate(withDuration: duration / 4, delay: 0, options: .curveEaseIn) {
            primaryCard.alpha = 1
            secondaryCard.alpha = 1
            barcodeTransitionView.alpha = 1
        }

        let secondaryCardHeight = topBarHeight + (lcdViewController.brandHeader.frame.height / 2) + LayoutHelper.LoyaltyCardDetail.contentPadding
        
        UIView.animate(withDuration: duration) {
            primaryCard.transform = CGAffineTransform(rotationAngle: 0)
            primaryCard.frame = brandHeaderRect
            secondaryCard.transform = CGAffineTransform(rotationAngle: 0)
            secondaryCard.frame = CGRect(x: -25, y: 0 - 5, width: lcdViewController.view.frame.width + 50, height: secondaryCardHeight)
            loyaltyWalletViewController.view.alpha = 0
        } completion: { _ in
            lcdViewController.brandHeader.alpha = 1
            loyaltyWalletViewController.view.alpha = 1
            lcdViewController.secondaryColorView.alpha = 1
            secondaryCard.removeFromSuperview()
            primaryCard.removeFromSuperview()
            barcodeView.removeFromSuperview()
            transitionContext.completeTransition(true)
        }
    }
}
