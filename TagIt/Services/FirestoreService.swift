//
//  FirebaseManager.swift
//  TagIt
//
//  Created by Peter Tran on 2024-10-16.
//


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
                    let decodedObject = try document.data(as: modelType)
                    completion(.success(decodedObject))
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

    // MARK: - Database Initialization Functions

    /**
     Initializes predefined collections with initial data.

     - Parameters:
        - completion: A closure that returns a `Bool` indicating success or failure.
     */
    func initializeAllCollections(completion: @escaping (Bool) -> Void) {
        let group = DispatchGroup()

        // Create users first using AuthService
        createDummyUsers(group: group)

        // After creating users, initialize other collections
        group.notify(queue: .main) {
            // Initialize collections after users are created
            self.initializeDealsCollection(group: group)
            self.initializeBarcodeItemReviewCollection(group: group)
            self.initializeReviewStarsCollection(group: group)
            self.initializeUserCommentsCollection(group: group)
            self.initializeVotesCollection(group: group)

            group.notify(queue: .main) {
                completion(true)
            }
        }
    }

    // MARK: - Database Initialization Functions

    /**
     Creates dummy users and stores them in Firebase Auth and Firestore.
     
     - Parameters:
        - group: The `DispatchGroup` to track the completion of creating dummy users.
     */
    private func createDummyUsers(group: DispatchGroup) {
        // Create user1 using AuthService and store in Firebase Auth and Firestore
        group.enter()
        AuthService.shared.createDummyUser(withEmail: "user1@example.com", password: "password123", displayName: "User One", avatarURL: nil) { result in
            switch result {
            case .success(let userId):
                print("Created dummy user1: \(userId)")
            case .failure(let error):
                print("Failed to create dummy user1: \(error.localizedDescription)")
            }
            group.leave()
        }

        // Create user2 using AuthService and store in Firebase Auth and Firestore
        group.enter()
        AuthService.shared.createDummyUser(withEmail: "user2@example.com", password: "password123", displayName: "User Two", avatarURL: "https://example.com/avatar2.jpg") { result in
            switch result {
            case .success(let userId):
                print("Created dummy user2: \(userId)")
            case .failure(let error):
                print("Failed to create dummy user2: \(error.localizedDescription)")
            }
            group.leave()
        }
    }

    /**
     Initializes the Deals collection with predefined data.
     
     - Parameters:
        - group: The `DispatchGroup` to track the completion of the operation.
     */
    private func initializeDealsCollection(group: DispatchGroup) {
        group.enter()
        let dealsData: [Deal] = [
            Deal(id: "deal1", userID: "user1", photoURL: "https://example.com/photo1.jpg", productText: "Product 1", postText: "50% off on Product 1", price: 9.99, location: "Store A", date: "2024-10-15", commentIDs: ["comment1", "comment2"], upvote: 20, downvote: 10, dateTime: Timestamp()),
            Deal(id: "deal2", userID: "user2", photoURL: "https://example.com/photo2.jpg", productText: "Product 2", postText: "30% off on Product 2", price: 19.99, location: "Store B", date: "2024-10-14", commentIDs: ["comment3", "comment4"], upvote: 2, downvote: 25, dateTime: Timestamp())
        ]
        self.initializeCollection(collectionName: FirestoreCollections.deals, initialData: dealsData) { error in
            if let error = error {
                print("Error initializing Deals collection: \(error.localizedDescription)")
            } else {
                print("Deals collection initialized successfully!")
            }
            group.leave()
        }
    }

    /**
     Initializes the BarcodeItemReview collection with predefined data.
     
     - Parameters:
        - group: The `DispatchGroup` to track the completion of the operation.
     */
    private func initializeBarcodeItemReviewCollection(group: DispatchGroup) {
        group.enter()
        let barcodeItemReviewData: [BarcodeItemReview] = [
            BarcodeItemReview(id: nil, userID: "user1", photoURL: "https://example.com/review_photo1.jpg", reviewStars: 4.5, productName: "Product 1", commentIDs: ["comment1", "comment3"], barcodeNumber: "1234567890123"),
            BarcodeItemReview(id: nil, userID: "user2", photoURL: "https://example.com/review_photo2.jpg", reviewStars: 3.7, productName: "Product 2", commentIDs: ["comment2", "comment4"], barcodeNumber: "9876543210987")
        ]
        self.initializeCollection(collectionName: FirestoreCollections.revItem, initialData: barcodeItemReviewData) { error in
            if let error = error {
                print("Error initializing BarcodeItemReview collection: \(error.localizedDescription)")
            } else {
                print("BarcodeItemReview collection initialized successfully!")
            }
            group.leave()
        }
    }

    /**
     Initializes the ReviewStars collection with predefined data.
     
     - Parameters:
        - group: The `DispatchGroup` to track the completion of the operation.
     */
    private func initializeReviewStarsCollection(group: DispatchGroup) {
        group.enter()
        let reviewStarsData: [ReviewStars] = [
            ReviewStars(id: nil, barcodeNumber: "1234567890123", reviewStars: 4.5, productName: "Product 1"),
            ReviewStars(id: nil, barcodeNumber: "9876543210987", reviewStars: 3.7, productName: "Product 2")
        ]
        self.initializeCollection(collectionName: FirestoreCollections.revStars, initialData: reviewStarsData) { error in
            if let error = error {
                print("Error initializing ReviewStars collection: \(error.localizedDescription)")
            } else {
                print("ReviewStars collection initialized successfully!")
            }
            group.leave()
        }
    }

    /**
     Initializes the UserComments collection with predefined data.
     
     - Parameters:
        - group: The `DispatchGroup` to track the completion of the operation.
     */
    private func initializeUserCommentsCollection(group: DispatchGroup) {
        group.enter()
        let userCommentsData: [UserComments] = [
            UserComments(id: "comment1", userID: "user1", commentText: "Great deal!", commentType: .deal, upvote: 50, downvote: 2, dateTime: Timestamp()),
            UserComments(id: "comment2", userID: "user2", commentText: "Could be cheaper.", commentType: .barcodeItem, upvote: 25, downvote: 5, dateTime: Timestamp()),
            UserComments(id: "comment3", userID: "user1", commentText: "Nice product!", commentType: .deal, upvote: 12, downvote: 3, dateTime: Timestamp()),
            UserComments(id: "comment4", userID: "user2", commentText: "Poor quality!", commentType: .barcodeItem, upvote: 2, downvote: 10, dateTime: Timestamp())
        ]
        self.initializeCollection(collectionName: FirestoreCollections.userComm, initialData: userCommentsData) { error in
            if let error = error {
                print("Error initializing UserComments collection: \(error.localizedDescription)")
            } else {
                print("UserComments collection initialized successfully!")
            }
            group.leave()
        }
    }

    /**
     Initializes the Votes collection with predefined data.
     
     - Parameters:
        - group: The `DispatchGroup` to track the completion of the operation.
     */
    private func initializeVotesCollection(group: DispatchGroup) {
        group.enter()
        let votesData: [Vote] = [
            // Votes on Deals (itemType: .deal)
            Vote(userId: "user1", itemId: "deal1", voteType: .upvote, itemType: .deal),
            Vote(userId: "user2", itemId: "deal1", voteType: .downvote, itemType: .deal),
            Vote(userId: "user1", itemId: "deal2", voteType: .upvote, itemType: .deal),
            Vote(userId: "user2", itemId: "deal2", voteType: .upvote, itemType: .deal),
            
            // Votes on Comments (itemType: .comment)
            Vote(userId: "user1", itemId: "comment1", voteType: .upvote, itemType: .comment),
            Vote(userId: "user2", itemId: "comment1", voteType: .downvote, itemType: .comment),
            Vote(userId: "user1", itemId: "comment2", voteType: .upvote, itemType: .comment),
            Vote(userId: "user2", itemId: "comment2", voteType: .downvote, itemType: .comment),
            
            // Votes on Barcode Item Reviews (itemType: .review)
            Vote(userId: "user1", itemId: "review1", voteType: .upvote, itemType: .review),
            Vote(userId: "user2", itemId: "review1", voteType: .downvote, itemType: .review)
        ]


        self.initializeCollection(collectionName: FirestoreCollections.votes, initialData: votesData) { error in
            if let error = error {
                print("Error initializing Votes collection: \(error.localizedDescription)")
            } else {
                print("Votes collection initialized successfully!")
            }
            group.leave()
        }
    }

    /**
     Initializes a Firestore collection with predefined data.
     
     - Parameters:
        - collectionName: The name of the Firestore collection.
        - initialData: An array of `Codable` objects representing the initial data.
        - completion: A closure that returns an optional error if initialization fails.
     */
    func initializeCollection<T: Codable>(collectionName: String, initialData: [T], completion: @escaping (Error?) -> Void) {
        let group = DispatchGroup()
        var finalError: Error? = nil

        for data in initialData {
            var documentID: String? = nil
            
            // Determine document ID based on the object type
            switch T.self {
            case is UserProfile.Type:
                documentID = (data as! UserProfile).userId
            case is Deal.Type:
                documentID = (data as! Deal).id
            case is UserComments.Type:
                documentID = (data as! UserComments).id ?? UUID().uuidString
            case is BarcodeItemReview.Type:
                let review = data as! BarcodeItemReview
                documentID = review.barcodeNumber
            case is ReviewStars.Type:
                let review = data as! ReviewStars
                documentID = review.barcodeNumber
            case is Vote.Type:
                let vote = data as! Vote
                documentID = "\(vote.userId)_\(vote.itemId)_\(vote.itemType.rawValue)"
            default:
                break
            }
            
            // Unwrap documentID
            guard let documentID = documentID else {
                print("Error: documentID is nil for data of type \(T.self)")
                continue
            }

            group.enter()
            createDocumentIfNotExists(collectionName: collectionName, documentID: documentID, data: data) { error in
                if let error = error {
                    finalError = error
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            completion(finalError)
        }
    }
}
