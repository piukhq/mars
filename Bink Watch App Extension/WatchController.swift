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
    func sendWalletCardsToWatch(membershipCards: [CD_MembershipCard]?, completion: EmptyCompletionBlock? = nil) {
        var watchLoyaltyCardsDictArray: [[String: Any]] = []
        
        if WCSession.default.isReachable {
            guard let membershipCards = membershipCards else { return }
            
            for card in membershipCards {
                let barcodeViewModel = BarcodeViewModel(membershipCard: card)
                if let barcodeImageData = barcodeViewModel.barcodeImage(withSize: CGSize(width: 200, height: 200))?.pngData() {
                    /// If we have a barcode, send loyalty card to watch
                    guard let membershipPlan = card.membershipPlan else { return }
                    let walletCardViewModel = WalletLoyaltyCardCellViewModel(membershipCard: card)
                    var balanceString: String?
                    if walletCardViewModel.balance != nil {
                        balanceString = "\(walletCardViewModel.pointsValueText ?? "") \(walletCardViewModel.pointsValueSuffixText ?? "")"
                    }
                    
                    if let watchLoyaltyCardsDict = WatchLoyaltyCard(id: card.card?.barcode ?? "", companyName: membershipPlan.account?.companyName ?? "", iconImageData: nil, barcodeImageData: barcodeImageData, balanceString: balanceString).dictionary {
                        watchLoyaltyCardsDictArray.append(watchLoyaltyCardsDict)
                    }
                }
            }
            
            WCSession.default.sendMessage(["refresh_wallet": watchLoyaltyCardsDictArray], replyHandler: nil)
            completion?()

            for card in membershipCards {
                guard let plan = card.membershipPlan else { return }
                
                ImageService.getImage(forPathType: .membershipPlanIcon(plan: plan), traitCollection: nil) { retrievedImage in
                    if let imageDict = WatchLoyaltyCardIcon(id: card.card?.barcode ?? "", imageData: retrievedImage?.pngData()).dictionary {
                        WCSession.default.sendMessage(["icon_image": imageDict], replyHandler: nil)
                    }
                }
            }
        }
    }
    
    func addLoyaltyCardToWatch(_ membershipCard: CD_MembershipCard) {
        if WCSession.default.isReachable {
            let barcodeViewModel = BarcodeViewModel(membershipCard: membershipCard)
            if let barcodeImageData = barcodeViewModel.barcodeImage(withSize: CGSize(width: 200, height: 200))?.pngData() {
                guard let membershipPlan = membershipCard.membershipPlan else { return }
                let iconImageData = ImageService.getImageFromDevice(forPathType: .membershipPlanIcon(plan: membershipPlan))?.pngData()
                
                let walletCardViewModel = WalletLoyaltyCardCellViewModel(membershipCard: membershipCard)
                let balanceString = "\(walletCardViewModel.pointsValueText ?? "") \(walletCardViewModel.pointsValueSuffixText ?? "")"
                
                if let object = WatchLoyaltyCard(id: membershipCard.card?.barcode ?? "", companyName: membershipPlan.account?.companyName ?? "", iconImageData: iconImageData, barcodeImageData: barcodeImageData, balanceString: balanceString).dictionary {
                    WCSession.default.sendMessage(["add_card": object], replyHandler: nil)
                }
            }
        }
    }
    
    func deleteLoyaltyCardFromWatch(barcode: String) {
        if WCSession.default.isReachable {
            WCSession.default.sendMessage(["delete_card": barcode], replyHandler: nil)
        }
    }
    
    func hasCurrentUser(_ hasUser: Bool) {
        if WCSession.default.isReachable {
            WCSession.default.sendMessage(["has_current_user": hasUser], replyHandler: nil) { error in
                print(error.localizedDescription)
            }
        }
    }
}

// MOVE >>>>>>>>>
extension Encodable {
    var dictionary: [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
    }
}
