//
//  AuthService.swift
//  TagIt
//
//  Created by 何斯鹏 on 2024-10-16.
//

import FirebaseAuth
import FirebaseFirestore
import Foundation

/// A service responsible for handling user authentication and profile management using Firebase Authentication and Firestore.
class AuthService {
    /// The shared singleton instance of `AuthService`.
    static let shared = AuthService()

    /// The currently authenticated user's profile. This is cached to minimize Firestore reads.
    private var currentUserProfile: UserProfile?

    /// Private initializer to enforce singleton usage.
    private init() {}

    /// Resets the cached current user profile.
    ///
    /// Use this method to clear the cached user profile, forcing a fresh fetch from Firestore on the next retrieval.
    func resetCurrentUserProfile() {
        currentUserProfile = nil
    }

    /// Retrieves the current authenticated user's profile.
    ///
    /// - Parameter completion: A closure that receives the `UserProfile` if available, or `nil` if the user is not authenticated or an error occurs.
    func getCurrentUser(completion: @escaping (UserProfile?) -> Void) {
        if let profile = currentUserProfile {
            completion(profile)
        } else {
            fetchUser { profile in
                completion(profile)
            }
        }
    }

    /// Retrieves the current authenticated user's ID.
    ///
    /// - Returns: The user's ID as a `String`, or `nil` if the user is not authenticated.
    func getCurrentUserID() -> String? {
        Auth.auth().currentUser?.uid
    }

    /// Adds an authentication state change listener.
    ///
    /// This listener notifies you whenever the user's sign-in state changes (e.g., sign-in or sign-out).
    ///
    /// - Parameter completion: A closure that receives the user's ID as a `String` if signed in, or `nil` if signed out.
    /// - Returns: A handle to the authentication state change listener, which can be used to remove the listener later.
    func addAuthStateChangeListener(completion: @escaping (_ userId: String?) -> Void) -> AuthStateDidChangeListenerHandle {
        Auth.auth().addStateDidChangeListener { _, user in
            DispatchQueue.main.async {
                completion(user?.uid)
            }
        }
    }

    /// Checks whether a user is currently signed in.
    ///
    /// - Returns: `true` if a user is signed in, otherwise `false`.
    func isSignedIn() -> Bool {
        Auth.auth().currentUser != nil
    }

    /// Logs in a user with the provided email and password.
    ///
    /// - Parameters:
    ///   - email: The user's email address.
    ///   - password: The user's password.
    ///   - completion: A closure that receives a `Result` containing the user's ID as a `String` on success or an `AuthError` on failure.
    func loginUser(withEmail email: String, password: String, completion: @escaping (Result<String, AuthError>) -> Void) {
        Auth.auth().signIn(withEmail: email,
                           password: password)
        { authResult, error in
            if let error {
                let authError = AuthError.from(error: error)
                completion(.failure(authError))
                return
            }
            guard let userId = authResult?.user.uid else {
                completion(.failure(.unknownError))
                return
            }
            self.fetchUser { _ in
                print("User fetched")
            }
            completion(.success(userId))
        }
    }

