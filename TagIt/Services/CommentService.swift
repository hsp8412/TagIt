//
//  CommentService.swift
//  TagIt
//
//  Created by Peter Tran on 2024-10-21.
//
import FirebaseFirestore
import Foundation

/// Service class responsible for handling comment-related operations, such as fetching, adding, and retrieving comments from Firestore.
class CommentService {
    /// Shared singleton instance of `CommentService`.
    static let shared = CommentService()

    /// Firestore database reference.
    private let db = Firestore.firestore()

    private init() {}

    /**
     Fetches all comments from Firestore.

     - Parameters:
        - completion: A closure that returns a `Result` containing an array of `UserComments` on success or an `Error` on failure.
     */
    func getComments(completion: @escaping (Result<[UserComments], Error>) -> Void) {
        db.collection(FirestoreCollections.userComm)
            .order(by: "dateTime", descending: true) // Order comments by dateTime in descending order
            .getDocuments { snapshot, error in
                if let error {
                    print("[DEBUG] Error fetching comments: \(error.localizedDescription)")
                    completion(.failure(error))
                } else if let snapshot {
                    let comments = snapshot.documents.compactMap { doc -> UserComments? in
                        do {
                            var comment = try doc.data(as: UserComments.self)
                            if let timestamp = doc.get("dateTime") as? Timestamp {
                                // Convert `dateTime` to a human-readable string
                                comment.date = Utils.timeAgoString(from: timestamp)
                            } else {
                                comment.date = "Just now" // Fallback for missing timestamps
                            }
                            return comment
                        } catch {
                            print("Error decoding UserComments: \(error)")
                            return nil
                        }
                    }
                    print("[DEBUG] Fetched \(comments.count) comments")
                    completion(.success(comments))
                }
            }
    }

