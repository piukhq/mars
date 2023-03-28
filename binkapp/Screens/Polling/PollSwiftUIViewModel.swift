//
//  PollSwiftUIViewModel.swift
//  binkapp
//
//  Created by Ricardo Silva on 28/03/2023.
//  Copyright © 2023 Bink. All rights reserved.
//

import Foundation
import FirebaseFirestore

class PollSwiftUIViewModel: ObservableObject {
    @Published var pollData: PollModel?
    
    init () {
        self.fetchPoll(documentId: "ocucW1dmZJOqsdgQJ1Qu")
    }
    
    private func fetchPoll(documentId: String) {
        let db = Firestore.firestore()
        let docRef = db.collection("polls").document(documentId)
        
        docRef.getDocument(as: PollModel.self) { [weak self] result in
            switch result {
            case .success(let poll):
                print(poll)
                //self?.addVoting()
                self?.pollData = poll
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func addVoting() {
        let db = Firestore.firestore()
        let collectionRef = db.collection("pollResults")
        do {
            let vote = PollVotingModel(pollId: "ocucW1dmZJOqsdgQJ1Qu", userId: UUID().uuidString, createdDate: Int(Date().timeIntervalSince1970), overwritten: false, answer: "Apple")
            let newDocReference = try collectionRef.addDocument(from: vote)
            print("Voting stored with new document reference: \(newDocReference)")
        } catch {
            print(error)
        }
    }
    
    func daysToEnd() -> String {
        guard let poll = pollData else {
            return "0"
        }
        
        var startDate = NSDate(timeIntervalSince1970: TimeInterval(poll.startTime))
        var endDate = NSDate(timeIntervalSince1970: TimeInterval(poll.closeTime))
        
        let days = Calendar.current.dateComponents([.day], from: startDate as Date, to: endDate as Date).day ?? 0
        return String(days)
    }
}
