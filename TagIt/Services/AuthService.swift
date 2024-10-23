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
    
    private var currentUserProfile: UserProfile? = nil
    
    private init() {}
    
    func getCurrentUser(completion: @escaping (UserProfile?) -> Void) {
        if let profile = currentUserProfile {
            completion(profile)
        } else {
            fetchUser { profile in
                completion(profile)
            }
        }
    }
    
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
            self.fetchUser(){_ in
                print("User fetched")
            }
            completion(.success(userId))
        }
    }
    
    // Register a new user with email and password
    func registerUser(withEmail email: String, password: String, displayName: String, completion: @escaping (Result<String, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) {[weak self] result, error in
            if let error = error {
                completion(.failure(error)) // Return the error if registration fails
                return
            }
            
            guard let userId = result?.user.uid else {
                completion(.failure(NSError(domain: "RegistrationError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to get user ID"])))
                return
            }
            
            self?.insertUserRecord(id: userId, displayName: displayName, email: email, avatarURL: "")
            self?.fetchUser(){_ in
                print("User fetched")
            }
            completion(.success(userId)) // Registration successful, return userId
        }
    }
    
    // Function to create a dummy user (with a known email and password)
    func createDummyUser(withEmail email: String, password: String, displayName: String, avatarURL: String?, completion: @escaping (Result<String, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error)) // Return the error if registration fails
                return
            }
            
            guard let userId = result?.user.uid else {
                completion(.failure(NSError(domain: "RegistrationError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to get user ID"])))
                return
            }
            
            // Insert the user profile data into Firestore after registration
            self.insertUserRecord(id: userId, displayName: displayName, email: email, avatarURL: avatarURL)
            completion(.success(userId)) // Return userId if successful
        }
    }
    
    // Insert a new user record in Firestore
    private func insertUserRecord(id: String, displayName: String, email: String, avatarURL: String?) {
        let newUser = UserProfile(userId: id, email: email, displayName: displayName, avatarURL: avatarURL )
        let db = Firestore.firestore()
        
        db.collection("UserProfile")
            .document(id)
            .setData(newUser.asDictionary())
    }
    
    private func fetchUser(completion: @escaping (UserProfile?) -> Void) {
        let db = Firestore.firestore()
        
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(nil)
            return
        }
        
        let userDoc = db.collection("UserProfile").document(userId)
        
        userDoc.getDocument { [weak self] snapshot, error in
            if let error = error {
                print("Error fetching user profile: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            if let snapshot = snapshot, snapshot.exists {
                do {
                    self?.currentUserProfile = try snapshot.data(as: UserProfile.self)
                    completion(self?.currentUserProfile)
                } catch {
                    print("Error decoding user profile: \(error.localizedDescription)")
                    completion(nil)
                }
            } else {
                print("User profile does not exist.")
                completion(nil)
            }
        }
    }
}

enum AuthError: Error {
    case wrongPassword
    case userNotFound
    case invalidEmail
    case unknownError
    case invalidCredential
    
    static func from(error: Error) -> AuthError {
        let nsError = error as NSError
        print(nsError)
        switch nsError.code {
        case AuthErrorCode.wrongPassword.rawValue:
            return .wrongPassword
        case AuthErrorCode.userNotFound.rawValue:
            return .userNotFound
        case AuthErrorCode.invalidEmail.rawValue:
            return .invalidEmail
        case AuthErrorCode.invalidCredential.rawValue:
            return .invalidCredential
        default:
            return .unknownError
        }
    }
    
    var localizedDescription: String {
        switch self {
        case .wrongPassword, .userNotFound, .invalidEmail, .invalidCredential:
            return "Invalid credentials. Please check your email and password."
        case .unknownError:
            return "An unknown error occurred. Please try again."
        }
    }
}
