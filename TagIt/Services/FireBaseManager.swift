//
//  FireBaseManager.swift
//  TagIt
//
//  Created by Peter Tran on 2024-10-15.
//

import FirebaseFirestore

class FirebaseManager {
    static let shared = FirebaseManager()
    let db = Firestore.firestore()

    private init() {}

    // MARK: - Database Initialization

    // Function to initialize a collection with predefined data if not exists
    func initializeCollection(collectionName: String, initialData: [[String: Any]], completion: @escaping (Error?) -> Void) {
        let group = DispatchGroup()
        var finalError: Error? = nil

        for data in initialData {
            if let documentID = data["id"] as? String {
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

    // Function to initialize all necessary collections in the database
    func initializeAllCollections() {
        // UserProfile collection initialization
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

        // Deals collection initialization
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

        // UserComments collection initialization
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

        // ReviewStars collection initialization
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

        // BarcodedItemReviews collection initialization
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

    // Generic function to create a document if it doesn't exist
    func createDocumentIfNotExists(collectionName: String, documentID: String, data: [String: Any], completion: @escaping (Error?) -> Void) {
        db.collection(collectionName).document(documentID).getDocument { (documentSnapshot, error) in
            if let document = documentSnapshot, document.exists {
                completion(nil)  // No need to create if it already exists
            } else {
                self.db.collection(collectionName).document(documentID).setData(data) { error in
                    completion(error)
                }
            }
        }
    }

    // Generic function to update a field in a document
    func updateField(collectionName: String, documentID: String, field: String, value: Any, completion: @escaping (Error?) -> Void) {
        db.collection(collectionName).document(documentID).updateData([field: value]) { error in
            completion(error)
        }
    }

    // Generic function to read a document's data
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

    // Template for UserProfile structure
    func getUserProfileTemplate(userId: String, email: String, password: String, displayName: String, avatarURL: String = "") -> [String: Any] {
        return [
            "email": email,
            "password": password,  // This should be hashed before saving
            "displayName": displayName,
            "userId": userId,
            "avatarURL": avatarURL
        ]
    }

    // Template for Deals structure
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

    // Template for UserComments structure
    func getUserCommentsTemplate(commentID: String, userId: String, commentText: String, upvote: Int, downvote: Int, type: Int) -> [String: Any] {
        return [
            "commentID": commentID,
            "userId": userId,
            "commentText": commentText,
            "upvote": upvote,
            "downvote": downvote,
            "Type": type  // 0 for Deal, 1 for BarcodeItem
        ]
    }

    // Template for ReviewStars structure
    func getReviewStarsTemplate(userId: String, barcodeNumber: String, reviewStars: Double) -> [String: Any] {
        return [
            "userId": userId,
            "barcodeNumber": barcodeNumber,
            "reviewStars": reviewStars
        ]
    }

    // Template for BarcodedItemReviews structure
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

