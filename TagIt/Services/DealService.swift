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
    
    // Add a new deal to Firestore
    func addDeal(newDeal: Deal, completion: @escaping (Result<Void, Error>) -> Void) {
        var updatedDeal = newDeal
        updatedDeal.dateTime = nil // Ensure Firestore sets the timestamp
        
        do {
            let _ = try db.collection(FirestoreCollections.deals).addDocument(from: updatedDeal)
            completion(.success(()))
        } catch let error {
            completion(.failure(error))
        }
    }

}

