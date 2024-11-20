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
        
        // Fetch the vote first
        getUserVote(userId: userId, itemId: itemId, itemType: itemType) { result in
            switch result {
            case .success(let existingVote):
                if let existingVote = existingVote {
                    if existingVote.voteType == voteType {
                        // Undo vote
                        FirestoreService.shared.deleteDocument(collectionName: FirestoreCollections.votes, documentID: voteId) { error in
                            if let error = error {
                                completion(.failure(error))
                            } else {
                                completion(.success(()))
                            }
                        }
                    } else {
                        // Update vote
                        let updatedVote = Vote(userId: userId, itemId: itemId, voteType: voteType, itemType: itemType)
                        FirestoreService.shared.createDocument(collectionName: FirestoreCollections.votes, documentID: voteId, data: updatedVote) { error in
                            if let error = error {
                                completion(.failure(error))
                            } else {
                                completion(.success(()))
                            }
                        }
                    }
                } else {
                    // Create new vote
                    let newVote = Vote(userId: userId, itemId: itemId, voteType: voteType, itemType: itemType)
                    FirestoreService.shared.createDocument(collectionName: FirestoreCollections.votes, documentID: voteId, data: newVote) { error in
                        if let error = error {
                            completion(.failure(error))
                        } else {
                            completion(.success(()))
                        }
                    }
                }
            case .failure(let error):
                completion(.failure(error))
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
        
        FirestoreService.shared.readDocument(collectionName: FirestoreCollections.votes, documentID: voteId, modelType: Vote.self) { result in
            switch result {
            case .success(let vote):
                completion(.success(vote))
            case .failure(let error):
                let nsError = error as NSError
                if nsError.domain == "FirestoreError" && nsError.code == -1 {
                    // Document does not exist; return nil to indicate no existing vote
                    completion(.success(nil))
                } else {
                    print("Error decoding vote document: \(error.localizedDescription)")
                    print("Vote ID: \(voteId)")
                    completion(.failure(error))
                }
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
                // Decode documents into Vote objects
                let votes = documents.compactMap { document -> Vote? in
                    let data = document.data()
                    do {
                        return try Firestore.Decoder().decode(Vote.self, from: data)
                    } catch {
                        print("Error decoding vote document: \(error.localizedDescription)")
                        print("Document Data: \(data)")  // Add debugging for document data
                        return nil // Skip this document
                    }
                }

                // Filter votes by itemId and itemType
                let filteredVotes = votes.filter { $0.itemId == itemId && $0.itemType == itemType }
                
                // Count upvotes and downvotes
                let upvotes = filteredVotes.filter { $0.voteType == .upvote }.count
                let downvotes = filteredVotes.filter { $0.voteType == .downvote }.count
                
                completion(.success((upvotes: upvotes, downvotes: downvotes)))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }


}
