//
//  UserService.swift
//  TagIt
//
//  Created by 何斯鹏 on 2024-10-16.
//

import Foundation
import FirebaseFirestore

class UserService: ObservableObject {
    // Singleton instance
    static let shared = UserService()
    private let db = Firestore.firestore()

    // Private initializer to prevent creating multiple instances
    private init() {}

    @Published var userProfile: UserProfile?
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false

    /**
     Fetches a user by their ID.
     
     - Parameters:
        - id: The ID of the user to fetch.
        - completion: A closure that returns a `Result` containing `UserProfile` on success or an `Error` on failure.
     */
    func getUserById(id: String, completion: @escaping (Result<UserProfile, Error>) -> Void) {
        FirestoreService.shared.readDocument(collectionName: FirestoreCollections.user, documentID: id, modelType: UserProfile.self, completion: completion)
    }



    /**
     Updates the username of the user in the Firestore database.
     
     - Parameters:
        - userId: The ID of the user whose username needs to be updated.
        - newUsername: The new username to be set.
        - completion: A closure that returns a `Result` indicating whether the update was successful or an error.
     */
    func updateUsername(userId: String, newUsername: String, completion: @escaping (Result<Void, Error>) -> Void) {

        
        let userRef = db.collection(FirestoreCollections.user).document(userId)

        userRef.updateData([
            "displayName": newUsername
        ]) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }

    /**
     Updates the avatar of the user in the Firestore database.
     
     - Parameters:
        - userId: The ID of the user whose avatar URL needs to be updated.
        - avatarURL: The new avatar URL to be set.
        - completion: A closure that returns a `Result` indicating whether the update was successful or an `Error` on failure.
     */
    func updateAvatar(userId: String, avatarURL: String, completion: @escaping (Result<Void, Error>) -> Void) {

        
        let userRef = db.collection(FirestoreCollections.user).document(userId)

        userRef.updateData([
            "avatarURL": avatarURL
        ]) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }

    /**
     Adds a deal ID to the user's savedDeals array in Firestore.
     
     - Parameters:
        - userID: The ID of the user whose profile needs to be updated.
        - dealID: The ID of the deal to be added to the savedDeals array.
        - completion: A closure that returns a Result containing Void on success or an Error on failure.
     */
    func addSavedDealToUserProfile(userID: String, dealID: String, completion: @escaping (Result<Void, Error>) -> Void) {
        db.collection(FirestoreCollections.user)
            .document(userID)
            .updateData([
                "savedDeals": FieldValue.arrayUnion([dealID])
            ]) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
    }
}
