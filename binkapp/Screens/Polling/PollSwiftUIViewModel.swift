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
    @Published var currentAnswer: String?
    @Published var gotVotes = false
    
    var votingModel: PollVotingModel?
    
    private let userId = Current.userManager.currentUserId
    
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
        
        let query = collectionReference.whereField("userId", isEqualTo: userId ?? "").whereField("pollId", isEqualTo: pollData.id ?? "")
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
        /*
        for answer in pollData.answers {
            let query = collectionReference.whereField("pollId", isEqualTo: pollData.id ?? "").whereField("answer", isEqualTo: answer)
            query.getDocuments { [weak self] (snapshot, _) in
                self?.votesDictionary[answer] = snapshot?.documents.count
            }
        }
         */
        
        let query = collectionReference.whereField("pollId", isEqualTo: pollData.id ?? "")
        query.getDocuments { [weak self] (snapshot, _) in
            for answer in pollData.answers {
                self?.votesDictionary[answer] = snapshot?.documents.filter { $0["answer"] as? String == answer }.count
                print(answer + "\(self?.votesDictionary[answer])")
            }
            self?.gotVotes.toggle()
        }
    }
    
    
    private func getPollData() {
        guard let collectionReference = Current.firestoreManager.getCollection(collection: .polls) else { return }
        
        let query = collectionReference.whereField("publishedStatus", isEqualTo: PollStatus.published.rawValue )
        query.addSnapshotListener { [weak self] (snapshot, error) in
            do {
                if let doc = snapshot?.documents.first {
                    self?.pollData = try doc.data(as: PollModel.self)
                    //self?.getVoteCount()
                    self?.getVotingData()
                }
            } catch {
                print("Error getting documents: \(error)")
            }
        }
    }
    
    func setCurrentAnswer(answer: String) {
        currentAnswer = answer
    }
    
    func submitAnswer() {
        guard let answer = currentAnswer else { return }
        
        if var model = votingModel {
            model.answer = answer
            model.overwritten = true
            Current.firestoreManager.addDocument(model, collection: .pollResults, documentId: model.id ?? "") { [weak self] _ in
                self?.getVoteCount()
            }
        } else {
            votingModel = PollVotingModel(pollId: pollData?.id ?? "", userId: userId ?? "", createdDate: Int(Date().timeIntervalSince1970), overwritten: false, answer: answer)
            Current.firestoreManager.addDocument(votingModel, collection: .pollResults) { [weak self] _ in
                self?.getVoteCount()
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
    
    func votePercentage(answer: String) -> Double {
        let answerCount = Double(votesDictionary[answer] ?? 0)
        return answerCount / Double(votesTotalCount)
    }
}
