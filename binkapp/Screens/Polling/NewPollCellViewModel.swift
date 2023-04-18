//
//  NewPollCellViewModel.swift
//  binkapp
//
//  Created by Ricardo Silva on 18/04/2023.
//  Copyright © 2023 Bink. All rights reserved.
//

import Foundation
import FirebaseFirestore

class NewPollCellViewModel: ObservableObject {
    @Published var question: String?
    
    init () {
        self.getPollData()
    }
    
    private func getPollData() {
        guard let collectionReference = Current.firestoreManager.getCollection(collection: .polls) else { return }
        
        let query = collectionReference.whereField("publishedStatus", isEqualTo: PollStatus.published.rawValue )
        query.addSnapshotListener { [weak self] (snapshot, error) in
            do {
                if let doc = snapshot?.documents.first {
                    let pollData = try doc.data(as: PollModel.self)
                    self?.question = pollData.question
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: Notification.Name("test"), object: nil, userInfo: ["show": true])
                    }
                } else {
                    self?.question = nil
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: Notification.Name("test"), object: nil, userInfo: ["show": false])
                    }
                }
            } catch {
                print("Error getting documents: \(error)")
            }
        }
    }
}
