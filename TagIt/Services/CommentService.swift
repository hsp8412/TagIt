//
//  CommentService.swift
//  TagIt
//
//  Created by Peter Tran on 2024-10-21.
//

import Foundation
import FirebaseFirestore

/// Service class responsible for handling comment-related operations, such as fetching, adding, and retrieving comments from Firestore.
class CommentService {
    static let shared = CommentService()
    
    private let db = Firestore.firestore()
    
    /**
     Fetches all comments from Firestore.
     
     - Parameters:
        - completion: A closure that returns a `Result` containing an array of `UserComments` on success or an `Error` on failure.
     */
    func getComments(completion: @escaping (Result<[UserComments], Error>) -> Void) {
        db.collection(FirestoreCollections.userComm)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error)) // Return failure if an error occurs
                } else if let snapshot = snapshot {
                    let comments = snapshot.documents.compactMap { doc -> UserComments? in
                        try? doc.data(as: UserComments.self)
                    }
                    completion(.success(comments)) // Return the array of comments on success
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
                if let error = error {
                    completion(.failure(error)) // Return failure if an error occurs
                } else if let snapshot = snapshot, let comment = try? snapshot.data(as: UserComments.self) {
                    completion(.success(comment)) // Return the comment on success
                } else {
                    completion(.failure(NSError(domain: "CommentService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Comment not found"])))
                }
            }
    }
    
    /**
     Adds a new comment to Firestore.
     
     - Parameters:
        - newComment: The `UserComments` object representing the new comment.
        - completion: A closure that returns a `Result<Void, Error>` indicating success or failure.
     */
    func addComment(newComment: UserComments, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            let _ = try db.collection(FirestoreCollections.userComm).addDocument(from: newComment)
            completion(.success(())) // Successfully added the comment
        } catch let error {
            completion(.failure(error)) // Return failure if an error occurs during the addition
        }
    }
}
