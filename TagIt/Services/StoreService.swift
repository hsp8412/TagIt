//
//  StoreService.swift
//  TagIt
//
//  Created by 何斯鹏 on 2024-11-16.
//

import FirebaseFirestore
import Foundation

/**
 A service responsible for managing store-related functionalities within the TagIt application.

 This service provides functionalities to search for deals, fetch stores, and retrieve specific store details.
 */
class StoreService {
    /**
     The shared singleton instance of `StoreService`.

     This ensures that a single, consistent instance of the service is used throughout the application.
     */
    static let shared = StoreService()

    /**
     The `SearchService` instance used to perform deal searches.

     This service is utilized to integrate Algolia search functionalities within the `StoreService`.
     */
    private let searchService = SearchService()

    /**
     Retrieves deals based on a search query and fetches additional store information for each deal.

     - Parameters:
       - query: The search query string used to find matching deals.
       - completion: A closure that receives a `Result` containing an array of `Deal` on success or an `Error` on failure.

     This function performs the following steps:
     1. Uses Algolia to search for deals matching the query.
     2. Maps the search results to `Deal` objects.
     3. Fetches additional store information from Firestore for each deal.
     4. Returns the enriched deals through the completion handler.
     */
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

                        if let error {
                            print("Error fetching store \(storeId): \(error.localizedDescription)")
                            return
                        }

                        guard let storeSnapshot, storeSnapshot.exists,
                              let storeData = try? storeSnapshot.data(as: Store.self)
                        else {
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

    /**
     Retrieves all stores from Firestore.

     - Parameter completion: A closure that receives a `Result` containing an array of `Store` on success or an `Error` on failure.

     This function fetches all store documents from the Firestore `stores` collection and decodes them into `Store` objects.
     */
    func getStores(completion: @escaping (Result<[Store], Error>) -> Void) {
        let db = Firestore.firestore()
        db.collection(FirestoreCollections.stores)
            .getDocuments { snapshot, error in
                if let error {
                    completion(.failure(error))
                } else if let snapshot {
                    let stores = snapshot.documents.compactMap { doc -> Store? in
                        try? doc.data(as: Store.self)
                    }
                    completion(.success(stores))
                }
            }
    }

    /**
     Retrieves a specific store by its unique identifier.

     - Parameters:
       - id: The unique identifier of the store to be fetched.
       - completion: A closure that receives a `Result` containing the `Store` on success or an `Error` on failure.

     This function fetches a store document from the Firestore `stores` collection based on the provided `id` and decodes it into a `Store` object.
     */
    func getStoreById(id: String, completion: @escaping (Result<Store, Error>) -> Void) {
        let db = Firestore.firestore()
        db.collection(FirestoreCollections.stores)
            .document(id).getDocument { document, error in
                if let error {
                    // Handle error
                    completion(.failure(error))
                    return
                }
                guard let document, document.exists else {
                    // Handle case where document does not exist
                    completion(.failure(NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Document not found."])))
                    return
                }

                do {
                    // Decode the document into the `Store` model
                    let store = try document.data(as: Store.self)
                    completion(.success(store))
                } catch {
                    // Handle decoding error
                    completion(.failure(error))
                }
            }
    }
}
