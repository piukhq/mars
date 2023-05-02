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
    @Published var submitted = false
    
    lazy var disabledAnswerButton: BinkButtonSwiftUIView = {
        return BinkButtonSwiftUIView(viewModel: ButtonViewModel(title: L10n.submit), enabled: false, buttonTapped: {}, type: .capsule)
    }()
    
    lazy var submitAnswerButton: BinkButtonSwiftUIView = {
        return BinkButtonSwiftUIView(viewModel: ButtonViewModel(title: L10n.submit), enabled: true, buttonTapped: { [weak self] in
            self?.submitAnswer()
        }, type: .capsule)
    }()
    
    lazy var editVoteButton: BinkButtonSwiftUIView = {
        return BinkButtonSwiftUIView(viewModel: ButtonViewModel(title: L10n.editMyVote), enabled: true, buttonTapped: { [weak self] in
            self?.currentAnswer = nil
            self?.submitted = false
            self?.gotVotes.toggle()
        }, type: .bordered)
    }()
    
    lazy var doneButton: BinkButtonSwiftUIView = {
        return BinkButtonSwiftUIView(viewModel: ButtonViewModel(title: L10n.done), enabled: true, buttonTapped: { [weak self] in
            Current.navigate.back()
        }, type: .capsule)
    }()
    
    private var votingModel: PollVotingModel?
    
    private let userId = Current.userManager.currentUserId
    
    var votesDictionary: [String: Int] = [:]
    
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
        query.getDocuments { [weak self] (snapshot, error) in
            do {
                if let doc = snapshot?.documents.first {
                    self?.votingModel = try doc.data(as: PollVotingModel.self)
                    if let answer = self?.votingModel?.answer, !answer.isEmpty {
                        self?.getVoteCount()
                        self?.submitted.toggle()
                        self?.currentAnswer = answer
                    }
                }
            } catch {
                print("Error getting documents: \(error)")
            }
        }
    }
    
    private func getVoteCount() {
        guard let collectionReference = Current.firestoreManager.getCollection(collection: .pollResults) else { return }
        guard let pollData = self.pollData else { return }
        
        let query = collectionReference.whereField("pollId", isEqualTo: pollData.id ?? "")
        query.getDocuments { [weak self] (snapshot, _) in
            for answer in pollData.answers {
                self?.votesDictionary[answer] = snapshot?.documents.filter { $0["answer"] as? String == answer }.count
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
                self?.submitted.toggle()
            }
        } else {
            votingModel = PollVotingModel(pollId: pollData?.id ?? "", userId: userId ?? "", createdDate: Int(Date().timeIntervalSince1970), overwritten: false, answer: answer)
            Current.firestoreManager.addDocument(votingModel, collection: .pollResults) { [weak self] _ in
                self?.getVoteCount()
                self?.submitted.toggle()
            }
        }
    }
    
    func getTimeToEnd() -> String {
        guard let poll = pollData else {
            return ""
        }
        
        let startDate = NSDate(timeIntervalSince1970: TimeInterval(Date().timeIntervalSince1970))
        let endDate = NSDate(timeIntervalSince1970: TimeInterval(poll.closeTime))
        
        let diffComponents = Calendar.current.dateComponents([.day, .hour, .minute, .second], from: startDate as Date, to: endDate as Date)
        let days = diffComponents.day ?? 0
        let hours = diffComponents.hour ?? 0
        let minutes = diffComponents.minute ?? 0
        let seconds = diffComponents.second ?? 0
        
        if days > 0 {
            return "\(days) days"
        } else if hours == 0 && minutes == 0 && seconds == 0 {
            return ""
        }
        
        return String(format: "%i:%i:%i", hours, minutes, seconds)
    }
    
    func votePercentage(answer: String) -> Double {
        let answerCount = Double(votesDictionary[answer] ?? 0)
        return answerCount / Double(votesTotalCount)
    }
}
