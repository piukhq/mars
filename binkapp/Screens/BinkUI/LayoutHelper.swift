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
        static let cardHorizontalInset: CGFloat = 25.0
        private static let cardWidth: CGFloat = UIScreen.main.bounds.width - (WalletDimensions.cardHorizontalPadding * 2)
        private static let linkCellAspectRatio: CGFloat = 34 / 57
        static let cardSize = CGSize(width: WalletDimensions.cardWidth, height: 120.0)
        static let cardLineSpacing: CGFloat = 12.0
        static let cardCornerRadius: CGFloat = 8.0
        static let contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
        static let cellInterimSpacing: CGFloat = 15.0
        private static func headerHeight(for walletPrompt: WalletPrompt) -> CGFloat {
            switch walletPrompt.type {
            case .link, .store:
                return UIDevice.current.iPhoneSE ? 114.5 : 134
            case .see:
                return UIDevice.current.iPhoneSE ? 95.5 : 134
            default:
                return 0
            }
        }
        
        private static func walletPromptLinkCellHeight(viewWidth: CGFloat) -> CGFloat {
            return (viewWidth / 2) * linkCellAspectRatio
        }
        
        static func sizeForWalletPrompt(viewFrame: CGRect, walletPrompt: WalletPrompt) -> CGSize {
            var cardHeight: CGFloat = 0
            
            switch walletPrompt.type {
            case .link:
                cardHeight = headerHeight(for: walletPrompt) + (walletPromptLinkCellHeight(viewWidth: cardWidth) * walletPrompt.numberOfRows)
            case .see, .store:
                let numberOfItemsPerRow = UIDevice.current.iPhoneSE ? 4 : 5
                let padding: CGFloat = !UIDevice.current.iPhoneSE && walletPrompt.numberOfRows == 2 ? 5 : 0 /// Fixes clipping when 10 or more cells are visible
                
                let totalSpacing: CGFloat = (cardHorizontalInset * 2) + (cellInterimSpacing * CGFloat((numberOfItemsPerRow - 1)))
                let cellHeight = ((viewFrame.width - totalSpacing) / CGFloat(numberOfItemsPerRow))
                cardHeight = headerHeight(for: walletPrompt) + (cellHeight * walletPrompt.numberOfRows) + cellInterimSpacing + padding
            default:
                break
            }
            
            return CGSize(width: cardWidth, height: cardHeight)
        }
        
        static func sizeForWalletPromptCell(viewFrame: CGRect, walletPrompt: WalletPrompt?) -> CGSize {
            guard let walletPrompt = walletPrompt else { return .zero }
            var width: CGFloat
            var height: CGFloat
            
            switch walletPrompt.type {
            case .link:
                width = viewFrame.width / CGFloat(walletPrompt.numberOfItemsPerRow)
                height = width * linkCellAspectRatio
            default:
                let totalSpacing: CGFloat = (cardHorizontalInset * 2) + (cellInterimSpacing * CGFloat((walletPrompt.numberOfItemsPerRow - 1)))
                width = (viewFrame.width - totalSpacing) / CGFloat(walletPrompt.numberOfItemsPerRow)
                height = width
            }
            
            return CGSize(width: width, height: height)
        }
    }
}
