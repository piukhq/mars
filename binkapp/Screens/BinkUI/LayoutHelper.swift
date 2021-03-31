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
        static let cardSize = CGSize(width: WalletDimensions.cardWidth, height: 120.0)
        static let cardLineSpacing: CGFloat = 12.0
        static let cardCornerRadius: CGFloat = 8.0
        static let contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
        static let cellInterimSpacing: CGFloat = 15.0
        private static let cardWidth: CGFloat = UIScreen.main.bounds.width - (WalletDimensions.cardHorizontalPadding * 2)
        private static let linkCellAspectRatio: CGFloat = 34 / 57
        private static var walletPromptLinkCellHeight: CGFloat {
            (cardWidth / 2) * linkCellAspectRatio
        }
        private static func walletPromptSeeStoreCellHeight(_ itemsPerRow: CGFloat) -> CGFloat {
            let totalSpacing = (cardHorizontalInset * 2) + (cellInterimSpacing * (itemsPerRow - 1))
            return (cardWidth - totalSpacing) / itemsPerRow
        }
        
        private static func headerHeight(for walletPrompt: WalletPrompt) -> CGFloat {
            switch walletPrompt.type {
            case .link, .store:
                return UIDevice.current.isSmallSize ? 114.5 : 134
            case .see:
                switch UIDevice.current.width {
                case .iPhone12Size:
                    return 134
                case .iPhone12MiniSize, .iPhoneSESize, .iPhone5Size:
                    return 95.5
                default:
                    return 112
                }
            default:
                return 0
            }
        }
        
        static func sizeForWalletPrompt(walletPrompt: WalletPrompt) -> CGSize {
            var cardHeight = headerHeight(for: walletPrompt)
            switch walletPrompt.type {
            case .link:
                cardHeight += walletPromptLinkCellHeight * walletPrompt.numberOfRows
            case .see, .store:
                let merchantGridTotalCellsHeight = walletPromptSeeStoreCellHeight(walletPrompt.numberOfItemsPerRow) * walletPrompt.numberOfRows
                let merchantGridSpacing = cellInterimSpacing * (walletPrompt.numberOfRows - 1)
                cardHeight += merchantGridTotalCellsHeight + merchantGridSpacing + cardHorizontalInset
            default:
                break
            }
            
            return CGSize(width: cardWidth, height: cardHeight)
        }
        
        static func sizeForWalletPromptCell(walletPrompt: WalletPrompt) -> CGSize {
            switch walletPrompt.type {
            case .link:
                return CGSize(width: cardWidth / walletPrompt.numberOfItemsPerRow, height: walletPromptLinkCellHeight)
            default:
                let height = walletPromptSeeStoreCellHeight(walletPrompt.numberOfItemsPerRow)
                return CGSize(width: height, height: height)
            }
        }
    }
}
