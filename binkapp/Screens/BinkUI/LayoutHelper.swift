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
        static var walletPromptLinkHeaderHeight: CGFloat {
            switch UIDevice.current.width {
            case .iPhone6Size, .iPhone5Size, .iPhone4Size:
                return 113
            default:
                return 134
            }
        }
        
        static var walletPromptSeeStoreHeaderHeight: CGFloat {
            switch UIDevice.current.width {
            case .iPhone6Size, .iPhone5Size, .iPhone4Size:
                return 95.5
            default:
                return 134
            }
        }
        
        private static func walletPromptLinkCellHeight(viewWidth: CGFloat) -> CGFloat {
            return (viewWidth / 2) * linkCellAspectRatio
        }
        
        static func sizeForWalletPrompt(viewFrame: CGRect, walletPrompt: WalletPrompt) -> CGSize {
            var cardHeight: CGFloat = 0
            
            switch walletPrompt.type {
            case .link:
                cardHeight = walletPromptLinkHeaderHeight + (walletPromptLinkCellHeight(viewWidth: cardWidth) * walletPrompt.numberOfRows)
            case .see, .store:
                var numberOfItemsPerRow = 5
                var padding: CGFloat = 0
                
                switch UIDevice.current.width {
                case .iPhone6Size, .iPhone5Size, .iPhone4Size:
                    numberOfItemsPerRow = 4
                default:
                    padding = walletPrompt.numberOfRows == 2 ? 5 : 0
                }
                
                let totalSpacing: CGFloat = (cardHorizontalInset * 2) + (cellInterimSpacing * CGFloat((numberOfItemsPerRow - 1)))
                let cellHeight = ((viewFrame.width - totalSpacing) / CGFloat(numberOfItemsPerRow))
                cardHeight = walletPromptSeeStoreHeaderHeight + (cellHeight * walletPrompt.numberOfRows) + cellInterimSpacing + padding
            default:
                break
            }
            
            return CGSize(width: cardWidth, height: cardHeight)
        }
        
        static func sizeForWalletPromptCell(viewFrame: CGRect, walletPrompt: WalletPrompt?) -> CGSize {
            var numberOfItemsPerRow = 5
            switch UIDevice.current.width {
            case .iPhone6Size, .iPhone5Size, .iPhone4Size:
                numberOfItemsPerRow = 4
            default:
                break
            }
            
            var totalSpacing: CGFloat = (cardHorizontalInset * 2) + (cellInterimSpacing * CGFloat((numberOfItemsPerRow - 1)))

            if case .link = walletPrompt?.type {
                numberOfItemsPerRow = 2
                totalSpacing = 0
            }
            
            let width = ((viewFrame.width - totalSpacing) / CGFloat(numberOfItemsPerRow))
            var height = width
            
            if case .link = walletPrompt?.type {
                height = width * linkCellAspectRatio
            }
            
            return CGSize(width: width, height: height)
        }
    }
}
