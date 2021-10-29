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
    func sendWalletCardsToWatch(membershipCards: [CD_MembershipCard]?) {
        if WCSession.default.isReachable {
            guard let membershipCards = membershipCards else { return }
            
            for (i, card) in membershipCards.enumerated() {
                print(card.membershipPlan?.account?.companyName as Any)
                let barcodeViewModel = BarcodeViewModel(membershipCard: card)
                if let barcodeImageData = barcodeViewModel.barcodeImage(withSize: CGSize(width: 200, height: 200))?.pngData() {
                    /// If we have a barcode, send loyalty card to watch
                    guard let membershipPlan = card.membershipPlan else { return }
                    let iconImageData = ImageService.getImageFromDevice(forPathType: .membershipPlanIcon(plan: membershipPlan))?.pngData()
                    
                    let walletCardViewModel = WalletLoyaltyCardCellViewModel(membershipCard: card)
                    let balanceString = "\(walletCardViewModel.pointsValueText ?? "") \(walletCardViewModel.pointsValueSuffixText ?? "")"
                    
                    if let object = WatchLoyaltyCard(id: card.card?.barcode ?? "", companyName: membershipPlan.account?.companyName ?? "", iconImageData: iconImageData, barcodeImageData: barcodeImageData, balanceString: balanceString).dictionary {
                        print("Appending to dict")

                        WCSession.default.sendMessage(["message": object], replyHandler: nil)
                    }
                }
                
                if i == membershipCards.count - 1 {
                    WCSession.default.sendMessage(["transfer_complete": true], replyHandler: nil) { error in
                        print(error.localizedDescription)
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
}
