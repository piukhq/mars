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
            var cardsDictArray: [[String: Any]] = []
            
            for card in membershipCards {
                print(card.membershipPlan?.account?.companyName as Any)
                let barcodeViewModel = BarcodeViewModel(membershipCard: card)
                guard let barcodeImageData = barcodeViewModel.barcodeImage(withSize: CGSize(width: 200, height: 200))?.pngData() else { return }
                
                guard let membershipPlan = card.membershipPlan else { return }
                let iconImageData = ImageService.getImageFromDevice(forPathType: .membershipPlanIcon(plan: membershipPlan))?.pngData()
                
                let walletCardViewModel = WalletLoyaltyCardCellViewModel(membershipCard: card)
                let balanceString = "\(walletCardViewModel.pointsValueText ?? "") \(walletCardViewModel.pointsValueSuffixText ?? "")"
                print("Balance: \(balanceString)")
                
                if let object = WatchLoyaltyCard(id: card.card?.barcode ?? "", companyName: membershipPlan.account?.companyName ?? "", iconImageData: iconImageData, barcodeImageData: barcodeImageData, balanceString: balanceString).dictionary {
                    print("Appending to dict")
                    cardsDictArray.append(object)
                }
            }
            
            print(cardsDictArray.count)
            print(cardsDictArray)
            WCSession.default.sendMessage(["message": cardsDictArray], replyHandler: nil)
        }
    }
}
