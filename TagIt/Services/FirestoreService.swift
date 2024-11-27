//
//  FirebaseManager.swift
//  TagIt
//
//  Created by Peter Tran on 2024-10-16.
//

// Error handling (.success, .failure) of completion
// What are the outputs? Structure?


import FirebaseFirestore

/// Singleton class for managing Firebase Firestore interactions.
class FirestoreService {
    /// Shared instance of FirebaseManager for global access.
    static let shared = FirestoreService()
    
    let db = Firestore.firestore()
    
    /// Init as singleton
    private init() {}
    
    // MARK: - API HELPER FUNCTIONS
    
    /**
     Creates a Firestore document if and only if it does not already exist.
     
     - Parameters:
     - collectionName: The name of the Firestore collection.
     - documentID: The ID of the document.
     - data: The `Codable` object to store in the document.
     - completion: A closure that returns an optional error if something goes wrong.
     */
    
    // use case? Should be in concrete services?
    func createDocumentIfNotExists<T: Codable>(collectionName: String, documentID: String, data: T, completion: @escaping (Error?) -> Void) {
        db.collection(collectionName).document(documentID).getDocument { (documentSnapshot, error) in
            // Sets completion to nil if document doesnt exist, otherwise create document
            if let document = documentSnapshot, document.exists {
                completion(nil)
            } else {
                self.createDocument(collectionName: collectionName, documentID: documentID, data: data, completion: completion)
            }
        }
    }
    
    /**
     Creates a Firestore document with an optional provided `documentID`. If `documentID` is `nil`, Firestore will generate one.
     
     - Parameters:
     - collectionName: The name of the Firestore collection.
     - documentID: The optional ID of the document. If `documentID` is `nil`, Firestore generates an ID.
     - data: The `Codable` data to set for the document.
     - completion: A closure that returns an optional error if something goes wrong during document creation.
     */
    func createDocument<T: Codable>(collectionName: String, documentID: String?, data: T, completion: @escaping (Error?) -> Void) {
        do {
            let dataDict = try Firestore.Encoder().encode(data)
            if let documentID = documentID {
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
     - completion: A closure that returns an optional error if something goes wrong during the update.
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
     - completion: A closure that returns the document data or an error if something goes wrong during retrieval.
     */
    func readDocument<T: Codable>(collectionName: String, documentID: String, modelType: T.Type, completion: @escaping (Result<T, Error>) -> Void) {
        db.collection(collectionName).document(documentID).getDocument { (documentSnapshot, error) in
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
            } else if let error = error {
                completion(.failure(error))
            } else {
                completion(.failure(NSError(domain: "FirestoreError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Document does not exist"])))
            }
        }
    }
    
    
    
    func readCollection<T: Codable>(collectionName: String, modelType: T.Type, completion: @escaping (Result<[T], Error>) -> Void) {
        db.collection(collectionName).getDocuments { (querySnapshot, error) in
            if let error = error {
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
     Updates an entire document in a Firestore collection with the provided data.
     
     - Parameters:
     - collectionName: The name of the Firestore collection.
     - documentID: The ID of the document to update.
     - data: A dictionary or `Codable` object containing the data to update.
     - completion: A closure that returns an optional error if something goes wrong during the update.
     */
    func updateDocument<T: Codable>(collectionName: String, documentID: String, data: T, completion: @escaping (Error?) -> Void) {
        do {
            let dataDict = try Firestore.Encoder().encode(data)
            db.collection(collectionName).document(documentID).setData(dataDict, merge: true) { error in
                if let error = error {
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
     Deletes a Firestore document from a collection.
     
     - Parameters:
     - collectionName: The name of the Firestore collection.
     - documentID: The ID of the document to delete.
     - completion: A closure that returns an optional error if something goes wrong during the deletion process.
     */
    func deleteDocument(collectionName: String, documentID: String, completion: @escaping (Error?) -> Void) {
        db.collection(collectionName).document(documentID).delete { error in
            if let error = error {
                print("Error deleting document \(documentID) from \(collectionName): \(error.localizedDescription)")
                completion(error)
            } else {
                print("Successfully deleted document \(documentID) from \(collectionName)")
                completion(nil)
            }
        }
    }
}
