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
    
    private let userId = "7"
    
    var votesDictionary = [String: Int]()
    
    init () {
        self.getPollData()
    }
    
    var votesTotalCount: Int {
        var count = 0
        
        for value in votesDictionary.values {
            count += value
        }
        return count
    }
    
    private func getVotingData() {
        guard let collectionReference = Current.firestoreManager.getCollection(collection: .pollResults) else { return }
        guard let pollData = self.pollData else { return }
        
        let query = collectionReference.whereField("userId", isEqualTo: userId).whereField("pollId", isEqualTo: pollData.id ?? "")
        query.addSnapshotListener { [weak self] (snapshot, error) in
            do {
                if let doc = snapshot?.documents.first {
                    self?.votingModel = try doc.data(as: PollVotingModel.self)
                }
            } catch {
                print("Error getting documents: \(error)")
            }
        }
    }
    
    private func getVoteCount() {
        guard let collectionReference = Current.firestoreManager.getCollection(collection: .pollResults) else { return }
        guard let pollData = self.pollData else { return }
        
        for answer in pollData.answers {
            let query = collectionReference.whereField("pollId", isEqualTo: pollData.id ?? "").whereField("answer", isEqualTo: answer)
            query.getDocuments { [weak self] (snapshot, error) in
                print(answer)
                print(snapshot?.documents.count)
                self?.votesDictionary[answer] = snapshot?.documents.count
            }
        }
    }
    
    
    private func getPollData() {
        guard let collectionReference = Current.firestoreManager.getCollection(collection: .polls) else { return }
        
        let query = collectionReference.whereField("publishedStatus", isEqualTo: PollStatus.published.rawValue )
        query.getDocuments { [weak self] (snapshot, error) in
            do {
                if let doc = snapshot?.documents.first {
                    self?.pollData = try doc.data(as: PollModel.self)
                    self?.getVoteCount()
                    self?.getVotingData()
                }
            } catch {
                print("Error getting documents: \(error)")
            }
        }
        
        //Current.firestoreManager.test(query: .whereField("", isGreaterThan: 1))
//        Current.firestoreManager.fetchDocumentsInCollection(PollModel.self, collection: .polls) { [weak self] data in
//            if let documents = data {
//                self?.pollData = documents.first(where: { $0.publishedStatus == .published })
//            }
//
//            if let pollData = self?.pollData {
//                Current.firestoreManager.fetchDocumentsInCollection(PollVotingModel.self, collection: .pollResults) { [weak self] data in
//                    if let documents = data {
//                        self?.votingModel = documents.first(where: { $0.userId == "Ricardo" && $0.pollId == pollData.id })
//                    }
//                }
//            }
//        }
    }
    
    func setAnswer(answer: String) {
        if var model = votingModel {
            model.answer = answer
            model.overwritten = true
            Current.firestoreManager.addDocument(model, collection: .pollResults, documentId: model.id ?? "")
        } else {
            votingModel = PollVotingModel(pollId: pollData?.id ?? "", userId: userId, createdDate: Int(Date().timeIntervalSince1970), overwritten: false, answer: answer)
            Current.firestoreManager.addDocument(votingModel, collection: .pollResults) { [weak self] documentId in
                self?.votingModel?.id = documentId
            }
        }
    }
    
    func daysToEnd() -> String {
        guard let poll = pollData else {
            return "0"
        }
        
        let startDate = NSDate(timeIntervalSince1970: TimeInterval(poll.startTime))
        let endDate = NSDate(timeIntervalSince1970: TimeInterval(poll.closeTime))
        
        let days = Calendar.current.dateComponents([.day], from: startDate as Date, to: endDate as Date).day ?? 0
        return String(days)
    }
    
    func votePercentage(answer: String) -> CGFloat {
        let answerCount = CGFloat(votesDictionary[answer] ?? 0)
        return answerCount / CGFloat(votesTotalCount)
    }
}
