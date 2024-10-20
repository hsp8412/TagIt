//
//  UserService.swift
//  TagIt
//
//  Created by 何斯鹏 on 2024-10-16.
//

import Foundation

class UserService: ObservableObject{
    @Published var userProfile: UserProfile?
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    
    func loadUserProfile(userId: String) {
        self.isLoading = true
        getUserById(id: userId) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let fetchedUser):
                    self.userProfile = fetchedUser
                case .failure(let error):
                    self.errorMessage = "Failed to load user profile: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func getUserById(id: String, completion: @escaping (Result<UserProfile, Error>) -> Void) {
        FirestoreService.shared.readDocument(collectionName: FirestoreCollections.user, documentID: id, modelType: UserProfile.self, completion: completion)
    }
    
    
}


