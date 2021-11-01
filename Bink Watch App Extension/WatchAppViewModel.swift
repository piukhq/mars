//
//  WatchAppViewModel.swift
//  Bink Watch App Extension
//
//  Created by Nick Farrant on 06/09/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import UIKit
import WatchConnectivity

final class WatchAppViewModel: NSObject, ObservableObject, WCSessionDelegate {
    var session: WCSession
    
    init(session: WCSession = .default) {
        self.session = session
        super.init()
        self.session.delegate = self
        session.activate()
    }
    
    @Published var cards: [WatchLoyaltyCard] = []
    var loyaltyCards: [WatchLoyaltyCard] = [] {
        didSet {
            print("Cards count: \(loyaltyCards.count)")
        }
    }
    
//    var loyaltyCardIcons: [WatchLoyaltyCardIcon] = []
    
    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            if let cardToAddDict = message["add_card"] as? [String: Any] {
                if let newCard = try? WatchLoyaltyCard(dictionary: cardToAddDict) {
                    self.cards.insert(newCard, at: 0)
                    return
                }
            }
            
            if let barcode = message["delete_card"] as? String, let indexToDelete = self.cards.firstIndex(where: { $0.id == barcode }) {
                self.cards.remove(at: indexToDelete)
                return
            }
            
//            if let transferComplete = message["transfer_complete"] as? Bool, transferComplete {
//                self.cards = self.loyaltyCards
//                print(self.cards)
//                self.loyaltyCards = []
//                return
//            }
            
            if let imageDict = message["icon_image"] as? [String: Any] {
                if let watchLoyaltyCardIcon = try? WatchLoyaltyCardIcon(dictionary: imageDict) {
                    print("Got icon: \(watchLoyaltyCardIcon.id)")
//                    self.loyaltyCardIcons.append(watchLoyaltyCardIcon)
                    
                    for (i, var card) in self.cards.enumerated() {
                        if card.id == watchLoyaltyCardIcon.id {
                            card.iconImageData = watchLoyaltyCardIcon.imageData
                            self.cards[i] = card
                        }
                    }
                    return
                }
            }

            guard let cardDictsFromMessage = message["refresh_wallet"] as? [[String: Any]] else {
                print("ERRRRRRRRRRROR")
                print(message["message"] as Any)
                return
            }
            
//            self.cards = cardDictsFromMessage.map({ try? WatchLoyaltyCard(dictionary: $0) }).compactMap({ $0 })
            
            self.cards = cardDictsFromMessage.map({ loyaltyCardDict in
                if var loyaltyCard = try? WatchLoyaltyCard(dictionary: loyaltyCardDict) {
                    let icon = self.cards.first(where: { $0.id == loyaltyCard.id })
                    loyaltyCard.iconImageData = icon?.iconImageData
                    return loyaltyCard
                }
                return nil
            })
                .compactMap({ $0 })
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}
}

extension Decodable {
    init(dictionary: [String: Any]) throws {
        let decoder = JSONDecoder()
        let data = try JSONSerialization.data(withJSONObject: dictionary, options: [])
        self = try decoder.decode(Self.self, from: data)
    }
}
