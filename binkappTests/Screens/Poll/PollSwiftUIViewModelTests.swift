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
        print(sut.votePercentage(answer: "Nandos"))
        XCTAssertEqual(sut.votePercentage(answer: "Nandos"), 1.0)
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
            let p = PollVotingModel(id: "1", pollId: "10", userId: "100", createdDate: 1687774246, overwritten: false, answer: "Nandos", customAnswer: "")
            completion([p as! T])
        }
    }
    
    func fetchDocument<T: Codable>(_ type: T.Type, collection: FirestoreCollections, documentId: String, completion: @escaping (T?) -> Void) {
        
    }
    
    func fetchDocumentsInCollection<T: Codable>(_ type: T.Type, query: Query?, completion: @escaping ([T]?) -> Void) {
        
        ///need to do this because can't used JSondecoder on models that have properties with the Firstore @DocumentID wrapper
        if "\(T.self)" == "PollModel" {
            let p = PollModel(id: "10", title: "Brands", answers: ["Nandos"], startTime: 1686143254, closeTime: 1687774246, published: true, question: "Which retailer would you like to see next in your Bink app?", remindLaterMinutes: 10, allowCustomAnswer: true, editTimeLimit: 1000)
            completion([p as! T])
        } else  if "\(T.self)" == "PollVotingModel" {
//            let data = self.votingModel.data(using: .utf8)!
//            let val = try! JSONDecoder().decode(T.self, from: data)
//            completion([val])
            let p = PollVotingModel(id: "1", pollId: "10", userId: "100", createdDate: 1687774246, overwritten: false, answer: "Nandos", customAnswer: "")
            completion([p as! T])
        }
    }
    
    func fetchDocumentsInCollection<T>(_ type: T.Type, collection: CollectionReference, completion: @escaping ([T]?) -> Void) where T : Decodable, T : Encodable {
        
    }
    
    func addDocument(_ type: Codable, collection: FirestoreCollections, documentId: String?, completion: @escaping ((String) -> Void)) {
        
    }
    
    func deleteDocument(collection: FirestoreCollections, documentId: String, completion: @escaping ((Bool) -> Void)) {
        
    }
}

