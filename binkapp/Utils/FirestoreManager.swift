//
//  FirestoreManager.swift
//  binkapp
//
//  Created by Ricardo Silva on 29/03/2023.
//  Copyright © 2023 Bink. All rights reserved.
//

import Foundation
import FirebaseFirestore

enum FirestoreCollections: String {
    case polls
    case pollResults
    case releaseNotes
    case whatsNewIOS
}

class FirestoreManager {
    private let db = Firestore.firestore()
    
    func getCollection(collection: FirestoreCollections) -> CollectionReference? {
        return db.collection(collection.rawValue)
    }
    
    func fetchDocument<T: Codable>(_ type: T.Type, collection: FirestoreCollections, documentId: String, completion: @escaping (T?) -> Void) {
        let docRef = db.collection(collection.rawValue).document(documentId)
        docRef.getDocument(as: type) { result in
            switch result {
            case .success(let data):
                completion(data)
            case .failure(let error):
                print(error.localizedDescription)
                completion(nil)
            }
        }
    }
    
    func fetchDocumentsInCollection<T: Codable>(_ type: T.Type, query: Query, completion: @escaping ([T]?) -> Void) {
        query.addSnapshotListener { querySnapshot, err in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                do {
                    if let error = err {
                        throw error
                    }
                    guard let documents = querySnapshot?.documents else {
                        completion(nil)
                        return
                    }
                    let data = try documents.compactMap { QueryDocumentSnapshot -> T? in
                        return try QueryDocumentSnapshot.data(as: T.self)
                    }
                    completion(data)
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func fetchDocumentsInCollection<T: Codable>(_ type: T.Type, collection: CollectionReference, completion: @escaping ([T]?) -> Void) {
        collection.getDocuments() { querySnapshot, err in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                do {
                    if let error = err {
                        throw error
                    }
                    guard let documents = querySnapshot?.documents else {
                        completion(nil)
                        return
                    }
                    let data = try documents.compactMap { QueryDocumentSnapshot -> T? in
                        return try QueryDocumentSnapshot.data(as: T.self)
                    }
                    completion(data)
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func addDocument(_ type: Codable, collection: FirestoreCollections, documentId: String? = nil, completion: ((String) -> Void)? = nil) {
        let collectionRef = db.collection(collection.rawValue)
        var document: DocumentReference
        
        if let docId = documentId {
            document = collectionRef.document(docId)
        } else {
            document = collectionRef.document()
        }

        do {
            try document.setData(from: type)
            completion?(document.documentID)
        } catch {
            print(error)
        }
    }
}
