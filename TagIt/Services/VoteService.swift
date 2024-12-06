import FirebaseFirestore

/**
 A service responsible for handling vote-related operations for different types of items within the TagIt application.

 This service provides functionalities to manage upvotes and downvotes for items such as comments, deals, and reviews.
 It ensures that votes are accurately recorded, updated, and reflected in the corresponding item's vote counts.
 */
class VoteService {
    /**
     The shared singleton instance of `VoteService`.

     This ensures that a single, consistent instance of the service is used throughout the application.
     */
    static let shared = VoteService()

    /**
     Private initializer to enforce the singleton pattern.

     Prevents the creation of multiple instances of `VoteService`.
     */
    private init() {}

    /**
     Handles voting logic for upvoting or downvoting an item. If the user has already voted with the same vote type, it removes the vote (undo).
     If the vote type is opposite, it updates the vote, and if there is no existing vote, it creates a new one.

     - Parameters:
        - userId: The unique identifier for the user casting the vote.
        - itemId: The unique identifier for the item being voted on.
        - itemType: The type of item being voted on (e.g., comment, deal, review).
        - voteType: The type of vote being cast (`.upvote` or `.downvote`).
        - completion: A completion handler that returns a `Result<Void, Error>` indicating success or failure.

     This function manages the voting process by checking existing votes and updating Firestore accordingly.
     */
    func handleVote(userId: String, itemId: String, itemType: Vote.ItemType, voteType: Vote.VoteType, completion: @escaping (Result<Void, Error>) -> Void) {
        let voteId = "\(userId)_\(itemId)_\(itemType.rawValue)"
        print("[DEBUG] Handling vote with voteId: \(voteId), userId: \(userId), itemId: \(itemId), itemType: \(itemType), voteType: \(voteType))")

        getUserVote(userId: userId, itemId: itemId, itemType: itemType) { result in
            switch result {
            case let .success(existingVote):
                if let existingVote {
                    if existingVote.voteType == voteType {
                        // Undo vote
                        self.removeVote(userId: userId, itemId: itemId, itemType: itemType) { result in
                            if case .success = result, voteType == .upvote {
                                self.updateVoteCountsForItem(itemId: itemId, itemType: itemType, increment: false)
                            }
                            completion(result)
                        }
                    } else {
                        // Change vote
                        self.saveVote(voteId: voteId, userId: userId, itemId: itemId, voteType: voteType, itemType: itemType) { result in
                            if case .success = result {
                                self.updateVoteCountsForItem(itemId: itemId, itemType: itemType, increment: voteType == .upvote)
                            }
                            completion(result)
                        }
                    }
                } else {
                    // New vote
                    self.saveVote(voteId: voteId, userId: userId, itemId: itemId, voteType: voteType, itemType: itemType) { result in
                        if case .success = result, voteType == .upvote {
                            self.updateVoteCountsForItem(itemId: itemId, itemType: itemType, increment: true)
                        }
                        completion(result)
                    }
                }
            case .failure:
                // Assume the vote doesn't exist, so create it
                print("[DEBUG] Vote document doesn't exist, creating new vote with voteId: \(voteId)")
                self.saveVote(voteId: voteId, userId: userId, itemId: itemId, voteType: voteType, itemType: itemType) { result in
                    if case .success = result, voteType == .upvote {
                        self.updateVoteCountsForItem(itemId: itemId, itemType: itemType, increment: true)
                    }
                    completion(result)
                }
            }
        }
    }

    /**
     Updates the vote counts for a specific item based on the vote action.

     - Parameters:
        - itemId: The unique identifier for the item whose vote counts are to be updated.
        - itemType: The type of item being updated (e.g., comment, deal, review).
        - increment: A boolean indicating whether to increment (`true`) or decrement (`false`) the vote count.

     This function updates the `totalUpvotes` field for the associated user based on the vote action.
     */
    private func updateVoteCountsForItem(itemId: String, itemType: Vote.ItemType, increment: Bool) {
        let incrementValue = increment ? 1 : -1

        switch itemType {
        case .deal:
            FirestoreService.shared.readDocument(
                collectionName: FirestoreCollections.deals,
                documentID: itemId,
                modelType: Deal.self
            ) { result in
                switch result {
                case let .success(deal):
                    print("[DEBUG] Fetched deal \(deal.id ?? "unknown") for updating vote counts")
                    FirestoreService.shared.updateField(
                        collectionName: FirestoreCollections.user,
                        documentID: deal.userID,
                        field: "totalUpvotes",
                        value: FieldValue.increment(Int64(incrementValue))
                    ) { error in
                        if let error {
                            print("[DEBUG] Error updating totalUpvotes for user: \(error.localizedDescription)")
                        } else {
                            print("[DEBUG] Successfully updated totalUpvotes for user \(deal.userID)")
                        }
                    }
                case let .failure(error):
                    print("[DEBUG] Error fetching deal for vote count update: \(error.localizedDescription)")
                }
            }

        case .comment:
            FirestoreService.shared.readDocument(
                collectionName: FirestoreCollections.userComm,
                documentID: itemId,
                modelType: UserComments.self
            ) { result in
                switch result {
                case let .success(comment):
                    print("[DEBUG] Fetched comment \(comment.id ?? "unknown") for updating vote counts")
                    FirestoreService.shared.updateField(
                        collectionName: FirestoreCollections.user,
                        documentID: comment.userID,
                        field: "totalUpvotes",
                        value: FieldValue.increment(Int64(incrementValue))
                    ) { error in
                        if let error {
                            print("[DEBUG] Error updating totalUpvotes for user: \(error.localizedDescription)")
                        } else {
                            print("[DEBUG] Successfully updated totalUpvotes for user \(comment.userID)")
                        }
                    }
                case let .failure(error):
                    print("[DEBUG] Error fetching comment for vote count update: \(error.localizedDescription)")
                }
            }

        default:
            print("[DEBUG] Unsupported item type for vote count update")
        }
    }

