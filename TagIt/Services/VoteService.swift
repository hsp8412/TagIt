import FirebaseFirestore

/// Service class responsible for handling vote-related operations for different types of items (comments, deals, reviews).
class VoteService {
    static let shared = VoteService()
    
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
     */
    func handleVote(userId: String, itemId: String, itemType: Vote.ItemType, voteType: Vote.VoteType, completion: @escaping (Result<Void, Error>) -> Void) {
        let voteId = "\(userId)_\(itemId)_\(itemType.rawValue)"
        print("[DEBUG] Handling vote with voteId: \(voteId), userId: \(userId), itemId: \(itemId), itemType: \(itemType), voteType: \(voteType)")

        getUserVote(userId: userId, itemId: itemId, itemType: itemType) { result in
            switch result {
            case .success(let existingVote):
                if let existingVote = existingVote {
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
                case .success(let deal):
                    print("[DEBUG] Fetched deal \(deal.id ?? "unknown") for updating vote counts")
                    FirestoreService.shared.updateField(
                        collectionName: FirestoreCollections.user,
                        documentID: deal.userID,
                        field: "totalUpvotes",
                        value: FieldValue.increment(Int64(incrementValue))
                    ) { error in
                        if let error = error {
                            print("[DEBUG] Error updating totalUpvotes for user: \(error.localizedDescription)")
                        } else {
                            print("[DEBUG] Successfully updated totalUpvotes for user \(deal.userID)")
                        }
                    }
                case .failure(let error):
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
                case .success(let comment):
                    print("[DEBUG] Fetched comment \(comment.id ?? "unknown") for updating vote counts")
                    FirestoreService.shared.updateField(
                        collectionName: FirestoreCollections.user,
                        documentID: comment.userID,
                        field: "totalUpvotes",
                        value: FieldValue.increment(Int64(incrementValue))
                    ) { error in
                        if let error = error {
                            print("[DEBUG] Error updating totalUpvotes for user: \(error.localizedDescription)")
                        } else {
                            print("[DEBUG] Successfully updated totalUpvotes for user \(comment.userID)")
                        }
                    }
                case .failure(let error):
                    print("[DEBUG] Error fetching comment for vote count update: \(error.localizedDescription)")
                }
            }
            
        default:
            print("[DEBUG] Unsupported item type for vote count update")
        }
    }



    
    func saveVote(voteId: String, userId: String, itemId: String, voteType: Vote.VoteType, itemType: Vote.ItemType, completion: @escaping (Result<Void, Error>) -> Void) {
        let vote = Vote(userId: userId, itemId: itemId, voteType: voteType, itemType: itemType)
        print("[DEBUG] Saving vote with ID \(voteId): \(vote)")
        
        FirestoreService.shared.createDocument(
            collectionName: FirestoreCollections.votes,
            documentID: voteId,
            data: vote
        ) { error in
            if let error = error {
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
        - completion: A completion handler that returns a `Result<Vote?, Error>`. The result is `nil` if no vote exists.
     */
    func getUserVote(userId: String, itemId: String, itemType: Vote.ItemType, completion: @escaping (Result<Vote?, Error>) -> Void) {
        let voteId = "\(userId)_\(itemId)_\(itemType.rawValue)"
        print("[DEBUG] Fetching vote with voteId: \(voteId)")

        FirestoreService.shared.readDocument(
            collectionName: FirestoreCollections.votes,
            documentID: voteId,
            modelType: Vote.self
        ) { result in
            switch result {
            case .success(let vote):
                print("[DEBUG] Successfully fetched vote: \(vote)")
                completion(.success(vote))
            case .failure(let error):
                print("[DEBUG] Error fetching vote: \(error.localizedDescription)")
                completion(.failure(error))
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
     */
    func removeVote(userId: String, itemId: String, itemType: Vote.ItemType, completion: @escaping (Result<Void, Error>) -> Void) {
        let voteId = "\(userId)_\(itemId)_\(itemType.rawValue)"
        
        FirestoreService.shared.deleteDocument(
            collectionName: FirestoreCollections.votes,
            documentID: voteId
        ) { error in
            if let error = error {
                print("Error removing vote: \(error.localizedDescription)")
                completion(.failure(error))
            } else {
                print("Vote removed successfully for item: \(itemId)")
                completion(.success(()))
            }
        }
    }
    
    func getVoteCounts(itemId: String, itemType: Vote.ItemType, completion: @escaping (Result<(upvotes: Int, downvotes: Int), Error>) -> Void) {
        FirestoreService.shared.readCollection(collectionName: FirestoreCollections.votes, modelType: Vote.self) { result in
            switch result {
            case .success(let votes):
                let upvotes = votes.filter { $0.itemId == itemId && $0.itemType == itemType && $0.voteType == .upvote }.count
                let downvotes = votes.filter { $0.itemId == itemId && $0.itemType == itemType && $0.voteType == .downvote }.count
                completion(.success((upvotes: upvotes, downvotes: downvotes)))
            case .failure(let error):
                print("Error fetching votes: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }



}
