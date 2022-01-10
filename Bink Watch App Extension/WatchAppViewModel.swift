//
//  WatchAppViewModel.swift
//  Bink Watch App Extension
//
//  Created by Nick Farrant on 06/09/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import UIKit
import WatchConnectivity
import WatchKit

final class WatchAppViewModel: NSObject, ObservableObject, WCSessionDelegate {
    private var session: WCSession
    
    init(session: WCSession = .default) {
        self.session = session
        super.init()
        self.session.delegate = self
        session.activate()
    }
    
    @Published var cards: [WatchLoyaltyCard] = []
    @Published var hasCurrentUser = false
    @Published var didSyncWithPhoneOnLaunch = false
    @Published var noResponseFromPhone = false
    
    func getwalletData() {
        print("Session state: \(session.activationState)")
        print("Session reachability: \(session.isReachable)")

        session.sendMessage([WKSessionKey.refreshWallet: true], replyHandler: nil) { error in
            print(error.localizedDescription)
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.noResponseFromPhone = false

            if let hasCurrentUser = message[WKSessionKey.hasCurrentUser] as? Bool {
                self.hasCurrentUser = hasCurrentUser
                self.didSyncWithPhoneOnLaunch = true
                return
            }
            
            if let cardToAddDict = message[WKSessionKey.addCard] as? [String: Any] {
                if let newCard = try? WatchLoyaltyCard(dictionary: cardToAddDict) {
                    self.cards.insert(newCard, at: 0)
                    return
                }
            }
            
            if let barcode = message[WKSessionKey.deleteCard] as? String, let indexToDelete = self.cards.firstIndex(where: { $0.id == barcode }) {
                self.cards.remove(at: indexToDelete)
                return
            }
            
            if let imageDict = message[WKSessionKey.iconImage] as? [String: Any] {
                if let watchLoyaltyCardIcon = try? WatchLoyaltyCardIcon(dictionary: imageDict) {
                    for (i, var card) in self.cards.enumerated() {
                        if card.id == watchLoyaltyCardIcon.id {
                            card.iconImageData = watchLoyaltyCardIcon.imageData
                            self.cards[i] = card
                        }
                    }
                    return
                }
            }

            guard let cardDictsFromMessage = message[WKSessionKey.refreshWallet] as? [[String: Any]] else { return }
            
            self.cards = cardDictsFromMessage.map({ loyaltyCardDict in
                if var loyaltyCard = try? WatchLoyaltyCard(dictionary: loyaltyCardDict) {
                    let icon = self.cards.first(where: { $0.id == loyaltyCard.id })
                    loyaltyCard.iconImageData = icon?.iconImageData
                    return loyaltyCard
                }
                return nil
            })
            .compactMap({ $0 })
            
            /// If we receive cards, we know we are on the wallet, we know we are logged in
            self.hasCurrentUser = true
            self.didSyncWithPhoneOnLaunch = true
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("Watch: Session did activate: \(activationState)")
        guard activationState == .activated else { return }
        getwalletData()
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        print("Watch: reachability did change: \(session.isReachable)")
        if session.isReachable {
            getwalletData()
        }
    }
}

extension Decodable {
    init(dictionary: [String: Any]) throws {
        let decoder = JSONDecoder()
        let data = try JSONSerialization.data(withJSONObject: dictionary, options: [])
        self = try decoder.decode(Self.self, from: data)
    }
}
