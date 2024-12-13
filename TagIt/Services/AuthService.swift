//
//  AuthService.swift
//  TagIt
//
//  Created by 何斯鹏 on 2024-10-16.
//

import FirebaseAuth
import FirebaseFirestore
import Foundation
import AuthenticationServices
import CryptoKit
import SwiftUI // Added for UIApplication access

/// A service responsible for handling user authentication and profile management using Firebase Authentication and Firestore.
class AuthService: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    /// The shared singleton instance of `AuthService`.
    static let shared = AuthService()

    /// The currently authenticated user's profile. This is cached to minimize Firestore reads.
    private var currentUserProfile: UserProfile?
    
    /// The current nonce used for Apple Sign-In. This should be set before initiating the sign-in request.
    private var currentNonce: String?

    /// Private initializer to enforce singleton usage.
    private override init() {}
    
    // MARK: - Nonce Generation
    
    /// Generates a new nonce, sets it as the current nonce, and returns its SHA256 hash.
    func generateAndSetNonce() -> String {
        let nonce = randomNonceString()
        currentNonce = nonce
        return sha256(nonce)
    }
    
    // Generate a random nonce for authentication
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length

        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }

            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }

                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        print("Generated nonce: \(result)")
        return result
    }
    
    // Compute the SHA256 hash of the nonce
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        print("Hashed nonce: \(hashString)")
        return hashString
    }

    // MARK: - User Profile Management
    
    /// Resets the cached current user profile.
    func resetCurrentUserProfile() {
        currentUserProfile = nil
    }

    /// Retrieves the current authenticated user's profile.
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
    func getCurrentUserID() -> String? {
        Auth.auth().currentUser?.uid
    }

    /// Adds an authentication state change listener.
    func addAuthStateChangeListener(completion: @escaping (_ userId: String?) -> Void) -> AuthStateDidChangeListenerHandle {
        Auth.auth().addStateDidChangeListener { _, user in
            DispatchQueue.main.async {
                completion(user?.uid)
            }
        }
    }

    /// Checks whether a user is currently signed in.
    func isSignedIn() -> Bool {
        Auth.auth().currentUser != nil
    }

    /// Logs in a user with the provided email and password.
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

            self.insertUserRecord(id: userId, displayName: displayName, email: email, avatarURL: avatarURL)
            completion(.success(userId)) // Return userId if successful
        }
    }

    /// Inserts a new user record into Firestore.
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
            totalDeals: 0,
            totalComments: 0,
            rankingPoints: 0
        )
        let db = Firestore.firestore()

        db.collection("UserProfile")
            .document(id)
            .setData(newUser.asDictionary())
    }

    /// Fetches the current user's profile from Firestore.
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
                    totalDeals: data["totalDeals"] as? Int ?? 0,
                    totalComments: data["totalComments"] as? Int ?? 0,
                    rankingPoints: data["rankingPoints"] as? Int ?? 0
                )
                completion(self?.currentUserProfile)
            } else {
                print("User profile does not exist.")
                completion(nil)
            }
        }
    }
}

// MARK: - Apple Sign In Helper Methods
extension AuthService {
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            fatalError("No window scene found.")
        }
        return window
    }
    
    /**
     Core authentication logic for handling Apple Sign In credentials.
     This method processes the Apple ID credential, converts it to a Firebase credential,
     and completes the sign-in process.
     */
    private func handleAppleSignInCredential(_ credential: ASAuthorizationAppleIDCredential,
                                             completion: @escaping (Result<String, Error>) -> Void) {
        // Verify we have a valid nonce
        print("Handling Apple Sign In Credential")
        guard let nonce = currentNonce else {
            completion(.failure(NSError(
                domain: "AppleSignIn",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Invalid state: No nonce found for authentication"]
            )))
            return
        }
        
        // Verify we have a valid token
        guard let appleIDToken = credential.identityToken,
              let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            completion(.failure(NSError(
                domain: "AppleSignIn",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Unable to fetch or serialize identity token"]
            )))
            return
        }
        
        // Create Firebase credential
        let firebaseCredential = OAuthProvider.credential(
            providerID: AuthProviderID.apple,
            idToken: idTokenString,
            rawNonce: nonce,
            accessToken: nil
        )
        
        // Sign in with Firebase
        Auth.auth().signIn(with: firebaseCredential) { [weak self] authResult, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let userId = authResult?.user.uid else {
                completion(.failure(NSError(
                    domain: "AppleSignIn",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Unable to get user ID"]
                )))
                return
            }
            
            // For new users, create a profile with their Apple ID information
            if let email = credential.email,
               let fullName = credential.fullName {
                let displayName = [fullName.givenName, fullName.familyName]
                    .compactMap { $0 }
                    .joined(separator: " ")
                
                self?.insertUserRecord(
                    id: userId,
                    displayName: displayName,
                    email: email,
                    avatarURL: nil
                )
            }
            
            self?.fetchUser { _ in
                print("User profile fetched after Apple Sign In")
            }
            
            // Reset the nonce after successful sign-in
            self?.currentNonce = nil
            
            completion(.success(userId))
        }
    }
}

// MARK: - Public Apple Sign In Method
extension AuthService {
    /**
     Handles the authorization completion from SignInWithAppleButton.
     */
    func signInWithApple(authorization: ASAuthorization, completion: @escaping (Result<String, Error>) -> Void) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            print("Invalid credential type received")
            completion(.failure(NSError(domain: "AppleSignIn", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid credential type"])))
            return
        }
        print("Current nonce in callback: \(String(describing: currentNonce))")
        
        if let appleIDToken = appleIDCredential.identityToken,
           let idTokenString = String(data: appleIDToken, encoding: .utf8) {
            print("Received identity token in callback: \(idTokenString)")
        } else {
            print("Unable to retrieve identity token from the credential")
        }
        
        // Use the shared authentication logic
        handleAppleSignInCredential(appleIDCredential) { result in
            switch result {
            case .success(let userId):
                print("Successfully signed in with Apple ID: \(userId)")
                completion(.success(userId))
            case .failure(let error):
                print("Error signing in with Apple: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }
}

// MARK: - AuthError Enumeration
/// An enumeration of possible authentication errors.
enum AuthError: Error {
    case wrongPassword
    case userNotFound
    case invalidEmail
    case unknownError
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
            return "Invalid credentials. Please check your email and password."
        case .unknownError:
            return "An unknown error occurred. Please try again."
        }
    }
}
