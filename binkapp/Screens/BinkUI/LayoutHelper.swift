//
//  LayoutHelper.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

struct LayoutHelper { }

extension LayoutHelper {
    static let statusBarHeight: CGFloat = 20

    static func heightForNavigationBar(_ navigationBar: UINavigationBar?) -> CGFloat {
        return navigationBar?.frame.height ?? 0
    }

    enum BinkInfoButton {
        static let imageEdgeInsets = UIEdgeInsets(top: 8, left: 6, bottom: 7, right: 5)
        static let titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 3)
    }

    enum WalletDimensions {
        static let cardHorizontalPadding: CGFloat = 25.0
        private static let cardWidth: CGFloat = UIScreen.main.bounds.width - (WalletDimensions.cardHorizontalPadding * 2)
        private static let linkCellAspectRatio: CGFloat = 34 / 57
        static let cardSize = CGSize(width: WalletDimensions.cardWidth, height: 120.0)
        static let cardLineSpacing: CGFloat = 12.0
        static let cardCornerRadius: CGFloat = 8.0
        static let contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
        static var walletPromptHeaderHeight: CGFloat {
            switch UIDevice.current.width {
            case .iPhoneSESize, .iPhone5Size, .iPhone4Size:
                return 113
            default:
                return 134
            }
        }
        
        private static func walletPromptLinkCellHeight(viewWidth: CGFloat) -> CGFloat {
            return (viewWidth / 2) * linkCellAspectRatio
        }
        
        static func sizeForWalletPrompt(viewFrame: CGRect, numberOfRows: CGFloat) -> CGSize {
            let cardHeight = walletPromptHeaderHeight + (walletPromptLinkCellHeight(viewWidth: cardWidth) * numberOfRows)
            
            return CGSize(width: cardWidth, height: cardHeight)
        }
        
        static func sizeForWalletPromptCell(viewFrame: CGRect, walletPrompt: WalletPrompt?) -> CGSize {
            let plansCount = walletPrompt?.membershipPlans?.count ?? 0
            var numberOfCellsPerRow = plansCount > 5 ? 6 : 5
            
            if case .link = walletPrompt?.type {
                numberOfCellsPerRow = 2
            }
            
            let width = (viewFrame.width / CGFloat(numberOfCellsPerRow))
            var height = width
            
            if case .link = walletPrompt?.type {
                height = width * linkCellAspectRatio
            }
            
            return CGSize(width: width, height: height)
        }
    }
}
