//
//  LoyaltyWalletAnimator.swift
//  binkapp
//
//  Created by Sean Williams on 12/01/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import UIKit

class LoyaltyWalletAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    private let duration = 0.6
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let loyaltyWalletViewController = transitionContext.viewController(forKey: .from) as? LoyaltyWalletViewController,
            let LCDViewController = transitionContext.viewController(forKey: .to) as? LoyaltyCardFullDetailsViewController,
            let membershipCard = loyaltyWalletViewController.viewModel.cards?[loyaltyWalletViewController.selectedIndexPath.row],
            let membershipPlan = membershipCard.membershipPlan
        else {
            transitionContext.completeTransition(false)
            return
        }
        
        let collectionViewCellFrame = loyaltyWalletViewController.collectionView.layoutAttributesForItem(at: loyaltyWalletViewController.selectedIndexPath)?.frame
        let cellFrame = loyaltyWalletViewController.collectionView.convert(collectionViewCellFrame ?? CGRect.zero, to: loyaltyWalletViewController.collectionView.superview)
        let rectDimensions = LayoutHelper.RectangleView.self
        let navBarHeight = LCDViewController.navigationController?.navigationBar.frame.height ?? 0
        let statusBarHeight = loyaltyWalletViewController.view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        let topBarHeight = navBarHeight + statusBarHeight
        
        /// Primary Card
        let primaryCard = UIView()
        primaryCard.frame = CGRect(x: cellFrame.minX + rectDimensions.primaryRectX + 7.5, y: cellFrame.minY - LayoutHelper.WalletDimensions.cardLineSpacing, width: rectDimensions.primaryRectWidth / 2, height: rectDimensions.primaryRectHeight / 2)
        primaryCard.transform = CGAffineTransform(rotationAngle: rectDimensions.primaryRectRotation)
        primaryCard.backgroundColor = UIColor(hexString: membershipCard.card?.colour ?? "")
        primaryCard.layer.cornerRadius = rectDimensions.cornerRadius
        primaryCard.alpha = 0
        
        /// Brand Header
        let brandHeader = UIImageView()
        brandHeader.layer.cornerRadius = rectDimensions.cornerRadius
        brandHeader.clipsToBounds = true
        brandHeader.contentMode = .scaleAspectFill
        let brandHeaderRect = CGRect(x: LayoutHelper.LoyaltyCardDetail.contentPadding, y: topBarHeight + LayoutHelper.PaymentCardDetail.stackScrollViewContentInsets.top, width: LCDViewController.brandHeader.frame.width, height: LCDViewController.brandHeader.frame.height)
        brandHeader.frame = brandHeaderRect
        brandHeader.alpha = 0
        if LCDViewController.viewModel.isMembershipCardAuthorised {
            brandHeader.setImage(forPathType: .membershipPlanTier(card: membershipCard), animated: true)
        } else {
            brandHeader.setImage(forPathType: .membershipPlanHero(plan: membershipPlan), animated: true)
        }
        
        /// Secondary Card
        let secondaryCard = UIView()
        secondaryCard.frame = CGRect(x: cellFrame.minX + rectDimensions.secondaryRectX + 7.5, y: cellFrame.minY - LayoutHelper.WalletDimensions.cardLineSpacing, width: rectDimensions.secondaryRectWidth / 2, height: rectDimensions.secondaryRectHeight / 2)
        secondaryCard.transform = CGAffineTransform(rotationAngle: rectDimensions.secondaryRectRotation)
        secondaryCard.backgroundColor = membershipCard.membershipPlan?.secondaryBrandColor
        secondaryCard.layer.cornerRadius = rectDimensions.cornerRadius
        secondaryCard.alpha = 0
        
        let containerView = transitionContext.containerView
        containerView.addSubview(LCDViewController.view)
        containerView.addSubview(loyaltyWalletViewController.view)
        containerView.addSubview(secondaryCard)
        containerView.addSubview(brandHeader)
        containerView.addSubview(primaryCard)
        
        /// Animations
        LCDViewController.secondaryColorView.alpha = 0
        LCDViewController.brandHeader.alpha = 0
        
        UIView.animate(withDuration: duration / 4, delay: 0, options: .curveEaseIn) {
            primaryCard.alpha = 1
            secondaryCard.alpha = 1
        } completion: { _ in
            UIView.animate(withDuration: self.duration / 2, delay: self.duration / 4, options: .curveEaseOut) {
                primaryCard.alpha = 0
            }
        }

        let secondaryCardHeight = topBarHeight + (LCDViewController.brandHeader.frame.height / 2) + LayoutHelper.LoyaltyCardDetail.contentPadding
        
        UIView.animate(withDuration: duration) {
            primaryCard.transform = CGAffineTransform(rotationAngle: 0)
            primaryCard.frame = brandHeaderRect
            secondaryCard.transform = CGAffineTransform(rotationAngle: 0)
            secondaryCard.frame = CGRect(x: -25, y: 0 - 5, width: LCDViewController.view.frame.width + 50, height: secondaryCardHeight)
            loyaltyWalletViewController.view.alpha = 0
            brandHeader.alpha = 1
        } completion: { _ in
            loyaltyWalletViewController.view.alpha = 1
            LCDViewController.brandHeader.alpha = 1
            LCDViewController.secondaryColorView.alpha = 1
            primaryCard.removeFromSuperview()
            secondaryCard.removeFromSuperview()
            brandHeader.removeFromSuperview()
            transitionContext.completeTransition(true)
        }
    }
}
