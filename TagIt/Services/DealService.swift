//
//  DealService.swift
//  TagIt
//
//  Created by 何斯鹏 on 2024-10-16.
//

import FirebaseFirestore
import Foundation

/**
 A service responsible for managing deals and their interactions.

 This service provides functionalities to fetch all deals, retrieve specific deals by ID,
 add new deals, manage saved deals for users, and fetch deals associated with specific users.
 */
class DealService {
    /**
     The shared singleton instance of `DealService`.

     This ensures that a single, consistent instance of the service is used throughout the application.
     */
    static let shared = DealService()

    /**
     The Firestore database instance used for all database operations.

     This instance facilitates interactions with Firestore collections and documents.
     */
    private let db = Firestore.firestore()

    /**
     Fetches all deals from Firestore, ordered by the `dateTime` field in descending order.

     - Parameter completion: A closure that receives a `Result` containing an array of `Deal` on success or an `Error` on failure.

     - Returns: Void. The result is delivered asynchronously through the `completion` closure.
     */
    func getDeals(completion: @escaping (Result<[Deal], Error>) -> Void) {
        db.collection(FirestoreCollections.deals)
            .order(by: "dateTime", descending: true)
            .getDocuments { snapshot, error in
                if let error {
                    completion(.failure(error))
                } else if let snapshot {
                    let deals = snapshot.documents.compactMap { doc -> Deal? in
                        do {
                            // Decode the document into a Deal object
                            var deal = try doc.data(as: Deal.self)

                            // Get the Firestore Timestamp for dateTime
                            if let timestamp = doc.get("dateTime") as? Timestamp {
                                // Convert to a human-readable string
                                let dateString = Utils.timeAgoString(from: timestamp)
                                // Update the `date` field
                                deal.date = dateString
                            }

                            return deal
                        } catch {
                            print("Error decoding Deal: \(error)")
                            return nil
                        }
                    }
                    completion(.success(deals))
                }
            }
    }

