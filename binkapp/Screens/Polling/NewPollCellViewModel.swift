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
            dispatchNotification(showUI: false)
            return
        }
        
        let query = collectionReference.whereField("published", isEqualTo: true )
        Current.firestoreManager.fetchDocumentsInCollection(PollModel.self, query: query, completion: { [weak self] snapshot in
            guard let self = self else { return }
            if let doc = snapshot?.first {
                self.pollData = doc
                if let poll = self.pollData {
                    let endDate = NSDate(timeIntervalSince1970: TimeInterval(poll.closeTime)) as Date
                    if self.isDateBefore(date: endDate) {
                        if let pollId = Current.userDefaults.string(forDefaultsKey: .dismissedPollId) {
                            if pollId == poll.id {
                                self.dispatchNotification(showUI: false)
                                return
                            }

                            Current.userDefaults.set("", forDefaultsKey: .dismissedPollId)
                        }

                        self.question = poll.question
                        self.dispatchNotification(showUI: true)
                    } else {
                        self.dispatchNotification(showUI: false)
                    }
                }
            } else {
                self.question = nil
                self.dispatchNotification(showUI: false)
            }
        })
    }
    
    func dismissPollPressed() {
        guard let pollId = self.pollData?.id else { return }
        
        Current.userDefaults.set(pollId, forDefaultsKey: .dismissedPollId)
        MixpanelUtility.track(.pollDismissedPermanently(pollId: pollId))
        dispatchNotification(showUI: false)
    }
    
    func remindLaterPressed() {
        guard let pollId = self.pollData?.id else { return }
        guard let remindTime = self.pollData?.remindLaterMinutes else { return }
        
        MixpanelUtility.track(.pollDismissedTemporarily(pollId: pollId))
        
        /// add the reminder time to the current date
        if let dateToCheck = Calendar.current.date(byAdding: .minute, value: remindTime, to: Date()) {
            Current.userDefaults.set(true, forDefaultsKey: .isInPollRemindPeriod)
            Current.userDefaults.set(dateToCheck, forDefaultsKey: .timeToPromptPollRemindDate)
            startRemindLaterTimer()
            dispatchNotification(showUI: false)
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
    
    private func dispatchNotification(showUI: Bool) {
        NotificationCenter.default.post(name: .displayPollInfoCell, object: nil, userInfo: ["show": showUI])
    }
}
