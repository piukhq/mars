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
    var votingModel: PollVotingModel?
    
    init () {
        self.getPollData()
    }
    
    private func getPollData() {
        Current.firestoreManager.fetchDocument(PollModel.self, collection: "polls", documentId: "ocucW1dmZJOqsdgQJ1Qu") { [weak self] data in
            if let validData = data {
                self?.pollData = validData
                
                Current.firestoreManager.fetchDocumentsInCollection(PollVotingModel.self, collection: "pollResults") { [weak self] data in
                    if let documents = data {
                        self?.votingModel = documents.first(where: { $0.userId == "Ricardo" && $0.pollId == self?.pollData?.id })
                    }
                }
            }
            
            //let vote = PollVotingModel(pollId: "ocucW1dmZJOqsdgQJ1Qu", userId: "Ricardo", createdDate: Int(Date().timeIntervalSince1970), overwritten: false, answer: "Test")
            //Current.firestoreManager.addDocument(vote, collection: "pollResults")
        }
    }
    
    func setAnswer(answer: String) {
        if var model = votingModel {
            model.answer = answer
            Current.firestoreManager.addDocument(model, collection: "pollResults")
        } else {
            votingModel = PollVotingModel(pollId: pollData?.id ?? "", userId: "Ricardo", createdDate: Int(Date().timeIntervalSince1970), overwritten: false, answer: answer)
            Current.firestoreManager.addDocument(votingModel, collection: "pollResults") { [weak self] documentId in
                self?.votingModel?.id = documentId
            }
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
