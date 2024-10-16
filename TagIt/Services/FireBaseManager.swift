//
//  FireBaseManager.swift
//  TagIt
//
//  Created by Peter Tran on 2024-10-15.
//

import FirebaseFirestore

/// Singleton class for managing Firebase Firestore interactions.
class FirebaseManager {
    /// Shared instance of FirebaseManager for global access.
    static let shared = FirebaseManager()
    
    /// Firestore database reference.
    let db = Firestore.firestore()

    /// Private initializer to ensure the class follows the Singleton pattern.
    private init() {}

    // MARK: - Database Initialization

    /**
     Initializes a Firestore collection with predefined data if the documents do not already exist.
     
     - Parameters:
        - collectionName: The name of the Firestore collection.
        - initialData: An array of dictionaries containing the data for each document.
        - completion: A closure that returns an optional error if something goes wrong during the initialization.
     */
    func initializeCollection(collectionName: String, initialData: [[String: Any]], completion: @escaping (Error?) -> Void) {
        let group = DispatchGroup()
        var finalError: Error? = nil

        for data in initialData {
            var documentID: String? = nil
            
            // Dynamically assign the correct field to documentID based on the collection.
            switch collectionName {
            case "UserProfile":
                documentID = data["userId"] as? String
            case "Deals":
                documentID = data["postID"] as? String
            case "UserComments":
                documentID = data["commentID"] as? String
            case "BarcodedItemReviews":
                documentID = data["reviewID"] as? String
            case "ReviewStars":
                // Create a composite key from userId and barcodeNumber for uniqueness.
                if let userId = data["userId"] as? String, let barcode = data["barcodeNumber"] as? String {
                    documentID = "\(userId)_\(barcode)"
                }
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
     Initializes all necessary collections in Firestore with predefined data.
     
     - Parameter completion: A closure that indicates whether the initialization succeeded.
     */
    func initializeAllCollections(completion: @escaping (Bool) -> Void) {
        // Initialize UserProfile collection
        let userProfileData: [[String: Any]] = [
            ["userId": "user1", "email": "user1@example.com", "password": "encrypted_password_1", "displayName": "User One", "avatarURL": "https://example.com/avatar1.jpg"],
            ["userId": "user2", "email": "user2@example.com", "password": "encrypted_password_2", "displayName": "User Two", "avatarURL": "https://example.com/avatar2.jpg"]
        ]
        initializeCollection(collectionName: "UserProfile", initialData: userProfileData) { error in
            if let error = error {
                print("Error initializing UserProfile collection: \(error.localizedDescription)")
            } else {
                print("UserProfile collection initialized successfully!")
            }
        }

        // Initialize Deals collection
        let dealsData: [[String: Any]] = [
            ["postID": "deal1", "userId": "user1", "photoURL": "https://example.com/photo1.jpg", "productText": "Deal on Product 1", "postText": "50% off on Product 1", "price": 9.99, "location": "Store A", "date": "2024-10-15", "upvote": 100, "downvote": 10, "commentIDs": ["comment1", "comment2"]],
            ["postID": "deal2", "userId": "user2", "photoURL": "https://example.com/photo2.jpg", "productText": "Deal on Product 2", "postText": "30% off on Product 2", "price": 19.99, "location": "Store B", "date": "2024-10-14", "upvote": 200, "downvote": 15, "commentIDs": ["comment3", "comment4"]]
        ]
        initializeCollection(collectionName: "Deals", initialData: dealsData) { error in
            if let error = error {
                print("Error initializing Deals collection: \(error.localizedDescription)")
            } else {
                print("Deals collection initialized successfully!")
            }
        }

        // Initialize UserComments collection
        let userCommentsData: [[String: Any]] = [
            ["commentID": "comment1", "userId": "user1", "commentText": "Great deal!", "upvote": 50, "downvote": 2, "Type": 0],  // Type 0 for Deals
            ["commentID": "comment2", "userId": "user1", "commentText": "Nice product!", "upvote": 30, "downvote": 1, "Type": 0],
            ["commentID": "comment3", "userId": "user2", "commentText": "Barcode item is awesome!", "upvote": 80, "downvote": 1, "Type": 1],  // Type 1 for BarcodeItem
            ["commentID": "comment4", "userId": "user2", "commentText": "Could be cheaper.", "upvote": 25, "downvote": 5, "Type": 1]
        ]
        initializeCollection(collectionName: "UserComments", initialData: userCommentsData) { error in
            if let error = error {
                print("Error initializing UserComments collection: \(error.localizedDescription)")
            } else {
                print("UserComments collection initialized successfully!")
            }
        }

        // Initialize ReviewStars collection
        let reviewStarsData: [[String: Any]] = [
            ["userId": "user1", "barcodeNumber": "1234567890123", "reviewStars": 4.5],
            ["userId": "user2", "barcodeNumber": "9876543210987", "reviewStars": 3.7]
        ]
        initializeCollection(collectionName: "ReviewStars", initialData: reviewStarsData) { error in
            if let error = error {
                print("Error initializing ReviewStars collection: \(error.localizedDescription)")
            } else {
                print("ReviewStars collection initialized successfully!")
            }
        }

        // Initialize BarcodedItemReviews collection
        let barcodedItemReviewsData: [[String: Any]] = [
            ["userId": "user1", "photoURL": "https://example.com/photo_review_1.jpg", "barcodeNumber": "1234567890123", "reviewStars": 4.5, "productName": "Product 1", "commentIDs": ["comment1", "comment3"]],
            ["userId": "user2", "photoURL": "https://example.com/photo_review_2.jpg", "barcodeNumber": "9876543210987", "reviewStars": 3.7, "productName": "Product 2", "commentIDs": ["comment2", "comment4"]]
        ]
        initializeCollection(collectionName: "BarcodedItemReviews", initialData: barcodedItemReviewsData) { error in
            if let error = error {
                print("Error initializing BarcodedItemReviews collection: \(error.localizedDescription)")
            } else {
                print("BarcodedItemReviews collection initialized successfully!")
            }
        }
    }

    // MARK: - API Helpers

    /**
     Creates a Firestore document if it does not already exist.
     
     - Parameters:
        - collectionName: The name of the Firestore collection.
        - documentID: The ID of the document.
        - data: The data to set for the document.
        - completion: A closure that returns an optional error if something goes wrong during document creation.
     */
    func createDocumentIfNotExists(collectionName: String, documentID: String, data: [String: Any], completion: @escaping (Error?) -> Void) {
        db.collection(collectionName).document(documentID).getDocument { (documentSnapshot, error) in
            if let document = documentSnapshot, document.exists {
                completion(nil)  // No need to create if it already exists.
            } else {
                self.db.collection(collectionName).document(documentID).setData(data) { error in
                    completion(error)
                }
            }
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
    func readDocument(collectionName: String, documentID: String, completion: @escaping ([String: Any]?, Error?) -> Void) {
        db.collection(collectionName).document(documentID).getDocument { (documentSnapshot, error) in
            if let document = documentSnapshot, document.exists {
                completion(document.data(), nil)
            } else {
                completion(nil, error)
            }
        }
    }

    // MARK: - Structure Templates

    /**
     Returns a dictionary template for UserProfile structure.
     
     - Parameters:
        - userId: The user's unique ID.
        - email: The user's email.
        - password: The user's encrypted password.
        - displayName: The user's display name.
        - avatarURL: The URL to the user's avatar image.
     
     - Returns: A dictionary representing a user profile.
     */
    func getUserProfileTemplate(userId: String, email: String, password: String, displayName: String, avatarURL: String = "") -> [String: Any] {
        return [
            "email": email,
            "password": password,  // This should be hashed before saving.
            "displayName": displayName,
            "userId": userId,
            "avatarURL": avatarURL
        ]
    }

    /**
     Returns a dictionary template for Deals structure.
     
     - Parameters:
        - postID: The deal's unique post ID.
        - userId: The user who posted the deal.
        - photoURL: URL to the deal's photo.
        - productText: Short text about the product.
        - postText: Details about the deal.
        - price: The deal's price.
        - location: The deal's store location.
        - date: The date the deal was posted.
        - upvote: The upvotes for the deal.
        - downvote: The downvotes for the deal.
        - commentIDs: List of associated comment IDs.
     
     - Returns: A dictionary representing a deal.
     */
    func getDealsTemplate(postID: String, userId: String, photoURL: String, productText: String, postText: String, price: Float, location: String, date: String, upvote: Int, downvote: Int, commentIDs: [String]) -> [String: Any] {
        return [
            "postID": postID,
            "userId": userId,
            "photoURL": photoURL,
            "productText": productText,
            "postText": postText,
            "price": price,
            "location": location,
            "date": date,
            "upvote": upvote,
            "downvote": downvote,
            "commentIDs": commentIDs
        ]
    }

    /**
     Returns a dictionary template for UserComments structure.
     
     - Parameters:
        - commentID: The comment's unique ID.
        - userId: The user who made the comment.
        - commentText: The text of the comment.
        - upvote: The number of upvotes for the comment.
        - downvote: The number of downvotes for the comment.
        - type: Type of comment (0 for Deal, 1 for BarcodeItem).
     
     - Returns: A dictionary representing a user comment.
     */
    func getUserCommentsTemplate(commentID: String, userId: String, commentText: String, upvote: Int, downvote: Int, type: Int) -> [String: Any] {
        return [
            "commentID": commentID,
            "userId": userId,
            "commentText": commentText,
            "upvote": upvote,
            "downvote": downvote,
            "Type": type
        ]
    }

    /**
     Returns a dictionary template for ReviewStars structure.
     
     - Parameters:
        - userId: The user's unique ID.
        - barcodeNumber: The barcode number of the product.
        - reviewStars: The review score (1-5).
     
     - Returns: A dictionary representing a review star rating.
     */
    func getReviewStarsTemplate(userId: String, barcodeNumber: String, reviewStars: Double) -> [String: Any] {
        return [
            "userId": userId,
            "barcodeNumber": barcodeNumber,
            "reviewStars": reviewStars
        ]
    }

    /**
     Returns a dictionary template for BarcodedItemReviews structure.
     
     - Parameters:
        - userId: The user's unique ID.
        - photoURL: URL to the product review photo.
        - barcodeNumber: The barcode number of the product.
        - reviewStars: The review score (1-5).
        - productName: The product's name.
        - commentIDs: List of associated comment IDs.
     
     - Returns: A dictionary representing a barcoded item review.
     */
    func getBarcodedItemReviewsTemplate(userId: String, photoURL: String, barcodeNumber: String, reviewStars: Double, productName: String, commentIDs: [String]) -> [String: Any] {
        return [
            "userId": userId,
            "photoURL": photoURL,
            "barcodeNumber": barcodeNumber,
            "reviewStars": reviewStars,
            "productName": productName,
            "commentIDs": commentIDs
        ]
    }
}
