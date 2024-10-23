//
//  ProfileViewModel.swift
//  TagIt
//
//  Created by 何斯鹏 on 2024-10-16.
//

import Foundation
import FirebaseAuth

class ProfileViewModel:ObservableObject{
    @Published var isLoading = false;
    @Published var errorMessage:String? = nil;
    @Published var userProfile: UserProfile? = nil;
    
    init() {
        // Fetch the cached user from AuthService when the ViewModel is initialized
        fetchCachedUser()
    }
    
    func fetchCachedUser() {
        AuthService.shared.getCurrentUser(){profile in
            DispatchQueue.main.async {
                self.userProfile = profile
            }
        }
    }
    
    func logout(){
        errorMessage = nil
        isLoading = true
        do {
            try Auth.auth().signOut()
            isLoading = false
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
            errorMessage = "Error signing out"
            isLoading = false
        }
    }
}