    /**
     Saves a user's vote for a specific item in Firestore.

     - Parameters:
        - voteId: A unique identifier for the vote, typically combining user ID, item ID, and item type.
        - userId: The unique identifier for the user casting the vote.
        - itemId: The unique identifier for the item being voted on.
        - voteType: The type of vote being cast (`.upvote` or `.downvote`).
        - itemType: The type of item being voted on (e.g., comment, deal, review).
        - completion: A completion handler that returns a `Result<Void, Error>` indicating success or failure.

     This function creates a `Vote` object and stores it in the Firestore `votes` collection.
     */
    func saveVote(voteId: String, userId: String, itemId: String, voteType: Vote.VoteType, itemType: Vote.ItemType, completion: @escaping (Result<Void, Error>) -> Void) {
        let vote = Vote(userId: userId, itemId: itemId, voteType: voteType, itemType: itemType)
        print("[DEBUG] Saving vote with ID \(voteId): \(vote)")

        FirestoreService.shared.createDocument(
            collectionName: FirestoreCollections.votes,
            documentID: voteId,
            data: vote
        ) { error in
            if let error {
                print("[DEBUG] Error saving vote: \(error.localizedDescription)")
                completion(.failure(error))
            } else {
                print("[DEBUG] Vote saved successfully: \(voteId)")
                completion(.success(()))
            }
        }
    }

    /**
     Fetches the user's vote for a specific item from Firestore.

     - Parameters:
        - userId: The unique identifier for the user.
        - itemId: The unique identifier for the item being voted on.
        - itemType: The type of item being voted on (e.g., comment, deal, review).
        - completion: A completion handler that returns a `Result<Vote?, Error>` indicating success or failure. The result is `nil` if no vote exists.

     This function queries the Firestore `votes` collection to find an existing vote by the user for the specified item.
     */
    func getUserVote(userId: String, itemId: String, itemType _: Vote.ItemType, completion: @escaping (Result<Vote?, Error>) -> Void) {
        print("[DEBUG] Fetching vote with userID: \(userId) and itemID: \(itemId)")

        Firestore.firestore().collection(FirestoreCollections.votes)
            .whereField("itemId", isEqualTo: itemId)
            .whereField("userId", isEqualTo: userId)
            .getDocuments { snapshot, error in
                if let error {
                    print("[DEBUG] Fetching vote fails")
                    completion(.failure(error))
                } else if let snapshot {
                    let vote = snapshot.documents.compactMap { doc in
                        try? doc.data(as: Vote.self)
                    }.first

                    print("[DEBUG] Fetching vote successfully \(vote)")

                    completion(.success(vote))
                }
            }
    }

    /**
     Removes a user's vote for a specific item from Firestore.

     - Parameters:
        - userId: The unique identifier for the user.
        - itemId: The unique identifier for the item.
        - itemType: The type of item being voted on (e.g., comment, deal, review).
        - completion: A completion handler that returns a `Result<Void, Error>` indicating success or failure.

     This function deletes the vote document from the Firestore `votes` collection based on the constructed `voteId`.
     */
    func removeVote(userId: String, itemId: String, itemType: Vote.ItemType, completion: @escaping (Result<Void, Error>) -> Void) {
        let voteId = "\(userId)_\(itemId)_\(itemType.rawValue)"

        FirestoreService.shared.deleteDocument(
            collectionName: FirestoreCollections.votes,
            documentID: voteId
        ) { error in
            if let error {
                print("Error removing vote: \(error.localizedDescription)")
                completion(.failure(error))
            } else {
                print("Vote removed successfully for item: \(itemId)")
                completion(.success(()))
            }
        }
    }

    /**
     Retrieves the vote counts (upvotes and downvotes) for a specific item from Firestore.

     - Parameters:
        - itemId: The unique identifier for the item whose vote counts are to be retrieved.
        - itemType: The type of item being queried (e.g., comment, deal, review).
        - completion: A closure that returns a `Result<(upvotes: Int, downvotes: Int), Error>` indicating success or failure.

     This function queries the Firestore `votes` collection to count the number of upvotes and downvotes for the specified item.
     */
    func getVoteCounts(itemId: String, itemType: Vote.ItemType, completion: @escaping (Result<(upvotes: Int, downvotes: Int), Error>) -> Void) {
        FirestoreService.shared.readCollection(collectionName: FirestoreCollections.votes, modelType: Vote.self) { result in
            switch result {
            case let .success(votes):
                let upvotes = votes.filter { $0.itemId == itemId && $0.itemType == itemType && $0.voteType == .upvote }.count
                let downvotes = votes.filter { $0.itemId == itemId && $0.itemType == itemType && $0.voteType == .downvote }.count
                completion(.success((upvotes: upvotes, downvotes: downvotes)))
            case let .failure(error):
                print("Error fetching votes: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }
}
