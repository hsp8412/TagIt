//
//  AuthService.swift
//  TagIt
//
//  Created by 何斯鹏 on 2024-10-16.
//

import FirebaseAuth
import Foundation
import FirebaseFirestore

class AuthService {
    static let shared = AuthService()
    
    private init() {}
    
    // Function to add an Auth state change listener
    func addAuthStateChangeListener(completion: @escaping (_ userId: String?) -> Void) -> AuthStateDidChangeListenerHandle {
        return Auth.auth().addStateDidChangeListener { _, user in
            DispatchQueue.main.async {
                completion(user?.uid)
            }
        }
    }
    
    // Function to check if a user is signed in
    func isSignedIn() -> Bool {
        return Auth.auth().currentUser != nil
    }
    
    
    // Function to log in a user with email and password
    func loginUser(withEmail email: String, password: String, completion: @escaping (Result<String, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completion(.failure(error)) // Return the error to the ViewModel
                return
            }
            guard let userId = authResult?.user.uid else {
                // If no user ID is returned, return an error
                completion(.failure(NSError(domain: "LoginError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to get user ID"])))
                return
            }
            completion(.success(userId)) // Return the user ID on success
        }
    }
    
    // Register a new user with email and password
    func registerUser(withEmail email: String, password: String, displayName: String, avatarURL:String, completion: @escaping (String?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            guard let userId = result?.user.uid else {
                completion(nil) // Registration failed
                return
            }
            self.insertUserRecord(id: userId, displayName: displayName, email: email, avatarURL: "")
            completion(userId) // Registration successful
        }
    }
    
    // Insert a new user record in Firestore
    private func insertUserRecord(id: String, displayName: String, email: String, avatarURL: String) {
        let newUser = User(id: id, email: email, displayName: displayName,avatarURL: avatarURL )
        let db = Firestore.firestore()
        
        db.collection("users")
            .document(id)
            .setData(newUser.asDictionary())
    }
}
