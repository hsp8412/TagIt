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
    
    
    func loginUser(withEmail email: String, password: String, completion: @escaping (Result<String, AuthError>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                let authError = AuthError.from(error: error)
                completion(.failure(authError))
                return
            }
            guard let userId = authResult?.user.uid else {
                completion(.failure(.unknownError))
                return
            }
            completion(.success(userId))
        }
    }
    
    // Register a new user with email and password
    func registerUser(withEmail email: String, password: String, displayName: String, completion: @escaping (Result<String, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error)) // Return the error if registration fails
                return
            }
            
            guard let userId = result?.user.uid else {
                completion(.failure(NSError(domain: "RegistrationError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to get user ID"])))
                return
            }
            
            self.insertUserRecord(id: userId, displayName: displayName, email: email, avatarURL: "")
            completion(.success(userId)) // Registration successful, return userId
        }
    }

    
    // Insert a new user record in Firestore
    private func insertUserRecord(id: String, displayName: String, email: String, avatarURL: String) {
        let newUser = User(id: id, email: email, displayName: displayName,avatarURL: avatarURL )
        let db = Firestore.firestore()
        
        db.collection("UserProfile")
            .document(id)
            .setData(newUser.asDictionary())
    }
}

enum AuthError: Error {
    case wrongPassword
    case userNotFound
    case invalidEmail
    case unknownError

    static func from(error: Error) -> AuthError {
        let nsError = error as NSError
        switch nsError.code {
        case AuthErrorCode.wrongPassword.rawValue:
            return .wrongPassword
        case AuthErrorCode.userNotFound.rawValue:
            return .userNotFound
        case AuthErrorCode.invalidEmail.rawValue:
            return .invalidEmail
        default:
            return .unknownError
        }
    }

    var localizedDescription: String {
        switch self {
        case .wrongPassword, .userNotFound, .invalidEmail:
            return "Invalid credentials. Please check your email and password."
        case .unknownError:
            return "An unknown error occurred. Please try again."
        }
    }
}
