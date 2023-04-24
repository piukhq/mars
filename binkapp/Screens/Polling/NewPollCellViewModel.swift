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
    var pollData: PollModel?
    
    private let reminderInterval = 60.0
    
    init () {
        self.startRemindLaterTimer()
        self.getPollData()
    }
    
    private func getPollData() {
        guard let collectionReference = Current.firestoreManager.getCollection(collection: .polls) else { return }
        
        guard Current.userDefaults.bool(forDefaultsKey: .isInPollRemindPeriod) == false else {
            NotificationCenter.default.post(name: .displayPollInfoCell, object: nil, userInfo: ["show": false])
            return
        }
        
        let query = collectionReference.whereField("publishedStatus", isEqualTo: PollStatus.published.rawValue )
        query.addSnapshotListener { [weak self] (snapshot, error) in
            do {
                guard let self = self else { return }
                
                if let doc = snapshot?.documents.first {
                    self.pollData = try doc.data(as: PollModel.self)
                    if let poll = self.pollData {
                        let endDate = NSDate(timeIntervalSince1970: TimeInterval(poll.closeTime)) as Date
                        if self.isDateBefore(date: endDate) {
                            if let pollId = Current.userDefaults.string(forDefaultsKey: .dismissedPollId) {
                                if pollId == poll.id {
                                    DispatchQueue.main.async {
                                        NotificationCenter.default.post(name: .displayPollInfoCell, object: nil, userInfo: ["show": false])
                                    }
                                    return
                                }
                                
                                Current.userDefaults.set("", forDefaultsKey: .dismissedPollId)
                            }
                            
                            self.question = poll.question
                            DispatchQueue.main.async {
                                NotificationCenter.default.post(name: .displayPollInfoCell, object: nil, userInfo: ["show": true])
                            }
                        } else {
                            DispatchQueue.main.async {
                                NotificationCenter.default.post(name: .displayPollInfoCell, object: nil, userInfo: ["show": false])
                            }
                        }
                    }
                } else {
                    self.question = nil
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: .displayPollInfoCell, object: nil, userInfo: ["show": false])
                    }
                }
            } catch {
                print("Error getting documents: \(error)")
            }
        }
    }
    
    func dismissPollPressed() {
        guard let pollId = self.pollData?.id else { return }
        
        Current.userDefaults.set(pollId, forDefaultsKey: .dismissedPollId)
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .displayPollInfoCell, object: nil, userInfo: ["show": false])
        }
    }
    
    func remindLaterPressed() {
        guard let remindTime = self.pollData?.remindLaterMinutes else { return }
        
        /// add the reminder time to the current date
        if let dateToCheck = Calendar.current.date(byAdding: .minute, value: remindTime, to: Date()) {
            Current.userDefaults.set(true, forDefaultsKey: .isInPollRemindPeriod)
            Current.userDefaults.set(dateToCheck, forDefaultsKey: .timeToPromptPollRemindDate)
            startRemindLaterTimer()
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .displayPollInfoCell, object: nil, userInfo: ["show": false])
            }
        }
    }
    
    private func startRemindLaterTimer() {
        if let dateToCheck = Current.userDefaults.value(forDefaultsKey: .timeToPromptPollRemindDate) as? Date {
            if isDateBefore(date: dateToCheck) {
                let timer = Timer.scheduledTimer(withTimeInterval: reminderInterval, repeats: true) { timer in
                    print("Timer fired!")

                    /// if we passed the time diff we can show the poll cell again
                    if !self.isDateBefore(date: dateToCheck) {
                        timer.invalidate()
                        Current.userDefaults.set(false, forDefaultsKey: .isInPollRemindPeriod)
                        self.getPollData()
                    }
                }

                RunLoop.current.add(timer, forMode: .common)
            } else {
                Current.userDefaults.set(false, forDefaultsKey: .isInPollRemindPeriod)
            }
        } else {
            Current.userDefaults.set(false, forDefaultsKey: .isInPollRemindPeriod)
        }
    }
    
    private func isDateBefore(date: Date) -> Bool {
        return Date().isBefore(date: date, toGranularity: .minute)
    }
    
    func displayPollOptions() {
        let vc = ViewControllerFactory.makePollManagementAlertViewController( remindLaterHandler: {
            self.remindLaterPressed()
        }, dontShowAgainHandler: {
            self.dismissPollPressed()
        })
        
        let navigationRequest = AlertNavigationRequest(alertController: vc, completion: nil)
        Current.navigate.to(navigationRequest)
    }
}
