//
//  WatchController.swift
//  binkapp
//
//  Created by Sean Williams on 27/10/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import UIKit
import WatchConnectivity

class WatchController {
    let session = WCSession.default
    var watchRefreshRequired = true

    func sendMembershipCardsToWatch(completion: EmptyCompletionBlock? = nil) {
        guard Current.userManager.hasCurrentUser else {
            hasCurrentUser(false)
            return
        }
        
        var watchLoyaltyCardsDictArray: [[String: Any]] = []
        
        if session.isReachable && watchRefreshRequired {
            guard let membershipCards = Current.wallet.membershipCards else { return }
            
            for card in membershipCards {
                /// If we have a barcode, send loyalty card to watch
                let barcodeViewModel = BarcodeViewModel(membershipCard: card)
                if let _ = barcodeViewModel.barcodeImage(withSize: CGSize(width: 200, height: 200))?.pngData() {
                    guard let membershipPlan = card.membershipPlan else { return }
                    let walletCardViewModel = WalletLoyaltyCardCellViewModel(membershipCard: card)
                    var balanceString: String?
                    if walletCardViewModel.balance != nil {
                        balanceString = "\(walletCardViewModel.pointsValueText ?? "") \(walletCardViewModel.pointsValueSuffixText ?? "")"
                    }
                    
                    if let watchLoyaltyCardsDict = WatchLoyaltyCard(id: card.card?.barcode ?? "", companyName: membershipPlan.account?.companyName ?? "", iconImageData: nil, barcodeImageData: nil, balanceString: balanceString).dictionary {
                        watchLoyaltyCardsDictArray.append(watchLoyaltyCardsDict)
                    }
                }
            }
            
            session.sendMessage([WKSessionKey.refreshWallet: watchLoyaltyCardsDictArray], replyHandler: nil) { error in
                print(error.localizedDescription)
            }
            completion?()
            watchRefreshRequired = false

            for card in membershipCards {
                guard let plan = card.membershipPlan else { return }
                
                ImageService.getImage(forPathType: .membershipPlanIcon(plan: plan), traitCollection: nil) { [weak self] retrievedImage in
                    let barcodeViewModel = BarcodeViewModel(membershipCard: card)
                    let barcodeImageData = barcodeViewModel.barcodeImage(withSize: CGSize(width: 200, height: 200))?.pngData()
                    
                    if let imageDict = WatchLoyaltyCardImageData(id: card.card?.barcode ?? "", iconImageData: retrievedImage?.pngData(), barcodeImageData: barcodeImageData).dictionary {
                        self?.session.sendMessage([WKSessionKey.iconImage: imageDict], replyHandler: nil, errorHandler: { error in
                            print("Images: \(error.localizedDescription)")
                        })
                    }
                }
            }
        }
    }
    
    func addLoyaltyCardToWatch(_ membershipCard: CD_MembershipCard) {
        if session.isReachable {
            let barcodeViewModel = BarcodeViewModel(membershipCard: membershipCard)
            if let barcodeImageData = barcodeViewModel.barcodeImage(withSize: CGSize(width: 200, height: 200))?.pngData() {
                guard let membershipPlan = membershipCard.membershipPlan else { return }
                let iconImageData = ImageService.getImageFromDevice(forPathType: .membershipPlanIcon(plan: membershipPlan))?.pngData()
                
                let walletCardViewModel = WalletLoyaltyCardCellViewModel(membershipCard: membershipCard)
                let balanceString = "\(walletCardViewModel.pointsValueText ?? "") \(walletCardViewModel.pointsValueSuffixText ?? "")"
                
                if let object = WatchLoyaltyCard(id: membershipCard.card?.barcode ?? "", companyName: membershipPlan.account?.companyName ?? "", iconImageData: iconImageData, barcodeImageData: barcodeImageData, balanceString: balanceString).dictionary {
                    session.sendMessage([WKSessionKey.addCard: object], replyHandler: nil)
                    watchRefreshRequired = true
                }
            }
        }
    }
    
    func deleteLoyaltyCardFromWatch(barcode: String) {
        if session.isReachable {
            session.sendMessage([WKSessionKey.deleteCard: barcode], replyHandler: nil)
            watchRefreshRequired = true
        }
    }
    
    func hasCurrentUser(_ hasUser: Bool, completion: EmptyCompletionBlock? = nil) {
        if session.isReachable {
            session.sendMessage([WKSessionKey.hasCurrentUser: hasUser], replyHandler: nil)
            completion?()
        }
    }
}

extension Encodable {
    var dictionary: [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
    }
}
