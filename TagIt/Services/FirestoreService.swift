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

    // MARK: - Database Initialization Functions

    /**
     Initializes predefined collections with initial data.
     
     - Parameters:
        - completion: A closure that returns a `Bool` indicating success or failure.
     */
    func initializeAllCollections(completion: @escaping (Bool) -> Void) {
        // Initialize UserProfile collection
        let userProfileData: [UserProfile] = [
            UserProfile(userId: "user1", email: "user1@example.com", displayName: "User One", avatarURL: nil),
            UserProfile(userId: "user2", email: "user2@example.com", displayName: "User Two", avatarURL: "https://example.com/avatar2.jpg")
        ]
        initializeCollection(collectionName: FirestoreCollections.userProfile, initialData: userProfileData) { error in
            if let error = error {
                print("Error initializing UserProfile collection: \(error.localizedDescription)")
            } else {
                print("UserProfile collection initialized successfully!")
            }
        }

        // Initialize Deals collection
        let dealsData: [Deal] = [
            Deal(id: "deal1", userID: "user1", photoURL: "https://example.com/photo1.jpg", productText: "Product 1", postText: "50% off on Product 1", price: 9.99, location: "Store A", date: "2024-10-15", commentIDs: ["comment1", "comment2"], upvote: 20, downvote: 10),
            Deal(id: "deal2", userID: "user2", photoURL: "https://example.com/photo2.jpg", productText: "Product 2", postText: "30% off on Product 2", price: 19.99, location: "Store B", date: "2024-10-14", commentIDs: ["comment3", "comment4"], upvote: 2, downvote: 25)
        ]
        initializeCollection(collectionName: FirestoreCollections.deals, initialData: dealsData) { error in
            if let error = error {
                print("Error initializing Deals collection: \(error.localizedDescription)")
            } else {
                print("Deals collection initialized successfully!")
            }
        }

        // Initialize BarcodeItemReview collection
        let barcodeItemReviewData: [BarcodeItemReview] = [
            BarcodeItemReview(id: nil, userID: "user1", photoURL: "https://example.com/review_photo1.jpg", reviewStars: 4.5, productName: "Product 1", commentIDs: ["comment1", "comment3"], barcodeNumber: "1234567890123"),
            BarcodeItemReview(id: nil, userID: "user2", photoURL: "https://example.com/review_photo2.jpg", reviewStars: 3.7, productName: "Product 2", commentIDs: ["comment2", "comment4"], barcodeNumber: "9876543210987")
        ]
        initializeCollection(collectionName: FirestoreCollections.barcodeItemReview, initialData: barcodeItemReviewData) { error in
            if let error = error {
                print("Error initializing BarcodeItemReview collection: \(error.localizedDescription)")
            } else {
                print("BarcodeItemReview collection initialized successfully!")
            }
        }

        // Initialize ReviewStars collection
        let reviewStarsData: [ReviewStars] = [
            ReviewStars(id: nil, barcodeNumber: "1234567890123", reviewStars: 4.5, productName: "Product 1"),
            ReviewStars(id: nil, barcodeNumber: "9876543210987", reviewStars: 3.7, productName: "Product 2")
        ]
        initializeCollection(collectionName: FirestoreCollections.reviewStars, initialData: reviewStarsData) { error in
            if let error = error {
                print("Error initializing ReviewStars collection: \(error.localizedDescription)")
            } else {
                print("ReviewStars collection initialized successfully!")
            }
        }

        // Initialize UserComments collection
        let userCommentsData: [UserComments] = [
            UserComments(id: "comment1", userID: "user1", commentText: "Great deal!", type: 0, upvote: 50, downvote: 2),
            UserComments(id: "comment2", userID: "user2", commentText: "Could be cheaper.", type: 1, upvote: 25, downvote: 5)
        ]
        initializeCollection(collectionName: FirestoreCollections.userComments, initialData: userCommentsData) { error in
            if let error = error {
                print("Error initializing UserComments collection: \(error.localizedDescription)")
            } else {
                print("UserComments collection initialized successfully!")
            }
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
            default:
                break
            }
            
            if let documentID = documentID {
                group.enter()
                createDocumentIfNotExists(collectionName: collectionName, documentID: documentID, data: data) { error in
                    if let error = error {
                        finalError = error
                    }
                    group.leave()
                }
            }
        }

        group.notify(queue: .main) {
            completion(finalError)
        }
    }
    
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

    // MARK: - API HELPER FUNCTIONS

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
}
