//
//  DealService.swift
//  TagIt
//
//  Created by 何斯鹏 on 2024-10-16.
//

import Foundation
import FirebaseFirestore

class DealService {
    static let shared = DealService()
    
    private let db = Firestore.firestore()
    
    // Fetch all deals from Firestore
    func getDeals(completion: @escaping (Result<[Deal], Error>) -> Void) {
        db.collection(FirestoreCollections.deals)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                } else if let snapshot = snapshot {
                    let deals = snapshot.documents.compactMap { doc -> Deal? in
                        try? doc.data(as: Deal.self)
                    }
                    completion(.success(deals))
                }
            }
    }
    
    // Fetch a deal by ID
    func getDealById(id: String, completion: @escaping (Result<Deal, Error>) -> Void) {
        db.collection(FirestoreCollections.deals)
            .document(id)
            .getDocument { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                } else if let snapshot = snapshot, let deal = try? snapshot.data(as: Deal.self) {
                    completion(.success(deal))
                } else {
                    completion(.failure(NSError(domain: "DealService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Deal not found"])))
                }
            }
    }
    
    func addDeal(newDeal: Deal, completion: @escaping (Result<Void, Error>) -> Void) {
        FirestoreService.shared.createDocument(
            collectionName: FirestoreCollections.deals,
            documentID: newDeal.id,
            data: newDeal
        ) { error in
            if let error = error {
                print("Error adding new deal: \(error.localizedDescription)")
                completion(.failure(error))
            } else {
                // Increment the user's totalDeals
                FirestoreService.shared.updateField(
                    collectionName: FirestoreCollections.user,
                    documentID: newDeal.userID,
                    field: "totalDeals",
                    value: FieldValue.increment(Int64(1))
                ) { error in
                    if let error = error {
                        print("Error incrementing totalDeals for user: \(error.localizedDescription)")
                    }
                }
                completion(.success(()))
            }
        }
    }

    //Fetch a deal by userID
    func getDealsByUserID(userID: String, completion: @escaping (Result<[Deal], Error>) -> Void) {
        db.collection(FirestoreCollections.deals)
            .whereField("userID", isEqualTo: userID)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                } else if let snapshot = snapshot {
                    let deals = snapshot.documents.compactMap { doc -> Deal? in
                        try? doc.data(as: Deal.self)
                    }
                    completion(.success(deals))
                } else {
                    completion(.failure(NSError(domain: "DealService", code: -1, userInfo: [NSLocalizedDescriptionKey: "No deals found for this user"])))
                }
            }
    }

}

