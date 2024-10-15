//
//  UserManager.swift
//  TagIt
//
//  Created by Peter Tran on 2024-10-15.
//

import FirebaseFirestore

class UserManager {

    // Register a new user using FirebaseManager
    func registerUser(displayName: String, email: String, password: String, avatarURL: String = "", completion: @escaping (Bool, String?) -> Void) {
        // Generate a unique ID for the new user
        let userId = UUID().uuidString
        
        // Hash the password (this is an example, use a secure hashing method in production)
        let hashedPassword = hashPassword(password)
        
        // Get the user profile data structure using FirebaseManager's template
        let userProfileData = FirebaseManager.shared.getUserProfileTemplate(
            userId: userId,
            email: email,
            password: hashedPassword,  // Store the hashed password
            displayName: displayName,
            avatarURL: avatarURL
        )

        // Use FirebaseManager to create the user document in Firestore
        FirebaseManager.shared.createDocumentIfNotExists(collectionName: "UserProfile", documentID: userId, data: userProfileData) { error in
            if let error = error {
                // If there's an error creating the document, return false and the error message
                print("Error registering user: \(error.localizedDescription)")
                completion(false, error.localizedDescription)
            } else {
                // If successful, return true and the user ID
                print("User registered successfully!")
                completion(true, userId)
            }
        }
    }

    // A simple password hashing function (replace with a real hash function in production)
    private func hashPassword(_ password: String) -> String {
        return "hashed_\(password)"  // Example, replace with a real hash function
    }
}

