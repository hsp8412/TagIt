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
        let voteId = "\(userId)_\(itemId)_\(itemType)"
        
        // Fetch the existing vote
        getUserVote(userId: userId, itemId: itemId, itemType: itemType) { result in
            switch result {
            case .success(let existingVote):
                if let existingVote = existingVote {
                    if existingVote.voteType == voteType {
                        // Undo vote
                        print("User is undoing their vote: \(voteType.rawValue) for item: \(itemId)")
                        self.removeVote(userId: userId, itemId: itemId, itemType: itemType, completion: completion)
                    } else {
                        // Update vote
                        print("User is changing their vote to: \(voteType.rawValue) for item: \(itemId)")
                        self.saveVote(voteId: voteId, userId: userId, itemId: itemId, voteType: voteType, itemType: itemType, completion: completion)
                    }
                } else {
                    // Create new vote
                    print("User is casting a new vote: \(voteType.rawValue) for item: \(itemId)")
                    self.saveVote(voteId: voteId, userId: userId, itemId: itemId, voteType: voteType, itemType: itemType, completion: completion)
                }
            case .failure(let error):
                print("Error fetching user vote: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }
    
    private func saveVote(voteId: String, userId: String, itemId: String, voteType: Vote.VoteType, itemType: Vote.ItemType, completion: @escaping (Result<Void, Error>) -> Void) {
        let vote = Vote(userId: userId, itemId: itemId, voteType: voteType, itemType: itemType)
        FirestoreService.shared.createDocument(collectionName: FirestoreCollections.votes, documentID: voteId, data: vote) { error in
            if let error = error {
                print("Error saving vote: \(error.localizedDescription)")
                completion(.failure(error))
            } else {
                print("Vote saved successfully: \(voteType.rawValue) for item: \(itemId)")
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
        let voteId = "\(userId)_\(itemId)_\(itemType)"
        
        FirestoreService.shared.readDocument(collectionName: FirestoreCollections.votes, documentID: voteId, modelType: Vote.self) { result in
            switch result {
            case .success(let vote):
                completion(.success(vote))
            case .failure(let error):
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
        let voteId = "\(userId)_\(itemId)_\(itemType)"
        
        // Delete the user's vote document from the "Votes" collection
        FirestoreService.shared.deleteDocument(collectionName: FirestoreCollections.votes, documentID: voteId) { error in
            if let error = error {
                completion(.failure(error)) // Failed to delete the vote
            } else {
                completion(.success(())) // Vote deleted successfully
            }
        }
    }
    
    func getVoteCounts(itemId: String, itemType: Vote.ItemType, completion: @escaping (Result<(upvotes: Int, downvotes: Int), Error>) -> Void) {
        FirestoreService.shared.readCollection(collectionName: FirestoreCollections.votes) { result in
            switch result {
            case .success(let documents):
                var upvotes = 0
                var downvotes = 0

                // Decode votes and count
                for document in documents {
                    do {
                        let vote = try Firestore.Decoder().decode(Vote.self, from: document.data())
                        if vote.itemId == itemId && vote.itemType == itemType {
                            if vote.voteType == .upvote {
                                upvotes += 1
                            } else if vote.voteType == .downvote {
                                downvotes += 1
                            }
                        }
                    } catch {
                        print("Error decoding vote document: \(error.localizedDescription)")
                    }
                }
                
                print("Vote counts for item \(itemId): \(upvotes) upvotes, \(downvotes) downvotes")
                completion(.success((upvotes: upvotes, downvotes: downvotes)))
            case .failure(let error):
                print("Error fetching votes: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }



}
