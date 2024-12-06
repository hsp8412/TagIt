//
//  FirestoreService.swift
//  TagIt
//
//  Created by Peter Tran on 2024-10-16.
//

import FirebaseFirestore

/**
 A singleton class responsible for managing Firestore interactions.

 This service class provides helper functions for creating, reading, updating, and deleting Firestore documents.
 It ensures consistent and error-free interactions with Firestore across different parts of the application.
 */
class FirestoreService {
    /// Shared instance of `FirestoreService` for global access.
    static let shared = FirestoreService()

    /// Reference to the Firestore database.
    let db = Firestore.firestore()

    /// Private initializer to enforce the singleton pattern.
    private init() {}

    // MARK: - API Helper Functions

    /**
         Creates a Firestore document if it does not already exist.

         - Parameters:
             - collectionName: The name of the Firestore collection.
             - documentID: The ID of the document.
             - data: The `Codable` object to store in the document.
             - completion: A closure that returns an optional error if the operation fails.

         This method checks if a document with the specified `documentID` exists in the given `collectionName`.
         If the document does not exist, it creates a new document with the provided `data`.
     */
    func createDocumentIfNotExists(collectionName: String, documentID: String, data: some Codable, completion: @escaping (Error?) -> Void) {
        db.collection(collectionName).document(documentID).getDocument { documentSnapshot, _ in
            if let document = documentSnapshot, document.exists {
                completion(nil)
            } else {
                self.createDocument(collectionName: collectionName, documentID: documentID, data: data, completion: completion)
            }
        }
    }

    /**
         Creates a Firestore document with an optional `documentID`. If `documentID` is `nil`, Firestore generates one.

         - Parameters:
             - collectionName: The name of the Firestore collection.
             - documentID: The optional ID of the document. If `nil`, Firestore generates an ID.
             - data: The `Codable` data to set for the document.
             - completion: A closure that returns an optional error if the operation fails.

         This method encodes the provided `data` and stores it in Firestore under the specified `collectionName` and `documentID`.
     */
    func createDocument(collectionName: String, documentID: String?, data: some Codable, completion: @escaping (Error?) -> Void) {
        do {
            let dataDict = try Firestore.Encoder().encode(data)
            if let documentID {
                // Use the provided documentID
                db.collection(collectionName).document(documentID).setData(dataDict) { error in
                    completion(error)
                }
            } else {
                // Firestore generates the document ID
                db.collection(collectionName).addDocument(data: dataDict) { error in
                    completion(error)
                }
            }
        } catch {
            completion(error)
        }
    }

    /**
         Updates a specific field in a Firestore document.

         - Parameters:
             - collectionName: The name of the Firestore collection.
             - documentID: The ID of the document.
             - field: The field to update.
             - value: The new value for the field.
             - completion: A closure that returns an optional error if the operation fails.

         This method updates the specified `field` in the document identified by `documentID` within the given `collectionName` with the new `value`.
     */
    func updateField(collectionName: String, documentID: String, field: String, value: Any, completion: @escaping (Error?) -> Void) {
        db.collection(collectionName).document(documentID).updateData([field: value]) { error in
            completion(error)
        }
    }

