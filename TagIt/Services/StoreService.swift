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
    private let searchService = SearchService()
    
    func getDeals(query: String, completion: @escaping (Result<[Deal], Error>) -> Void) {
        Task {
            do {
                // Step 1: Use Algolia to search for deals
                let searchResults = try await searchService.searchDeals(query: query)
                
                // Step 2: Map search results to Deal objects
                var deals = searchResults
                
                // Step 3: Fetch additional store information from Firestore
                let db = Firestore.firestore()
                let group = DispatchGroup()
                
                for (index, deal) in deals.enumerated() {
                    guard let storeId = deal.locationId else {
                        if let dealId = deal.id {
                            print("Deal \(dealId) has no locationId")
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
                
                // Step 4: Notify completion when all store fetches are done
                group.notify(queue: .main) {
                    completion(.success(deals))
                }
                
            } catch {
                print("Algolia search failed: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }
    
    func getStores(completion: @escaping (Result<[Store], Error>) -> Void) {
        let db = Firestore.firestore()
        db.collection(FirestoreCollections.stores)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                } else if let snapshot = snapshot {
                    let stores = snapshot.documents.compactMap { doc -> Store? in
                        try? doc.data(as: Store.self)
                    }
                    completion(.success(stores))
                }
            }
    }
}
