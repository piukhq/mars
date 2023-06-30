//
//  PollSwiftUIViewModel.swift
//  binkapp
//
//  Created by Ricardo Silva on 28/03/2023.
//  Copyright © 2023 Bink. All rights reserved.
//

import Foundation
import SwiftUI
import FirebaseFirestore

class PollSwiftUIViewModel: ObservableObject {
    @Published var pollData: PollModel?
    @Published var currentAnswer: String?
    @Published var customAnswer: String?
    @Published var gotVotes = false
    @Published var submitted = false
    @Published var canEditVote = false
    
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
            self?.editVotePressed()
        }, type: .bordered)
    }()
    
    lazy var doneButton: BinkButtonSwiftUIView = {
        return BinkButtonSwiftUIView(viewModel: ButtonViewModel(title: L10n.done), enabled: true, buttonTapped: { [weak self] in
            Current.navigate.back()
        }, type: .capsule)
    }()
    
    var shouldDisplayCustomAnswer: Bool {
        if pollData?.allowCustomAnswer == true {
            if submitted && customAnswer == nil {
                return false
            }
            return true
        }
        
        return false
    }
    
    var votingModel: PollVotingModel?
    
    private let userId = Current.userManager.currentUserId
    
    private var votesDictionary: [String: Int] = [:]
    
    var firestoreManager: FirestoreProtocol
    
    init (firestoreManager: FirestoreProtocol) {
        self.firestoreManager = firestoreManager
        self.getPollData()
    }
    
    private var votesTotalCount: Int {
        return votesDictionary.values.reduce(0, +)
    }
    
    private func getVotingData() {
        guard let pollData = self.pollData else { return }
        
        let collectionReference = firestoreManager.getCollection(collection: .pollResults)
        let query = collectionReference?.whereField("userId", isEqualTo: userId ?? "").whereField("pollId", isEqualTo: pollData.id ?? "")
        firestoreManager.fetchDocumentsInCollection(PollVotingModel.self, query: query, completion: { [weak self] snapshot in
            if let doc = snapshot?.first {
                if self?.votingModel != nil {
                    self?.votingModel?.id = doc.id
                    return
                }
                
                self?.votingModel = doc
                if let answer = self?.votingModel?.answer, !answer.isEmpty {
                    self?.getVoteCount()
                    self?.submitted.toggle()
                    self?.currentAnswer = answer
                } else if let customAnswer = self?.votingModel?.customAnswer, !customAnswer.isEmpty {
                    self?.getVoteCount()
                    self?.submitted.toggle()
                    self?.customAnswer = customAnswer
                }
            }
        })
    }
    
    private func getVoteCount() {
        guard let pollData = self.pollData else { return }
        
        let collectionReference = firestoreManager.getCollection(collection: .pollResults)
        let query = collectionReference?.whereField("pollId", isEqualTo: pollData.id ?? "")
        
        firestoreManager.getDocuments(PollVotingModel.self, query: query, completion: { [weak self] snapshot in
            for answer in pollData.answers {
                self?.votesDictionary[answer] = snapshot?.filter { $0.answer == answer }.count
            }
            self?.gotVotes.toggle()
        })
        
        checkIfCanEditVote()
    }
    
    func checkIfCanEditVote() {
        guard let pollData = pollData else { return }
        guard let model = votingModel else { return }
        
        let createdDate = Date(timeIntervalSince1970: TimeInterval(model.createdDate))
        canEditVote = !Date.hasElapsed(minutes: ((pollData.editTimeLimit ?? 0) % 3600) / 60, since: createdDate)
    }
    
    
    private func getPollData() {
        let collectionReference = firestoreManager.getCollection(collection: .polls)
        
        let query = collectionReference?.whereField("published", isEqualTo: true )

        firestoreManager.fetchDocumentsInCollection(PollModel.self, query: query, completion: { [weak self] snapshot in
            if let doc = snapshot?.first {
                self?.pollData = doc
                print(doc)
                self?.getVotingData()
                if let pollId = self?.pollData?.id {
                    MixpanelUtility.track(.pollClicked(pollId: pollId))
                }
            }
        })
    }
    
    func editVotePressed() {
        if let modelId = votingModel?.id {
            firestoreManager.deleteDocument(collection: .pollResults, documentId: modelId) { [weak self] success in
                if success {
                    self?.votingModel = nil
                    self?.currentAnswer = nil
                    self?.customAnswer = nil
                    self?.submitted = false
                    self?.gotVotes.toggle()
                }
            }
        }
    }
    
    func submitAnswer() {
        let answer = currentAnswer ?? ""
        let customAnswer = customAnswer ?? ""
        
        submitted.toggle()
        
        votingModel = PollVotingModel(pollId: pollData?.id ?? "", userId: userId ?? "", createdDate: Int(Date().timeIntervalSince1970), overwritten: false, answer: answer, customAnswer: customAnswer)
        firestoreManager.addDocument(votingModel, collection: .pollResults, documentId: nil) { [weak self] _ in
            self?.getVoteCount()
        }
    }
    
    func getTimeToEnd() -> String {
        guard let poll = pollData else {
            return ""
        }

        let endDate = NSDate(timeIntervalSince1970: TimeInterval(poll.closeTime))
        
        let diffComponents = Calendar.current.dateComponents([.day, .hour, .minute, .second], from: Date(), to: endDate as Date)
        let days = diffComponents.day ?? 0
        let hours = diffComponents.hour ?? 0
        let minutes = diffComponents.minute ?? 0
        let seconds = diffComponents.second ?? 0
        
        if days > 0 {
            return "\(days) days"
        } else if hours == 0 && minutes == 0 && seconds == 0 {
            return ""
        }
        
        return String(format: "%02i:%02i:%02i", hours, minutes, seconds)
    }
    
    func votePercentage(answer: String) -> Double {
        let answerCount = Double(votesDictionary[answer] ?? 0)
        return answerCount / Double(votesTotalCount)
    }
    
    func customAnswerIsValid() -> Bool {
        guard let answer = customAnswer else {
            return false
        }

        return !answer.isEmpty
    }

    func colorForOuterCircleIcons(colorScheme: ColorScheme) -> Color {
        switch Current.themeManager.currentTheme.type {
        case .system:
            switch colorScheme {
            case .light:
                return  .gray
            case .dark:
                return .white
            @unknown default:
                return .white
        }
        case .light:
            return .gray
        case .dark:
            return .white
        }
    }
    
    func colorForAnsweredRow(colorScheme: ColorScheme) -> Color {
        switch Current.themeManager.currentTheme.type {
        case .system:
            switch colorScheme {
            case .light:
                return Color(.percentageGreen)
            case .dark:
                return Color(UIColor.binkBlue)
            @unknown default:
                return Color(UIColor.binkBlue)
        }
        case .light:
            return Color(.percentageGreen)
        case .dark:
            return Color(UIColor.binkBlue)
        }
    }
    
    func colorForUnansweredRow(colorScheme: ColorScheme) -> Color {
        switch Current.themeManager.currentTheme.type {
        case .system:
            switch colorScheme {
            case .light:
                return Color(.unansweredRowGreen)
            case .dark:
                return Color(.unansweredRowDarkBlue)
            @unknown default:
                return Color(.unansweredRowDarkBlue)
        }
        case .light:
            return Color(.unansweredRowGreen)
        case .dark:
            return Color(.unansweredRowDarkBlue)
        }
    }
}
