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
            let membershipCard = loyaltyWalletViewController.viewModel.cards?[loyaltyWalletViewController.selectedIndexPath?.row ?? 0],
            let membershipPlan = membershipCard.membershipPlan
        else {
            transitionContext.completeTransition(false)
            return
        }
        
        lcdViewController.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        let selectedIndexPath = loyaltyWalletViewController.selectedIndexPath ?? IndexPath(item: 0, section: 0)
        let collectionViewCellFrame = loyaltyWalletViewController.collectionView.layoutAttributesForItem(at: selectedIndexPath)?.frame
        let cellFrame = loyaltyWalletViewController.collectionView.convert(collectionViewCellFrame ?? CGRect.zero, to: loyaltyWalletViewController.collectionView.superview)
        let navBarHeight = lcdViewController.navigationController?.navigationBar.frame.height ?? 0
        let statusBarHeight = loyaltyWalletViewController.view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        let topBarHeight = navBarHeight + statusBarHeight
        
        /// Primary Card
        let primaryCard = UIView()
        primaryCard.frame = CGRect(x: cellFrame.minX + LayoutHelper.RectangleView.primaryRectX + 7.5, y: cellFrame.minY - LayoutHelper.WalletDimensions.cardLineSpacing, width: LayoutHelper.RectangleView.primaryRectWidth / 2, height: LayoutHelper.RectangleView.primaryRectHeight / 2)
        primaryCard.transform = CGAffineTransform(rotationAngle: LayoutHelper.RectangleView.primaryRectRotation)
        primaryCard.backgroundColor = UIColor(hexString: membershipCard.card?.colour ?? "")
        primaryCard.layer.cornerRadius = LayoutHelper.RectangleView.cornerRadius
        primaryCard.alpha = 0
        
        /// Brand Header
        let brandHeader = UIImageView()
        brandHeader.layer.cornerRadius = LayoutHelper.RectangleView.cornerRadius
        brandHeader.clipsToBounds = true
        brandHeader.contentMode = .scaleAspectFill
        let brandHeaderRect = CGRect(x: LayoutHelper.LoyaltyCardDetail.contentPadding, y: topBarHeight + LayoutHelper.PaymentCardDetail.stackScrollViewContentInsets.top, width: lcdViewController.brandHeader.frame.width, height: lcdViewController.brandHeader.frame.height)
        brandHeader.frame = brandHeaderRect
        brandHeader.alpha = 0
        if let hexStringColor = membershipCard.card?.colour {
            brandHeader.backgroundColor = UIColor(hexString: hexStringColor)
            brandHeader.layoutIfNeeded()
            let placeholderName = membershipPlan.account?.planNameCard ?? membershipPlan.account?.planName ?? ""
            let placeholder = LCDPlaceholderGenerator.generate(with: hexStringColor, planName: placeholderName, destSize: brandHeader.frame.size)
            brandHeader.backgroundColor = UIColor(patternImage: placeholder)
        }
        brandHeader.image = lcdViewController.brandHeader.image
        
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
        containerView.addSubview(brandHeader)
        containerView.addSubview(primaryCard)
        
        /// Animations
        lcdViewController.secondaryColorView.alpha = 0
        lcdViewController.brandHeader.alpha = 0
        
        UIView.animate(withDuration: duration / 4, delay: 0, options: .curveEaseIn) {
            primaryCard.alpha = 1
            secondaryCard.alpha = 1
        } completion: { [weak self] _ in
            guard let self = self else { return }
            UIView.animate(withDuration: self.duration / 2, delay: self.duration / 4, options: .curveEaseOut) {
                primaryCard.alpha = 0
            }
        }

        let secondaryCardHeight = topBarHeight + (lcdViewController.brandHeader.frame.height / 2) + LayoutHelper.LoyaltyCardDetail.contentPadding
        
        UIView.animate(withDuration: duration) {
            primaryCard.transform = CGAffineTransform(rotationAngle: 0)
            primaryCard.frame = brandHeaderRect
            secondaryCard.transform = CGAffineTransform(rotationAngle: 0)
            secondaryCard.frame = CGRect(x: -25, y: 0 - 5, width: lcdViewController.view.frame.width + 50, height: secondaryCardHeight)
            loyaltyWalletViewController.view.alpha = 0
            brandHeader.alpha = 1
            lcdViewController.brandHeader.alpha = 1
        } completion: { _ in
            loyaltyWalletViewController.view.alpha = 1
            lcdViewController.secondaryColorView.alpha = 1
            primaryCard.removeFromSuperview()
            secondaryCard.removeFromSuperview()
            brandHeader.removeFromSuperview()
            transitionContext.completeTransition(true)
        }
    }
}