    /**
     Fetches a specific deal by its unique identifier.

     - Parameters:
       - id: The unique identifier of the deal to be fetched.
       - completion: A closure that receives a `Result` containing the `Deal` on success or an `Error` on failure.

     - Returns: Void. The result is delivered asynchronously through the `completion` closure.
     */
    func getDealById(id: String, completion: @escaping (Result<Deal, Error>) -> Void) {
        db.collection(FirestoreCollections.deals)
            .document(id)
            .getDocument { snapshot, error in
                if let error {
                    completion(.failure(error))
                } else if let snapshot, var deal = try? snapshot.data(as: Deal.self) {
                    if let dateTime = deal.dateTime {
                        deal.date = Utils.timeAgoString(from: dateTime)
                        completion(.success(deal))
                    } else {
                        completion(.failure(NSError(domain: "DealService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid dateTime field"])))
                    }
                } else {
                    completion(.failure(NSError(domain: "DealService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Deal not found"])))
                }
            }
    }

    /**
     Adds a new deal to Firestore and increments the `totalDeals` count for the associated user.

     - Parameters:
       - newDeal: The `Deal` object to be added to Firestore.
       - completion: A closure that receives a `Result` indicating success (`Void`) or an `Error` on failure.

     - Returns: Void. The result is delivered asynchronously through the `completion` closure.
     */
    func addDeal(newDeal: Deal, completion: @escaping (Result<Void, Error>) -> Void) {
        FirestoreService.shared.createDocument(
            collectionName: FirestoreCollections.deals,
            documentID: newDeal.id,
            data: newDeal
        ) { error in
            if let error {
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
                    if let error {
                        print("Error incrementing totalDeals for user: \(error.localizedDescription)")
                    }
                }
                completion(.success(()))
            }
        }
    }

    /**
     Adds a deal ID to the `savedDeals` array of a `UserProfile` in Firestore.

     - Parameters:
       - userID: The ID of the user whose `savedDeals` array is to be updated.
       - dealID: The ID of the deal to be added to the `savedDeals` array.
       - completion: A closure that receives a `Result<Void, Error>` indicating success or failure.

     - Returns: Void. The result is delivered asynchronously through the `completion` closure.

     This function retrieves the user's profile from Firestore, appends the deal ID to the `savedDeals` array, and updates the user's profile in the Firestore database.
     */
    func addSavedDeal(userID: String, dealID: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let userRef = db.collection(FirestoreCollections.user).document(userID)

        userRef.getDocument { snapshot, error in
            if let error {
                completion(.failure(error))
                return
            }

            guard let snapshot, snapshot.exists,
                  var userProfile = try? snapshot.data(as: UserProfile.self)
            else {
                completion(.failure(NSError(domain: "DealService", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not found or invalid data"])))
                return
            }

            userProfile.savedDeals.append(dealID)

            userRef.updateData(["savedDeals": userProfile.savedDeals]) { error in
                if let error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        }
    }

    /**
     Fetches all saved deals for a specific user by their user ID.

     - Parameters:
       - userID: The ID of the user whose saved deals are to be fetched.
       - completion: A closure that receives a `Result` containing an array of `Deal` on success or an `Error` on failure.

     - Returns: Void. The result is delivered asynchronously through the `completion` closure.

     This function retrieves the user's profile, fetches each saved deal in chunks (due to Firestore's query limitations), and returns the aggregated list of deals sorted by `dateTime` in descending order.
     */
    func getSavedDealsByUserID(userID: String, completion: @escaping (Result<[Deal], Error>) -> Void) {
        let userRef = db.collection(FirestoreCollections.user).document(userID)

        userRef.getDocument { snapshot, error in
            if let error {
                completion(.failure(error))
                return
            }

            guard let snapshot, snapshot.exists,
                  let userProfile = try? snapshot.data(as: UserProfile.self)
            else {
                completion(.failure(NSError(domain: "DealService", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not found or invalid data"])))
                return
            }

            var all_deals: [Deal] = []

            if !userProfile.savedDeals.isEmpty {
                // Split IDs into chunks of 10
                let chunks = userProfile.savedDeals.chunked(into: 10)
                var pendingChunks = chunks.count

                for chunk in chunks {
                    self.db.collection(FirestoreCollections.deals)
                        .whereField(FieldPath.documentID(), in: chunk)
                        .getDocuments { snapshot, error in
                            if let error {
                                completion(.failure(error))
                            } else if let snapshot {
                                let deals = snapshot.documents.compactMap { doc -> Deal? in
                                    do {
                                        // Decode the document into a Deal object
                                        var deal = try doc.data(as: Deal.self)

                                        // Get the Firestore Timestamp for dateTime
                                        if let timestamp = doc.get("dateTime") as? Timestamp {
                                            // Convert to a human-readable string
                                            let dateString = Utils.timeAgoString(from: timestamp)
                                            // Update the `date` field
                                            deal.date = dateString
                                        }
                                        return deal
                                    } catch {
                                        print("Error decoding Deal: \(error)")
                                        return nil
                                    }
                                }
                                all_deals.append(contentsOf: deals)

                                // Check if all chunks are processed
                                pendingChunks -= 1
                                if pendingChunks == 0 {
                                    let sortedDeals = all_deals.sorted { firstDeal, secondDeal in
                                        guard let firstDate = firstDeal.dateTime?.dateValue(),
                                              let secondDate = secondDeal.dateTime?.dateValue()
                                        else {
                                            return false
                                        }
                                        return firstDate > secondDate // Descending order
                                    }
                                    completion(.success(sortedDeals))
                                }
                            }
                        }
                }
            } else {
                completion(.success(all_deals))
            }
        }
    }

    /**
     Fetches all deals posted by a specific user by their user ID.

     - Parameters:
       - userID: The ID of the user whose posted deals are to be fetched.
       - completion: A closure that receives a `Result` containing an array of `Deal` on success or an `Error` on failure.

     - Returns: Void. The result is delivered asynchronously through the `completion` closure.

     **Note:** This implementation fetches all deals posted by the user, not the saved deals.
     */
    func getDealsByUserID(userID: String, completion: @escaping (Result<[Deal], Error>) -> Void) {
        db.collection(FirestoreCollections.deals)
            .whereField("userID", isEqualTo: userID)
            .order(by: "dateTime", descending: true)
            .getDocuments { snapshot, error in
                if let error {
                    completion(.failure(error))
                } else if let snapshot {
                    let deals = snapshot.documents.compactMap { doc -> Deal? in
                        do {
                            // Decode the document into a Deal object
                            var deal = try doc.data(as: Deal.self)

                            // Get the Firestore Timestamp for dateTime
                            if let timestamp = doc.get("dateTime") as? Timestamp {
                                // Convert to a human-readable string
                                let dateString = Utils.timeAgoString(from: timestamp)
                                // Update the `date` field
                                deal.date = dateString
                            }

                            return deal
                        } catch {
                            print("Error decoding Deal: \(error)")
                            return nil
                        }
                    }
                    completion(.success(deals))
                } else {
                    completion(.failure(NSError(domain: "DealService", code: -1, userInfo: [NSLocalizedDescriptionKey: "No deals found for this user"])))
                }
            }
    }

    /**
     Removes a deal ID from the `savedDeals` array of a `UserProfile` in Firestore.

     - Parameters:
       - userID: The ID of the user whose `savedDeals` array is to be updated.
       - dealID: The ID of the deal to be removed from the `savedDeals` array.
       - completion: A closure that receives a `Result<Void, Error>` indicating success or failure.

     - Returns: Void. The result is delivered asynchronously through the `completion` closure.

     This function retrieves the user's profile from Firestore, checks if the deal ID exists in the `savedDeals` array,
     removes it if found, and updates the user's profile in the Firestore database.
     */
    func removeSavedDeal(userID: String, dealID: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let userRef = db.collection(FirestoreCollections.user).document(userID)

        userRef.getDocument { snapshot, error in
            if let error {
                completion(.failure(error))
                return
            }

            guard let snapshot, snapshot.exists,
                  var userProfile = try? snapshot.data(as: UserProfile.self)
            else {
                completion(.failure(NSError(domain: "DealService", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not found or invalid data"])))
                return
            }

            if let index = userProfile.savedDeals.firstIndex(of: dealID) {
                userProfile.savedDeals.remove(at: index)

                userRef.updateData(["savedDeals": userProfile.savedDeals]) { error in
                    if let error {
                        completion(.failure(error))
                    } else {
                        completion(.success(()))
                    }
                }
            } else {
                completion(.failure(NSError(domain: "DealService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Deal ID not found in savedDeals"])))
            }
        }
    }
}
