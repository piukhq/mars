//
//  PollSwiftUIViewModelTests.swift
//  binkappTests
//
//  Created by Ricardo Silva on 21/06/2023.
//  Copyright © 2023 Bink. All rights reserved.
//

import XCTest
@testable import binkapp

import SwiftUI
import FirebaseFirestore

// swiftlint:disable all

final class PollSwiftUIViewModelTests: XCTestCase {
    
    var sut = PollSwiftUIViewModel(firestoreManager: FirestoreMock())

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_pollDataIsValid() throws {
        XCTAssertNotNil(sut.pollData)
    }

    func test_votingDataIsValid() throws {
        XCTAssertNotNil(sut.votingModel)
    }
    
    func test_votePercentageIsCorrect() throws {
        XCTAssertEqual(sut.votePercentage(answer: "Nandos"), 1.0)
    }
    
    func test_editPressed_variablesSetupCorrectly() throws {
        sut.editVotePressed()
        XCTAssertNil(sut.votingModel)
        XCTAssertNil(sut.currentAnswer)
        XCTAssertNil(sut.customAnswer)
        XCTAssertFalse(sut.submitted)
    }
    
    func test_answerSubmittedCorrectly() throws {
        sut.currentAnswer = "KFC"
        
        sut.submitAnswer()
        
        XCTAssertEqual(sut.votingModel?.answer, "KFC")
    }

    func test_canEdit_shouldbeFalse() throws {
        sut.checkIfCanEditVote()
        
        XCTAssertEqual(sut.canEditVote, false)
    }

    func test_timeToEnd_shouldbeDays() throws {
        let components = DateComponents(day: 2, hour: 2)
        let expirationDate = Calendar.current.date(byAdding: components, to: Date(), wrappingComponents: false)
        
        sut.pollData!.closeTime = Int(expirationDate!.timeIntervalSince1970)
        
        XCTAssertEqual(sut.getTimeToEnd(), "2 days")
    }
    
    func test_timeToEnd_shouldbeLongTimer() throws {
        let components = DateComponents(hour: 2, minute: 2, second: 2)
        //components.setValue(2, for: .hour)
        let expirationDate = Calendar.current.date(byAdding: components, to: Date(), wrappingComponents: false)
        
        sut.pollData!.closeTime = Int(expirationDate!.timeIntervalSince1970)
        
        XCTAssertTrue(sut.getTimeToEnd().contains("02:02:"))
    }
    
    func test_colorForAnsweredRowIsCorrect() throws {
        XCTAssertEqual(sut.colorForAnsweredRow(colorScheme: .light), Color(.percentageGreen))
        //XCTAssertEqual(sut.colorForAnsweredRow(colorScheme: .dark), Color(UIColor.binkBlue))
    }
    
    func test_colorForUnansweredRowIsCorrect() throws {
        XCTAssertEqual(sut.colorForUnansweredRow(colorScheme: .light), Color(.unansweredRowGreen))
        //XCTAssertEqual(sut.colorForUnansweredRow(colorScheme: .dark), Color(.unansweredRowDarkBlue))
    }
    
    func test_colorOuterCircleIconsIsCorrect() throws {
        XCTAssertEqual(sut.colorForOuterCircleIcons(colorScheme: .light), .gray)
        //XCTAssertEqual(sut.colorForOuterCircleIcons(colorScheme: .dark), .white)
    }

}

class FirestoreMock: FirestoreProtocol {
    
    let poll = """
{
"id": "asd",
"title": "Brands",
"answers": ["Adidas", "Nandos", "Wobbly Bobs Jelly Emporium", "Costa Coffee"
],
"startTime": 1686143254,
"closeTime": 1687774246,
"published": true,
"question": "Which retailer would you like to see next in your Bink app?", "remindLaterMinutes": 10,
"allowCustomAnswer": true, "editTimeLimit": 600
}
"""
    
    let votingModel = """
{
    "id": "1",
    "pollId": "10",
    "userId": 1686143254,
    "createdDate": 1687774246,
    "overwritten": false,
    "answer": "Nandos",
    "customAnswer": ""
}
"""
    
    func getCollection(collection: FirestoreCollections) -> CollectionReference? {
        /// doesn't really matter. Is just for testing
        return nil
    }
    
    func getDocuments<T: Codable>(_ type: T.Type, query: Query?, completion: @escaping ([T]?) -> Void) {
        if "\(T.self)" == "PollVotingModel" {
            let p = PollVotingModel(id: "1", pollId: "10", userId: "100", createdDate: 1687336184, overwritten: false, answer: "Nandos", customAnswer: "")
            completion([p as! T])
        }
    }
    
    func fetchDocument<T: Codable>(_ type: T.Type, collection: FirestoreCollections, documentId: String, completion: @escaping (T?) -> Void) {
        
    }
    
    func fetchDocumentsInCollection<T: Codable>(_ type: T.Type, query: Query?, completion: @escaping ([T]?) -> Void) {
        
        ///need to do this because can't used JSondecoder on models that have properties with the Firstore @DocumentID wrapper
        if "\(T.self)" == "PollModel" {
            let p = PollModel(id: "10", title: "Brands", answers: ["Nandos", "KFC"], startTime: 1686143254, closeTime: 1687774246, published: true, question: "Which retailer would you like to see next in your Bink app?", remindLaterMinutes: 10, allowCustomAnswer: true, editTimeLimit: 60)
            completion([p as! T])
        } else  if "\(T.self)" == "PollVotingModel" {
            let p = PollVotingModel(id: "1", pollId: "10", userId: "100", createdDate: 1687336184, overwritten: false, answer: "Nandos", customAnswer: "")
            completion([p as! T])
        }
    }
    
    func fetchDocumentsInCollection<T>(_ type: T.Type, collection: CollectionReference?, completion: @escaping ([T]?) -> Void) where T : Decodable, T : Encodable {
        if "\(T.self)" == "WhatsNewModel" {
            let merch1 = NewMerchantModel(id: "230", description: ["Sign up to Tesco clubcard", "View your points"])
            let feat1 = NewFeatureModel(id: "0", title: "This is a new feature!", description: ["This new feature is pretty cool and you should totally check it out."], screen: 4, imageUrl: nil)
            let p = WhatsNewModel(appVersion: Bundle.currentVersion?.versionString, merchants: [merch1], features: [feat1])
            completion([p as! T])
        }
    }
    
    func addDocument(_ type: Codable, collection: FirestoreCollections, documentId: String?, completion: @escaping ((String) -> Void)) {
        completion("1000")
    }
    
    func deleteDocument(collection: FirestoreCollections, documentId: String, completion: @escaping ((Bool) -> Void)) {
        completion(true)
    }
}