    /**
         Reads data from a Firestore document.

         - Parameters:
             - collectionName: The name of the Firestore collection.
             - documentID: The ID of the document.
             - modelType: The type of the model to decode the document data into.
             - completion: A closure that returns a `Result` containing the decoded model or an error.

         This method retrieves the document identified by `documentID` from the specified `collectionName` and attempts to decode it into the provided `modelType`.
     */
    func readDocument<T: Codable>(collectionName: String, documentID: String, modelType: T.Type, completion: @escaping (Result<T, Error>) -> Void) {
        db.collection(collectionName).document(documentID).getDocument { documentSnapshot, error in
            if let document = documentSnapshot, document.exists {
                do {
                    if modelType == UserProfile.self {
                        let data = document.data() ?? [:]
                        guard let userProfile = UserProfile(
                            id: documentID,
                            email: data["email"] as? String ?? "",
                            displayName: data["displayName"] as? String ?? "Anonymous",
                            avatarURL: data["avatarURL"] as? String,
                            score: data["score"] as? Int ?? 0,
                            savedDeals: data["savedDeals"] as? [String] ?? [],
                            totalUpvotes: data["totalUpvotes"] as? Int ?? 0,
                            totalDownvotes: data["totalDownvotes"] as? Int ?? 0,
                            totalDeals: data["totalDeals"] as? Int ?? 0,
                            totalComments: data["totalComments"] as? Int ?? 0,
                            rankingPoints: data["rankingPoints"] as? Int ?? 0
                        ) as? T else {
                            throw NSError(domain: "FirestoreError", code: -2, userInfo: [NSLocalizedDescriptionKey: "Type mismatch for UserProfile"])
                        }
                        completion(.success(userProfile))
                    } else {
                        let decodedObject = try document.data(as: modelType)
                        completion(.success(decodedObject))
                    }
                } catch {
                    completion(.failure(error))
                }
            } else if let error {
                completion(.failure(error))
            } else {
                completion(.failure(NSError(domain: "FirestoreError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Document does not exist"])))
            }
        }
    }

    /**
         Reads all documents from a Firestore collection.

         - Parameters:
             - collectionName: The name of the Firestore collection.
             - modelType: The type of the model to decode the documents into.
             - completion: A closure that returns a `Result` containing an array of decoded models or an error.

         This method retrieves all documents from the specified `collectionName` and attempts to decode each document into the provided `modelType`.
     */
    func readCollection<T: Codable>(collectionName: String, modelType: T.Type, completion: @escaping (Result<[T], Error>) -> Void) {
        db.collection(collectionName).getDocuments { querySnapshot, error in
            if let error {
                completion(.failure(error))
            } else if let documents = querySnapshot?.documents {
                let results = documents.compactMap { document -> T? in
                    do {
                        if T.self == UserProfile.self {
                            let data = document.data()
                            return UserProfile(
                                id: document.documentID,
                                email: data["email"] as? String ?? "",
                                displayName: data["displayName"] as? String ?? "Anonymous",
                                avatarURL: data["avatarURL"] as? String,
                                score: data["score"] as? Int ?? 0,
                                savedDeals: data["savedDeals"] as? [String] ?? [],
                                totalUpvotes: data["totalUpvotes"] as? Int ?? 0,
                                totalDownvotes: data["totalDownvotes"] as? Int ?? 0,
                                totalDeals: data["totalDeals"] as? Int ?? 0,
                                totalComments: data["totalComments"] as? Int ?? 0,
                                rankingPoints: data["rankingPoints"] as? Int ?? 0
                            ) as? T
                        } else {
                            return try document.data(as: modelType)
                        }
                    } catch {
                        print("Error decoding document \(document.documentID): \(error.localizedDescription)")
                        return nil
                    }
                }
                completion(.success(results))
            } else {
                completion(.failure(NSError(domain: "FirestoreError", code: -1, userInfo: [NSLocalizedDescriptionKey: "No documents found"])))
            }
        }
    }

    /**
         Updates an entire Firestore document with the provided data.

         - Parameters:
             - collectionName: The name of the Firestore collection.
             - documentID: The ID of the document to update.
             - data: A `Codable` object containing the data to update.
             - completion: A closure that returns an optional error if the operation fails.

         This method encodes the provided `data` and updates the specified document in Firestore. If `merge` is set to `true`, it merges the data with existing fields; otherwise, it overwrites the document.
     */
    func updateDocument(collectionName: String, documentID: String, data: some Codable, completion: @escaping (Error?) -> Void) {
        do {
            let dataDict = try Firestore.Encoder().encode(data)
            db.collection(collectionName).document(documentID).setData(dataDict, merge: true) { error in
                if let error {
                    print("Error updating document \(documentID): \(error.localizedDescription)")
                    completion(error)
                } else {
                    print("Successfully updated document \(documentID) in \(collectionName)")
                    completion(nil)
                }
            }
        } catch {
            print("Error encoding data for update: \(error.localizedDescription)")
            completion(error)
        }
    }

    /**
         Deletes a Firestore document from a specified collection.

         - Parameters:
             - collectionName: The name of the Firestore collection.
             - documentID: The ID of the document to delete.
             - completion: A closure that returns an optional error if the operation fails.

         This method removes the document identified by `documentID` from the specified `collectionName` in Firestore.
     */
    func deleteDocument(collectionName: String, documentID: String, completion: @escaping (Error?) -> Void) {
        db.collection(collectionName).document(documentID).delete { error in
            if let error {
                print("Error deleting document \(documentID) from \(collectionName): \(error.localizedDescription)")
                completion(error)
            } else {
                print("Successfully deleted document \(documentID) from \(collectionName)")
                completion(nil)
            }
        }
    }
}
