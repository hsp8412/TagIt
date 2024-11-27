//
//  DummyService.swift
//  TagIt
//
//  Created by Peter Tran on 2024-11-27.
//
import FirebaseFirestore

/// Service responsible for initializing Firestore collections with predefined data.
class DatabaseInitializationService {
    /// Shared instance of DatabaseInitializationService for global access.
    static let shared = DatabaseInitializationService()
    
    private let firestore = Firestore.firestore()

    /// Private initializer to enforce singleton usage.
    private init() {}

    /**
     Initializes predefined collections with initial data.
     
     - Parameters:
        - completion: A closure that returns a `Bool` indicating success or failure.
     */
    func initializeAllCollections(completion: @escaping (Bool) -> Void) {
        let group = DispatchGroup()

        // Create users first
        createDummyUsers(group: group)

        // After creating users, initialize other collections
        group.notify(queue: .main) {
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

    /**
     Creates dummy users and stores them in Firebase Auth and Firestore.
     
     - Parameters:
        - group: The `DispatchGroup` to track the completion of creating dummy users.
     */
    private func createDummyUsers(group: DispatchGroup) {
        group.enter()
        AuthService.shared.createDummyUser(withEmail: "user1@example.com", password: "password123", displayName: "User One", avatarURL: nil) { result in
            self.handleDummyUserResult(result, userNumber: 1)
            group.leave()
        }

        group.enter()
        AuthService.shared.createDummyUser(withEmail: "user2@example.com", password: "password123", displayName: "User Two", avatarURL: "https://example.com/avatar2.jpg") { result in
            self.handleDummyUserResult(result, userNumber: 2)
            group.leave()
        }
    }

    private func handleDummyUserResult(_ result: Result<String, Error>, userNumber: Int) {
        switch result {
        case .success(let userId):
            print("Created dummy user\(userNumber): \(userId)")
        case .failure(let error):
            print("Failed to create dummy user\(userNumber): \(error.localizedDescription)")
        }
    }

    // MARK: - Collection Initialization Functions

    private func initializeDealsCollection(group: DispatchGroup) {
        group.enter()
        let dealsData: [Deal] = [
            // Sample Deal objects
        ]
        initializeCollection(collectionName: FirestoreCollections.deals, initialData: dealsData) { error in
            self.logInitializationResult(collection: "Deals", error: error)
            group.leave()
        }
    }

    private func initializeBarcodeItemReviewCollection(group: DispatchGroup) {
        group.enter()
        let reviewsData: [BarcodeItemReview] = [
            // Sample BarcodeItemReview objects
        ]
        initializeCollection(collectionName: FirestoreCollections.revItem, initialData: reviewsData) { error in
            self.logInitializationResult(collection: "BarcodeItemReview", error: error)
            group.leave()
        }
    }

    private func initializeReviewStarsCollection(group: DispatchGroup) {
        group.enter()
        let reviewStarsData: [ReviewStars] = [
            // Sample ReviewStars objects
        ]
        initializeCollection(collectionName: FirestoreCollections.revStars, initialData: reviewStarsData) { error in
            self.logInitializationResult(collection: "ReviewStars", error: error)
            group.leave()
        }
    }

    private func initializeUserCommentsCollection(group: DispatchGroup) {
        group.enter()
        let commentsData: [UserComments] = [
            // Sample UserComments objects
        ]
        initializeCollection(collectionName: FirestoreCollections.userComm, initialData: commentsData) { error in
            self.logInitializationResult(collection: "UserComments", error: error)
            group.leave()
        }
    }

    private func initializeVotesCollection(group: DispatchGroup) {
        group.enter()
        let votesData: [Vote] = [
            // Sample Vote objects
        ]
        initializeCollection(collectionName: FirestoreCollections.votes, initialData: votesData) { error in
            self.logInitializationResult(collection: "Votes", error: error)
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
    private func initializeCollection<T: Codable>(collectionName: String, initialData: [T], completion: @escaping (Error?) -> Void) {
        let group = DispatchGroup()
        var finalError: Error? = nil

        for data in initialData {
            var documentID: String? = nil
            
            // Determine document ID based on the object type
            switch T.self {
            case is UserProfile.Type:
                documentID = (data as! UserProfile).id
            case is Deal.Type:
                documentID = (data as! Deal).id
            case is UserComments.Type:
                documentID = (data as! UserComments).id ?? UUID().uuidString
            case is BarcodeItemReview.Type:
                let review = data as! BarcodeItemReview
                documentID = review.id ?? "\(review.userID)_\(review.barcodeNumber)"
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
            firestore.collection(collectionName).document(documentID).setData(try! Firestore.Encoder().encode(data)) { error in
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

    // MARK: - Helper Functions

    private func logInitializationResult(collection: String, error: Error?) {
        if let error = error {
            print("Error initializing \(collection) collection: \(error.localizedDescription)")
        } else {
            print("\(collection) collection initialized successfully!")
        }
    }
}