    /**
     Fetches a comment by its unique ID from Firestore.

     - Parameters:
        - id: The unique identifier for the comment.
        - completion: A closure that returns a `Result` containing `UserComments` on success or an `Error` on failure.
     */
    func getCommentById(id: String, completion: @escaping (Result<UserComments, Error>) -> Void) {
        db.collection(FirestoreCollections.userComm)
            .document(id)
            .getDocument { snapshot, error in
                if let error {
                    print("[DEBUG] Error fetching comment by ID: \(error.localizedDescription)")
                    completion(.failure(error))
                } else if let snapshot, var comment = try? snapshot.data(as: UserComments.self) {
                    if let timestamp = comment.dateTime {
                        comment.date = Utils.timeAgoString(from: timestamp)
                    }
                    print("[DEBUG] Fetched comment with ID \(id)")
                    completion(.success(comment))
                } else {
                    let error = NSError(domain: "CommentService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Comment not found"])
                    print("[DEBUG] Comment with ID \(id) not found")
                    completion(.failure(error))
                }
            }
    }

    /**
     Fetches all comments for a specific item from Firestore based on the provided item ID and comment type.

     - Parameters:
        - itemID: The unique identifier of the item.
        - commentType: The type of the comment (e.g., `.deal`, `.barcodeItemReview`).
        - completion: A closure that returns a `Result` containing an array of `UserComments` on success or an `Error` on failure.
     */
    func getCommentsForItem(itemID: String, completion: @escaping (Result<[UserComments], Error>) -> Void) {
        db.collection(FirestoreCollections.userComm)
            .whereField("itemID", isEqualTo: itemID)
            .order(by: "dateTime", descending: true) // Order by dateTime
            .getDocuments { snapshot, error in
                if let error {
                    print("[DEBUG] Error fetching comments for item \(itemID): \(error.localizedDescription)")
                    completion(.failure(error))
                } else if let snapshot {
                    let comments = snapshot.documents.compactMap { doc -> UserComments? in
                        do {
                            var comment = try doc.data(as: UserComments.self)
                            if let timestamp = doc.get("dateTime") as? Timestamp {
                                comment.date = Utils.timeAgoString(from: timestamp)
                            } else {
                                comment.date = "Just now"
                            }
                            return comment
                        } catch {
                            print("Error decoding UserComments: \(error)")
                            return nil
                        }
                    }
                    print("[DEBUG] Fetched \(comments.count) comments for item \(itemID)")
                    completion(.success(comments))
                }
            }
    }

    /**
     Adds a new comment to Firestore and updates the user's total comments and ranking points.

     - Parameters:
        - newComment: The `UserComments` object representing the new comment.
        - completion: A closure that returns a `Result<Void, Error>` indicating success or failure.
     */
    func addComment(newComment: UserComments, completion: @escaping (Result<Void, Error>) -> Void) {
        FirestoreService.shared.createDocument(
            collectionName: FirestoreCollections.userComm,
            documentID: newComment.id ?? UUID().uuidString,
            data: newComment
        ) { error in
            if let error {
                print("[DEBUG] Error adding comment: \(error.localizedDescription)")
                completion(.failure(error))
            } else {
                print("[DEBUG] Successfully added new comment")
                completion(.success(()))
            }
        }
    }

    /**
     Increments the `totalComments` field for a user in Firestore and updates their ranking points.

     - Parameters:
        - forUserId: The unique identifier of the user whose `totalComments` field needs to be updated.
        - completion: A closure that returns a `Result<Void, Error>` indicating success or failure.
     */
    private func incrementTotalComments(forUserId userId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        FirestoreService.shared.updateField(
            collectionName: FirestoreCollections.user,
            documentID: userId,
            field: "totalComments",
            value: FieldValue.increment(Int64(1))
        ) { error in
            if let error {
                print("[DEBUG] Error incrementing totalComments for user \(userId): \(error.localizedDescription)")
                completion(.failure(error))
            } else {
                print("[DEBUG] Incremented totalComments for user \(userId)")
                // Recalculate ranking points
                self.updateRankingPoints(forUserId: userId, completion: completion)
            }
        }
    }

    /**
     Updates the `rankingPoints` field for a user based on their updated statistics.

     - Parameters:
        - forUserId: The unique identifier of the user whose ranking points need to be updated.
        - completion: A closure that returns a `Result<Void, Error>` indicating success or failure.
     */
    private func updateRankingPoints(forUserId userId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        FirestoreService.shared.readDocument(
            collectionName: FirestoreCollections.user,
            documentID: userId,
            modelType: UserProfile.self
        ) { result in
            switch result {
            case let .success(user):
                let newRankingPoints = (user.totalDeals * 5) + user.totalUpvotes + user.totalComments
                FirestoreService.shared.updateField(
                    collectionName: FirestoreCollections.user,
                    documentID: userId,
                    field: "rankingPoints",
                    value: newRankingPoints
                ) { error in
                    if let error {
                        print("[DEBUG] Error updating rankingPoints for user \(userId): \(error.localizedDescription)")
                        completion(.failure(error))
                    } else {
                        print("[DEBUG] Successfully updated rankingPoints for user \(userId) to \(newRankingPoints)")
                        completion(.success(()))
                    }
                }
            case let .failure(error):
                print("[DEBUG] Error fetching user for rankingPoints update: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }

    /**
     Fetches all unique deals commented on by a specific user.

     - Parameters:
        - userID: The ID of the user whose unique commented deals are to be fetched.
        - completion: A closure that returns a `Result<Set<String>, Error>` with the set of unique `itemID`s (deals).
     */
    func getUniqueDealsCommentedByUser(userID: String, completion: @escaping (Result<Set<String>, Error>) -> Void) {
        db.collection(FirestoreCollections.userComm)
            .whereField("userID", isEqualTo: userID)
            .getDocuments { snapshot, error in
                if let error {
                    print("[DEBUG] Error fetching unique deals commented by user \(userID): \(error.localizedDescription)")
                    completion(.failure(error))
                } else if let snapshot {
                    // Extract unique itemIDs (deals) from comments
                    let uniqueDeals = Set(snapshot.documents.compactMap { $0.data()["itemID"] as? String })
                    print("[DEBUG] User \(userID) commented on \(uniqueDeals.count) unique deals.")
                    completion(.success(uniqueDeals))
                }
            }
    }
}
