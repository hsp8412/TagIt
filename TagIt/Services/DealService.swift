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
            .order(by: "dateTime", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                } else if let snapshot = snapshot {
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
    
    // Fetch a deal by ID
    func getDealById(id: String, completion: @escaping (Result<Deal, Error>) -> Void) {
        db.collection(FirestoreCollections.deals)
            .document(id)
            .getDocument { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                } else if let snapshot = snapshot, var deal = try? snapshot.data(as: Deal.self) {
                    if let dateTime = deal.dateTime{
                        deal.date = Utils.timeAgoString(from: dateTime)
                        completion(.success(deal))
                    }
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
    
    /**
     Add  a deal ID to  the savedDeals array of a UserProfile in Firestore.
     
     - Parameters:
     - userID: The ID of the user whose savedDeals array is to be updated.
     - dealID: The ID of the deal to be added to the savedDeals array.
     - completion: A closure that returns a `Result<Void, Error>` indicating success or failure.
     
     This function retrieves the user's profile from Firestore, checks if the deal ID exists in the savedDeals array, removes it if found, and updates the user's profile in the Firestore database.
     */
    func addSavedDeal(userID: String, dealID: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let userRef = db.collection(FirestoreCollections.user).document(userID)
        
        userRef.getDocument { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let snapshot = snapshot, snapshot.exists,
                  var userProfile = try? snapshot.data(as: UserProfile.self) else {
                completion(.failure(NSError(domain: "DealService", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not found or invalid data"])))
                return
            }
            
            userProfile.savedDeals.append(dealID)
            
            userRef.updateData(["savedDeals": userProfile.savedDeals]) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        }
    }
    
    //Fetch saved deals by userID
    func getSavedDealsByUserID(userID: String, completion: @escaping (Result<[Deal], Error>) -> Void) {
        let userRef = db.collection(FirestoreCollections.user).document(userID)
        
        userRef.getDocument { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let snapshot = snapshot, snapshot.exists,
                  let userProfile = try? snapshot.data(as: UserProfile.self) else {
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
                            if let error = error {
                                completion(.failure(error))
                            } else if let snapshot = snapshot {
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
                                
                                // Check if all chunks are processed
                                pendingChunks -= 1
                                if pendingChunks == 0 {
                                    let sortedDeals = all_deals.sorted { firstDeal, secondDeal in
                                            guard let firstDate = firstDeal.dateTime?.dateValue(),
                                                  let secondDate = secondDeal.dateTime?.dateValue() else {
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
    
    //INCORRECT IMPLEMENTATION - FETCH ALL DEALS POST BY THE USER, NOT ALL SAVED DEALS
    //Fetch a deal by userID
    func getDealsByUserID(userID: String, completion: @escaping (Result<[Deal], Error>) -> Void) {
        db.collection(FirestoreCollections.deals)
            .whereField("userID", isEqualTo: userID)
            .order(by: "dateTime", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                } else if let snapshot = snapshot {
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
     Removes a deal ID from the savedDeals array of a UserProfile in Firestore.
     
     - Parameters:
     - userID: The ID of the user whose savedDeals array is to be updated.
     - dealID: The ID of the deal to be removed from the savedDeals array.
     - completion: A closure that returns a `Result<Void, Error>` indicating success or failure.
     
     This function retrieves the user's profile from Firestore, checks if the deal ID exists in the savedDeals array, removes it if found, and updates the user's profile in the Firestore database.
     */
    func removeSavedDeal(userID: String, dealID: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let userRef = db.collection(FirestoreCollections.user).document(userID)
        
        userRef.getDocument { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let snapshot = snapshot, snapshot.exists,
                  var userProfile = try? snapshot.data(as: UserProfile.self) else {
                completion(.failure(NSError(domain: "DealService", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not found or invalid data"])))
                return
            }
            
            if let index = userProfile.savedDeals.firstIndex(of: dealID) {
                userProfile.savedDeals.remove(at: index)
                
                userRef.updateData(["savedDeals": userProfile.savedDeals]) { error in
                    if let error = error {
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