    /// Registers a new user with the provided email, password, and display name.
    ///
    /// - Parameters:
    ///   - email: The user's email address.
    ///   - password: The user's password.
    ///   - displayName: The display name for the user's profile.
    ///   - completion: A closure that receives a `Result` containing the user's ID as a `String` on success or an `Error` on failure.
    func registerUser(withEmail email: String, password: String, displayName: String, completion: @escaping (Result<String, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            if let error {
                completion(.failure(error)) // Return the error if registration fails
                return
            }

            guard let userId = result?.user.uid else {
                completion(.failure(NSError(domain: "RegistrationError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to get user ID"])))
                return
            }

            self?.insertUserRecord(id: userId, displayName: displayName, email: email, avatarURL: "")
            self?.fetchUser { _ in
                print("User fetched")
            }
            completion(.success(userId)) // Registration successful, return userId
        }
    }

    /// Creates a dummy user with the provided details. Useful for testing purposes.
    ///
    /// - Parameters:
    ///   - email: The dummy user's email address.
    ///   - password: The dummy user's password.
    ///   - displayName: The display name for the dummy user's profile.
    ///   - avatarURL: An optional URL string for the dummy user's avatar.
    ///   - completion: A closure that receives a `Result` containing the user's ID as a `String` on success or an `Error` on failure.
    func createDummyUser(withEmail email: String, password: String, displayName: String, avatarURL: String?, completion: @escaping (Result<String, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error {
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

    /// Inserts a new user record into Firestore.
    ///
    /// - Parameters:
    ///   - id: The user's unique identifier.
    ///   - displayName: The display name for the user's profile.
    ///   - email: The user's email address.
    ///   - avatarURL: An optional URL string for the user's avatar.
    private func insertUserRecord(id: String, displayName: String, email: String, avatarURL: String?) {
        let newUser = UserProfile(
            id: id,
            email: email,
            displayName: displayName,
            avatarURL: avatarURL,
            score: 0,
            savedDeals: [],
            totalUpvotes: 0,
            totalDownvotes: 0,
            totalDeals: 0, // Default value for new users
            totalComments: 0, // Default value for new users
            rankingPoints: 0 // Default value for new users
        )
        let db = Firestore.firestore()

        db.collection("UserProfile")
            .document(id)
            .setData(newUser.asDictionary())
    }

    /// Fetches the current user's profile from Firestore.
    ///
    /// - Parameter completion: A closure that receives the `UserProfile` if fetched successfully, or `nil` if an error occurs or the user is not authenticated.
    private func fetchUser(completion: @escaping (UserProfile?) -> Void) {
        let db = Firestore.firestore()
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(nil)
            return
        }

        let userDoc = db.collection("UserProfile").document(userId)
        userDoc.getDocument { [weak self] snapshot, error in
            if let error {
                print("Error fetching user profile: \(error.localizedDescription)")
                completion(nil)
                return
            }

            if let snapshot, snapshot.exists {
                let data = snapshot.data() ?? [:]
                self?.currentUserProfile = UserProfile(
                    id: data["id"] as? String ?? userId,
                    email: data["email"] as? String ?? "",
                    displayName: data["displayName"] as? String ?? "Anonymous",
                    avatarURL: data["avatarURL"] as? String,
                    score: data["score"] as? Int ?? 0,
                    savedDeals: data["savedDeals"] as? [String] ?? [],
                    totalUpvotes: data["totalUpvotes"] as? Int ?? 0,
                    totalDownvotes: data["totalDownvotes"] as? Int ?? 0,
                    totalDeals: data["totalDeals"] as? Int ?? 0, // Include new field
                    totalComments: data["totalComments"] as? Int ?? 0, // Include new field
                    rankingPoints: data["rankingPoints"] as? Int ?? 0 // Include new field
                )
                completion(self?.currentUserProfile)
            } else {
                print("User profile does not exist.")
                completion(nil)
            }
        }
    }
}

/// An enumeration of possible authentication errors.
enum AuthError: Error {
    /// The password provided is incorrect.
    case wrongPassword
    /// No user was found for the provided credentials.
    case userNotFound
    /// The email address provided is invalid.
    case invalidEmail
    /// An unknown error occurred during authentication.
    case unknownError
    /// The credential provided is invalid.
    case invalidCredential

    /// Creates an `AuthError` from a given `Error`.
    ///
    /// - Parameter error: The original error to convert.
    /// - Returns: An appropriate `AuthError` based on the error code.
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

    /// A localized description of the authentication error.
    var localizedDescription: String {
        switch self {
        case .wrongPassword, .userNotFound, .invalidEmail, .invalidCredential:
            "Invalid credentials. Please check your email and password."
        case .unknownError:
            "An unknown error occurred. Please try again."
        }
    }
}
