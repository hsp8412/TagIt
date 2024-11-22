//
//  UserService.swift
//  TagIt
//
//  Created by 何斯鹏 on 2024-10-16.
//

import Foundation

class UserService: ObservableObject {
    // Singleton instance
    static let shared = UserService()

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
}
