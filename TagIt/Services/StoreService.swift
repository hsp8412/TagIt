//
//  LocationService.swift
//  TagIt
//
//  Created by 何斯鹏 on 2024-11-16.
//

import Foundation
import FirebaseFirestore

class StoreService {
    static let shared = StoreService()
    
    func getDeals(query: String, completion: @escaping (Result<[Deal], Error>) -> Void) {
        let db = Firestore.firestore()
        db.collection(FirestoreCollections.deals)
            .whereField("productText", isGreaterThanOrEqualTo: query)
            .whereField("productText", isLessThanOrEqualTo: query + "\u{F7FF}")
            .getDocuments { (snapshot, error) in
                if let error = error {
                    print("Failed to get deals: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("No deals found")
                    completion(.success([]))
                    return
                }
                
                var deals = documents.compactMap { document in
                    try? document.data(as: Deal.self)
                }
                
                let group = DispatchGroup()
                
                for (index, deal) in deals.enumerated() {
                    guard let storeId = deal.locationId else {
                        if let dealId = deal.id{
                            print("Deal \(dealId) has no locationId")
                            continue
                        }
                        continue
                    }
                    
                    group.enter()
                    db.collection(FirestoreCollections.stores).document(storeId).getDocument { storeSnapshot, error in
                        defer { group.leave() }
                        
                        if let error = error {
                            print("Error fetching store \(storeId): \(error.localizedDescription)")
                            return
                        }
                        
                        guard let storeSnapshot = storeSnapshot, storeSnapshot.exists,
                              let storeData = try? storeSnapshot.data(as: Store.self) else {
                            print("Store \(storeId) does not exist or failed to decode")
                            return
                        }
                        
                        deals[index].store = storeData
                    }
                }
                
                group.notify(queue: .main) {
                    completion(.success(deals))
                }
            }
    }
}
