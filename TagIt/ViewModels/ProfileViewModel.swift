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
