//
//  UserService.swift
//  TagIt
//
//  Created by 何斯鹏 on 2024-10-16.
//

import FirebaseFirestore
import Foundation

/**
 A service responsible for managing user-related functionalities within the TagIt application.

 This service provides functionalities to fetch user profiles, update user information such as username and avatar,
 and manage the user's saved deals. It utilizes Firestore for all database operations related to user data.
 */
class UserService: ObservableObject {
    /**
     The shared singleton instance of `UserService`.

     This ensures that a single, consistent instance of the service is used throughout the application.
     */
    static let shared = UserService()

    /**
     The Firestore database instance used for all database operations.

     This instance facilitates interactions with Firestore collections and documents related to users.
     */
    private let db = Firestore.firestore()

    /**
     The current user's profile.

     This property is published to allow SwiftUI views to reactively update when the user profile changes.
     */
    @Published var userProfile: UserProfile?

    /**
     The error message to be displayed in case of any failures during user-related operations.

     This property is published to allow SwiftUI views to reactively display error messages.
     */
    @Published var errorMessage: String?

    /**
     A flag indicating whether a user-related operation is currently in progress.

     This property is published to allow SwiftUI views to show loading indicators when necessary.
     */
    @Published var isLoading: Bool = false

    /**
     Fetches a user by their ID.

     - Parameters:
        - id: The ID of the user to fetch.
        - completion: A closure that returns a `Result` containing `UserProfile` on success or an `Error` on failure.

     This function retrieves the user's profile from Firestore based on the provided user ID.
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

     This function updates the `displayName` field of the user's document in Firestore.
     */
    func updateUsername(userId: String, newUsername: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let userRef = db.collection(FirestoreCollections.user).document(userId)

        userRef.updateData([
            "displayName": newUsername,
        ]) { error in
            if let error {
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

     This function updates the `avatarURL` field of the user's document in Firestore.
     */
    func updateAvatar(userId: String, avatarURL: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let userRef = db.collection(FirestoreCollections.user).document(userId)

        userRef.updateData([
            "avatarURL": avatarURL,
        ]) { error in
            if let error {
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
        - completion: A closure that returns a `Result` containing `Void` on success or an `Error` on failure.

     This function appends the specified deal ID to the `savedDeals` array of the user's document in Firestore.
     */
    func addSavedDealToUserProfile(userID: String, dealID: String, completion: @escaping (Result<Void, Error>) -> Void) {
        db.collection(FirestoreCollections.user)
            .document(userID)
            .updateData([
                "savedDeals": FieldValue.arrayUnion([dealID]),
            ]) { error in
                if let error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
    }
}
