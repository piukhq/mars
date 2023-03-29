//
//  FirestoreManager.swift
//  binkapp
//
//  Created by Ricardo Silva on 29/03/2023.
//  Copyright © 2023 Bink. All rights reserved.
//

import Foundation
import FirebaseFirestore

class FirestoreManager {
    private let db = Firestore.firestore()
    
    func fetchDocument<T: Codable>(_ type: T.Type, collection: String, documentId: String, completion: @escaping (T?) -> Void) {
        let docRef = db.collection(collection).document(documentId)
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
    
    func fetchDocumentsInCollection<T: Codable>(_ type: T.Type, collection: String, completion: @escaping ([T]?) -> Void) {
        db.collection(collection).addSnapshotListener { (querySnapshot, error) in
            do {
                if let error = error {
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
    
    func addDocument(_ type: Codable, collection: String, completion: ((String) -> Void)? = nil) {
        let collectionRef = db.collection(collection)
        let document = collectionRef.document()
        
        do {
            //let newDocReference = try collectionRef.addDocument(from: type)
            //print("Voting stored with new document reference: \(newDocReference)")
            try document.setData(from: type)
            completion?(document.documentID)
        } catch {
            print(error)
        }
    }
    
    func updateDocument(_ type: Codable, collection: String, completion: (() -> Void)? = nil) {
        let collectionRef = db.collection(collection)
        
        do {
            let newDocReference = try collectionRef.addDocument(from: type)
            print("Voting stored with new document reference: \(newDocReference)")
            completion?()
        } catch {
            print(error)
        }
    }
}
