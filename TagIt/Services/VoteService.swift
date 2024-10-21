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
        let voteId = "\(userId)_\(itemId)_\(itemType)" // Unique identifier for each vote (userId + itemId + itemType)
        
        // Check if the user has already voted on this item
        getUserVote(userId: userId, itemId: itemId, itemType: itemType) { result in
            switch result {
            case .success(let existingVote):
                if let existingVote = existingVote {
                    if existingVote.voteType == voteType {
                        // If the user clicks the same vote type again, undo the vote (delete it)
                        FirestoreService.shared.deleteDocument(collectionName: FirestoreCollections.votes, documentID: voteId) { error in
                            if let error = error {
                                completion(.failure(error))
                            } else {
                                print("Vote removed successfully")
                                completion(.success(()))
                            }
                        }
                    } else {
                        // If the user clicks the opposite vote, update the vote to the new type
                        let updatedVote = Vote(userId: userId, itemId: itemId, voteType: voteType, itemType: itemType)
                        FirestoreService.shared.createDocument(collectionName: FirestoreCollections.votes, documentID: voteId, data: updatedVote) { error in
                            if let error = error {
                                completion(.failure(error))
                            } else {
                                print("Vote updated successfully")
                                completion(.success(()))
                            }
                        }
                    }
                } else {
                    // If no vote exists, create a new vote
                    let newVote = Vote(userId: userId, itemId: itemId, voteType: voteType, itemType: itemType)
                    FirestoreService.shared.createDocument(collectionName: FirestoreCollections.votes, documentID: voteId, data: newVote) { error in
                        if let error = error {
                            completion(.failure(error))
                        } else {
                            print("Vote created successfully")
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
        let voteId = "\(userId)_\(itemId)_\(itemType)"
        
        // Read the user's vote document from the "Votes" collection
        FirestoreService.shared.readDocument(collectionName: FirestoreCollections.votes, documentID: voteId, modelType: Vote.self) { result in
            switch result {
            case .success(let vote):
                completion(.success(vote)) // Successfully fetched the vote
            case .failure(let error):
                completion(.failure(error)) // Failed to fetch the vote
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
}
