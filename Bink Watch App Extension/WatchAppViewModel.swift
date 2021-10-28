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
    
    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if let transferComplete = message["transfer_complete"] as? Bool, transferComplete {
                self.cards = self.loyaltyCards
                print(self.cards)
                self.loyaltyCards = []
                return
            }
//        print(message)
            guard let cardDictsFromMessage = message["message"] as? [String: Any] else {
                print("ERRRRRRRRRRROR")
                print(message["message"] as Any)
                return
            }
//            print(cardDictsFromMessage)
            
            if let card = try? WatchLoyaltyCard(dictionary: cardDictsFromMessage) {
                self.loyaltyCards.append(card)
            }

//            self.cards = cardDictsFromMessage.map { try? WatchLoyaltyCard(dictionary: $0) }.compactMap { $0 }
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
